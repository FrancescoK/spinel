/* Compile-time evaluation over the node table (ct_eval.h). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ct_eval.h"
#include "builtin_names.h"

static void *ct_grow(void *p, int *cap, int need, size_t elem) {
  if (need <= *cap) return p;
  int nc = *cap ? *cap * 2 : 8;
  while (nc < need) nc *= 2;
  void *r = realloc(p, elem * (size_t)nc);
  if (!r) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  *cap = nc;
  return r;
}

static char *ct_strdup(const char *s) {
  char *r = strdup(s);
  if (!r) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  return r;
}

void ct_env_ran(CtEnv *e, const char *cls, const char *meth) {
  for (int i = 0; i < e->nran; i++)
    if (strcmp(e->ran[i].cls, cls) == 0 && strcmp(e->ran[i].meth, meth) == 0) return;
  e->ran = ct_grow(e->ran, &e->cran, e->nran + 1, sizeof *e->ran);
  e->ran[e->nran].cls = ct_strdup(cls);
  e->ran[e->nran].meth = ct_strdup(meth);
  e->nran++;
}

static CtFx *ct_fx(CtEnv *e, CtFxKind k, int site) {
  e->fx = ct_grow(e->fx, &e->cfx, e->nfx + 1, sizeof *e->fx);
  CtFx *f = &e->fx[e->nfx++];
  memset(f, 0, sizeof *f);
  f->k = k; f->site = site; f->cls = -1;
  return f;
}

static CtVal *ct_lookup(CtEnv *e, const char *name) {
  for (int i = 0; i < e->nloc; i++) if (strcmp(e->loc[i].name, name) == 0) return &e->loc[i].v;
  return NULL;
}

int ct_env_set(CtEnv *e, const char *name, CtVal v) {
  CtVal *o = ct_lookup(e, name);
  if (o) { *o = v; return 1; }
  if (e->nloc >= 64) return 0;
  e->loc[e->nloc].name = ct_strdup(name);
  e->loc[e->nloc].v = v;
  e->nloc++;
  return 1;
}

void ct_env_new_call(CtEnv *e) {
  for (int i = 0; i < e->nloc; i++) free(e->loc[i].name);
  e->nloc = 0;
}

void ct_env_free(CtEnv *e) {
  ct_env_new_call(e);
  for (int i = 0; i < e->ncls; i++) free(e->cls[i].name);
  for (int i = 0; i < e->nfx; i++) free(e->fx[i].name);
  for (int i = 0; i < e->nran; i++) { free((char *)e->ran[i].cls); free((char *)e->ran[i].meth); }
  free(e->cls); free(e->fx); free(e->ran);
  memset(e, 0, sizeof *e);
}

/* the core class whose methods a value's calls run */
static const char *ct_class_of(Mv v) {
  switch (v.k) {
  case MV_NIL: return "NilClass";
  case MV_TRUE: return "TrueClass";
  case MV_FALSE: return "FalseClass";
  case MV_INT: return "Integer";
  case MV_STR: return "String";
  case MV_SYM: return "Symbol";
  case MV_ARR: return "Array";
  default: return NULL;
  }
}

/* a plain value (not a constant or a class) */
static int ct_value(const NodeTable *nt, CtEnv *e, int node, Mv *out) {
  CtVal v;
  if (!ct_eval(nt, e, node, &v) || v.k != CT_VALUE) return 0;
  *out = v.mv;
  return 1;
}

/* the arguments of call `call`, when every one is a plain positional one */
static const int *ct_args(const NodeTable *nt, int call, int *argc) {
  int an = nt_ref(nt, call, "arguments");
  const int *av = an >= 0 ? nt_arr(nt, an, "arguments", argc) : NULL;
  if (!av) { *argc = 0; return NULL; }
  for (int i = 0; i < *argc; i++) {
    NodeKind k = nt_kind(nt, av[i]);
    if (k == NK_SplatNode || k == NK_KeywordHashNode || k == NK_BlockArgumentNode) { *argc = -1; return NULL; }
  }
  return av;
}

/* the one statement of a StatementsNode, or -1 */
static int ct_single(const NodeTable *nt, int stmts) {
  int n = 0;
  const int *b = stmts >= 0 && nt_kind(nt, stmts) == NK_StatementsNode ? nt_arr(nt, stmts, "body", &n) : NULL;
  return b && n == 1 ? b[0] : -1;
}

/* the pattern argument of gsub / sub: a regexp literal with no options, or
   an ASCII String */
static int ct_pattern(const NodeTable *nt, CtEnv *e, int node, MvPat *pt) {
  memset(pt, 0, sizeof *pt);
  if (nt_kind(nt, node) == NK_RegularExpressionNode) {
    if (nt_regexp_opts(nt, node) & (NT_RE_IGNORE_CASE | NT_RE_EXTENDED | NT_RE_MULTI_LINE | NT_RE_ONCE)) return 0;
    const char *src = nt_str(nt, node, "unescaped");
    return src && mv_pat_regexp(src, src + strlen(src), pt);
  }
  Mv v;
  if (!ct_value(nt, e, node, &v) || v.k != MV_STR || !mv_ascii(v.s) || !v.s[0]) return 0;
  pt->lit = 1; pt->text = v.s; pt->tn = strlen(v.s);
  return 1;
}

/* the text of a String or Symbol's parts */
static int ct_parts(const NodeTable *nt, CtEnv *e, int node, MvBuf *b) {
  int pn = 0;
  const int *parts = nt_arr(nt, node, "parts", &pn);
  for (int i = 0; i < pn; i++) {
    NodeKind k = nt_kind(nt, parts[i]);
    if (k == NK_StringNode) { const char *t = nt_str(nt, parts[i], "content"); mvb_puts(b, t ? t : ""); }
    else if (k == NK_EmbeddedStatementsNode) {
      Mv v;
      int st = ct_single(nt, nt_ref(nt, parts[i], "statements"));
      if (st < 0 || !ct_value(nt, e, st, &v)) return 0;
      if (v.k == MV_ARR) {
        if (!mv_inspect_exact(v)) return 0;
        ct_env_ran(e, "Array", "inspect");
        mv_inspect(v, b);
      }
      else {
        if (ct_class_of(v)) ct_env_ran(e, ct_class_of(v), "to_s");
        mv_to_s(v, b);
      }
    }
    else if (k == NK_InterpolatedStringNode) { if (!ct_parts(nt, e, parts[i], b)) return 0; }
    else return 0;
  }
  return 1;
}

/* is interpolated String `node` adjacent literals only ("a" "b") */
static int ct_literal_fold(const NodeTable *nt, int node) {
  int pn = 0;
  const int *parts = nt_arr(nt, node, "parts", &pn);
  for (int i = 0; i < pn; i++)
    if (nt_kind(nt, parts[i]) != NK_StringNode &&
        (nt_kind(nt, parts[i]) != NK_InterpolatedStringNode || !ct_literal_fold(nt, parts[i]))) return 0;
  return 1;
}

/* `Class.new(Constant)` without a block: a class of the evaluation's own */
static int ct_class_new(const NodeTable *nt, CtEnv *e, int call, CtVal *out) {
  int rv = nt_ref(nt, call, "receiver"), argc = 0;
  const int *av = ct_args(nt, call, &argc);
  if (rv < 0 || nt_kind(nt, rv) != NK_ConstantReadNode || !is_class_const_name(nt_str(nt, rv, "name")) ||
      nt_ref(nt, call, "block") >= 0 || argc != 1) return 0;
  CtVal pv;
  if (!ct_eval(nt, e, av[0], &pv) || pv.k != CT_CONST) return 0;
  ct_env_ran(e, "Class", "new");
  e->cls = ct_grow(e->cls, &e->ccls, e->ncls + 1, sizeof *e->cls);
  e->cls[e->ncls].parent = pv.node;
  e->cls[e->ncls].name = NULL;
  memset(out, 0, sizeof *out);
  out->k = CT_CLASS; out->cls = e->ncls++;
  CtFx *f = ct_fx(e, CT_FX_CLASS_NEW, call);
  f->cls = out->cls;
  return 1;
}

static int ct_eval_call(const NodeTable *nt, CtEnv *e, int call, CtVal *out) {
  const char *name = nt_str(nt, call, "name");
  int rv = nt_ref(nt, call, "receiver"), argc = 0;
  const int *av = ct_args(nt, call, &argc);
  if (!name || rv < 0 || nt_kind(nt, rv) == NK_SelfNode || argc < 0 || nt_ref(nt, call, "block") >= 0) return 0;
  if (is_new_name(name)) return ct_class_new(nt, e, call, out);
  Mv r, a0;
  memset(out, 0, sizeof *out);
  if (!ct_value(nt, e, rv, &r)) return 0;
  if (argc == 2 && is_substitution(name) && r.k == MV_STR && mv_ascii(r.s)) {
    MvPat pt; Mv rep;
    if (!ct_pattern(nt, e, av[0], &pt) || !ct_value(nt, e, av[1], &rep) || rep.k != MV_STR) return 0;
    ct_env_ran(e, "String", name);
    return mv_sub(r, &pt, rep.s, name[0] == 'g', &out->mv);
  }
  memset(&a0, 0, sizeof a0);
  if (argc > 1 || (argc == 1 && !ct_value(nt, e, av[0], &a0))) return 0;
  if (!mv_call(name, r, argc, a0, &out->mv)) return 0;
  if (ct_class_of(r)) ct_env_ran(e, ct_class_of(r), name);
  return 1;
}

int ct_eval(const NodeTable *nt, CtEnv *e, int node, CtVal *out) {
  memset(out, 0, sizeof *out);
  if (node < 0) { out->mv = mv_nil(); return 1; }
  switch (nt_kind(nt, node)) {
  case NK_NilNode: out->mv = mv_nil(); return 1;
  case NK_TrueNode: out->mv = mv_nil(); out->mv.k = MV_TRUE; return 1;
  case NK_FalseNode: out->mv = mv_nil(); out->mv.k = MV_FALSE; return 1;
  case NK_IntegerNode:
    if (nt_str(nt, node, "bigval")) return 0;   /* a Bignum */
    out->mv = mv_nil(); out->mv.k = MV_INT; out->mv.i = nt_int(nt, node, "value", 0);
    return 1;
  case NK_StringNode: case NK_SymbolNode: {
    int str = nt_kind(nt, node) == NK_StringNode;
    const char *t = nt_str(nt, node, str ? "content" : "value");
    if (!t) return 0;
    out->mv = mv_str(t, strlen(t), str ? MV_STR : MV_SYM);
    /* a frozen literal is the literal of its bytes; an unfrozen one (the
       file's pragma off) a new String each time it runs */
    out->mv.frozen = out->mv.lit = str && nt_int(nt, node, "fzl", 0) != 0;
    return 1;
  }
  case NK_InterpolatedStringNode: case NK_InterpolatedSymbolNode: {
    MvBuf b = {0};
    int ok = ct_parts(nt, e, node, &b);
    if (ok) out->mv = mv_str(b.p ? b.p : "", b.len, nt_kind(nt, node) == NK_InterpolatedStringNode ? MV_STR : MV_SYM);
    free(b.p);
    /* adjacent literals ("a" "b") are one literal, frozen as a literal is */
    if (ok && nt_kind(nt, node) == NK_InterpolatedStringNode && ct_literal_fold(nt, node))
      out->mv.frozen = out->mv.lit = nt_int(nt, node, "fzl", 0) != 0;
    return ok;
  }
  case NK_ArrayNode: {
    int en = 0;
    const int *el = nt_arr(nt, node, "elements", &en);
    out->mv = mv_nil(); out->mv.k = MV_ARR; out->mv.n = en;
    out->mv.a = calloc((size_t)en + 1, sizeof(Mv));
    if (!out->mv.a) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
    for (int i = 0; i < en; i++)
      if (nt_kind(nt, el[i]) == NK_SplatNode || !ct_value(nt, e, el[i], &out->mv.a[i])) return 0;
    return 1;
  }
  case NK_ConstantReadNode: case NK_ConstantPathNode:
    out->k = CT_CONST; out->node = node;
    return 1;
  case NK_LocalVariableReadNode: {
    const char *nm = nt_str(nt, node, "name");
    CtVal *v = nm && nt_int(nt, node, "depth", 0) == 0 ? ct_lookup(e, nm) : NULL;
    if (!v) return 0;
    *out = *v;
    return 1;
  }
  case NK_ParenthesesNode: {
    int b = nt_ref(nt, node, "body");
    if (b >= 0 && nt_kind(nt, b) == NK_StatementsNode) b = ct_single(nt, b);
    return b >= 0 && ct_eval(nt, e, b, out);
  }
  case NK_AndNode: case NK_OrNode: {
    Mv l;
    if (!ct_value(nt, e, nt_ref(nt, node, "left"), &l)) return 0;
    if ((nt_kind(nt, node) == NK_AndNode) != mv_truthy(l)) { out->mv = l; return 1; }
    return ct_eval(nt, e, nt_ref(nt, node, "right"), out);
  }
  case NK_IfNode: {
    /* `c ? a : b`, and an if whose arms are one expression each */
    Mv pv;
    if (!ct_value(nt, e, nt_ref(nt, node, "predicate"), &pv)) return 0;
    int arm = nt_ref(nt, node, "statements");
    if (!mv_truthy(pv)) {
      int el = nt_ref(nt, node, "subsequent");
      if (el < 0) { out->mv = mv_nil(); return 1; }
      if (nt_kind(nt, el) != NK_ElseNode) return ct_eval(nt, e, el, out);
      arm = nt_ref(nt, el, "statements");
    }
    if (arm < 0) { out->mv = mv_nil(); return 1; }
    int one = ct_single(nt, arm);
    return one >= 0 && ct_eval(nt, e, one, out);
  }
  case NK_CallNode: return ct_eval_call(nt, e, node, out);
  default: return 0;
  }
}

/* does `when` value w match v */
static int ct_when_matches(const NodeTable *nt, CtEnv *e, int w, Mv v, int *hit) {
  if (nt_kind(nt, w) == NK_RangeNode) {
    Mv lo, hi;
    int l = nt_ref(nt, w, "left"), r = nt_ref(nt, w, "right");
    if (l < 0 || r < 0 || !ct_value(nt, e, l, &lo) || !ct_value(nt, e, r, &hi) || lo.k != MV_INT || hi.k != MV_INT) return 0;
    ct_env_ran(e, "Range", "===");
    *hit = v.k == MV_INT && v.i >= lo.i && (nt_range_excl(nt, w) ? v.i < hi.i : v.i <= hi.i);
    return 1;
  }
  Mv wv;
  if (!ct_value(nt, e, w, &wv) || (wv.k != MV_INT && wv.k != MV_STR && wv.k != MV_SYM)) return 0;
  ct_env_ran(e, ct_class_of(wv), "===");
  *hit = mv_eq(v, wv);
  return 1;
}

/* a constant name const_set accepts and the program could have written */
static int ct_const_name(Mv n) {
  if ((n.k != MV_STR && n.k != MV_SYM) || !n.s[0] || n.s[0] < 'A' || n.s[0] > 'Z' || !mv_sym_plain(n.s)) return 0;
  char last = n.s[strlen(n.s) - 1];
  return last != '?' && last != '!' && last != '=';
}

/* the statement call `call`: one of the effects the evaluator follows */
static int ct_exec_call(const NodeTable *nt, CtEnv *e, int call) {
  const char *name = nt_str(nt, call, "name");
  int rv = nt_ref(nt, call, "receiver"), argc = 0;
  const int *av = ct_args(nt, call, &argc);
  if (!name || argc < 0 || nt_ref(nt, call, "block") >= 0) return 0;
  int self_recv = rv < 0 || nt_kind(nt, rv) == NK_SelfNode;
  if (self_recv && argc == 2 && is_const_set_name(name)) {
    Mv cn; CtVal v;
    if (!ct_value(nt, e, av[0], &cn) || !ct_const_name(cn) || !ct_eval(nt, e, av[1], &v)) return 0;
    ct_env_ran(e, "Class", name);
    CtFx *f = ct_fx(e, CT_FX_CONST_SET, call);
    f->name = ct_strdup(cn.s); f->val = v;
    /* an anonymous class takes the first name it is given */
    if (v.k == CT_CLASS && !e->cls[v.cls].name) { e->cls[v.cls].name = ct_strdup(cn.s); f->names = 1; }
    return 1;
  }
  if (!self_recv && argc == 2 && is_ivar_set_name(name)) {
    CtVal r, v; Mv iv;
    if (!ct_eval(nt, e, rv, &r) || r.k != CT_CLASS || !ct_value(nt, e, av[0], &iv) ||
        (iv.k != MV_SYM && iv.k != MV_STR) || iv.s[0] != '@' || iv.s[1] == '@' || !mv_sym_plain(iv.s + 1) ||
        !ct_eval(nt, e, av[1], &v)) return 0;
    ct_env_ran(e, "Class", name);
    CtFx *f = ct_fx(e, CT_FX_IVAR_SET, call);
    f->cls = r.cls; f->name = ct_strdup(iv.s); f->val = v;
    return 1;
  }
  if (!self_recv && argc == 2 && is_index_assign(name) &&
      (nt_kind(nt, rv) == NK_ConstantReadNode || nt_kind(nt, rv) == NK_ConstantPathNode)) {
    CtVal k, v;
    if (!ct_eval(nt, e, av[0], &k) || !ct_eval(nt, e, av[1], &v)) return 0;
    CtFx *f = ct_fx(e, CT_FX_INDEX_SET, call);
    f->recv.k = CT_CONST; f->recv.node = rv; f->key = k; f->val = v;
    return 1;
  }
  if (!self_recv && argc == 0 && is_freeze_name(name)) {
    /* a value the code holds: a String frozen here keeps its literal (lit).
       One the evaluation made may be held by other locals too, which this
       local's value would not tell: not followed. */
    CtVal r;
    if (!ct_eval(nt, e, rv, &r) || r.k != CT_VALUE || (r.mv.k != MV_STR && r.mv.k != MV_INT && r.mv.k != MV_SYM) ||
        (r.mv.k == MV_STR && !r.mv.lit && !r.mv.frozen)) return 0;
    ct_env_ran(e, ct_class_of(r.mv), name);
    if (nt_kind(nt, rv) == NK_LocalVariableReadNode && nt_str(nt, rv, "name")) {
      CtVal *lv = ct_lookup(e, nt_str(nt, rv, "name"));
      if (lv) lv->mv.frozen = 1;
    }
    return 1;
  }
  return 0;
}

static int ct_exec_one(const NodeTable *nt, CtEnv *e, int n) {
  switch (nt_kind(nt, n)) {
  case NK_LocalVariableWriteNode: {
    const char *nm = nt_str(nt, n, "name");
    CtVal v;
    if (!nm || nt_int(nt, n, "depth", 0) != 0) return 0;   /* a local of the scope around the block */
    return ct_eval(nt, e, nt_ref(nt, n, "value"), &v) && ct_env_set(e, nm, v);
  }
  case NK_IfNode: case NK_UnlessNode: {
    int is_if = nt_kind(nt, n) == NK_IfNode;
    Mv pv;
    if (!ct_value(nt, e, nt_ref(nt, n, "predicate"), &pv)) return 0;
    if (mv_truthy(pv) == is_if) return ct_exec(nt, e, nt_ref(nt, n, "statements"));
    int el = nt_ref(nt, n, is_if ? "subsequent" : "else_clause");
    if (el < 0) return 1;
    if (nt_kind(nt, el) == NK_ElseNode) return ct_exec(nt, e, nt_ref(nt, el, "statements"));
    return ct_exec_one(nt, e, el);
  }
  case NK_CaseNode: {
    Mv v;
    int pred = nt_ref(nt, n, "predicate"), wn = 0;
    if (pred < 0 || !ct_value(nt, e, pred, &v)) return 0;
    const int *ws = nt_arr(nt, n, "conditions", &wn);
    for (int i = 0; i < wn; i++) {
      if (nt_kind(nt, ws[i]) != NK_WhenNode) return 0;
      int cn = 0;
      const int *cs = nt_arr(nt, ws[i], "conditions", &cn);
      for (int j = 0; j < cn; j++) {
        int hit = 0;
        if (!ct_when_matches(nt, e, cs[j], v, &hit)) return 0;
        if (hit) return ct_exec(nt, e, nt_ref(nt, ws[i], "statements"));
      }
    }
    int el = nt_ref(nt, n, "else_clause");
    return el >= 0 ? ct_exec(nt, e, nt_ref(nt, el, "statements")) : 1;
  }
  case NK_CallNode: return ct_exec_call(nt, e, n);
  default: return 0;
  }
}

int ct_exec(const NodeTable *nt, CtEnv *e, int stmts) {
  if (stmts < 0) return 1;
  if (nt_kind(nt, stmts) != NK_StatementsNode) return 0;
  int n = 0;
  const int *b = nt_arr(nt, stmts, "body", &n);
  for (int i = 0; i < n; i++) if (!ct_exec_one(nt, e, b[i])) return 0;
  return 1;
}
