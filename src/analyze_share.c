/* analyze_share.c -- the share classes --share-strings decides by (#6765).

   See share.h. One walk over the node table gives every node a value (an
   element of the union-find, or none) and unifies what flows together:
   each write with its target, each container store with the container's
   elements, each yield with what the method yields, each return with the
   method's value. What the walk does not follow -- here every call but the
   in-place String mutation of its receiver -- joins UNKNOWN, so a case it
   misses costs a handle, never a silent copy. */

#include <stdlib.h>
#include <string.h>
#include "analyze_internal.h"
#include "builtin_names.h"
#include "share.h"

/* element-own flags (not merged by a union) */
enum { SHE_WRITTEN = 1 };

typedef struct ShareFacts {
  int n, cap;
  int *parent, *elem, *nhold, *nmem, *nelem, *hidx, *owner;
  /* the mutation sites, for SPINEL_SHARE_STATS=3: node, value */
  int *mut_n, *mut_v, nmut, cmut;
  int *hcount;         /* per root, once built: holders storing a String */
  unsigned char *kind, *flags, *own;
  /* the holders, and their element */
  ShareHolder *h;
  int *helem, nh, ch;
  /* holder keys: a hash over (kind, a, name) */
  int *bucket, *hnext;
  int nbucket;
  /* each node's value: -2 not yet computed, -1 none */
  int *nval, nnodes;
  /* the method names a Method, `send` or define_method can reach */
  const char **dyn;
  int ndyn, cdyn, dyn_all, dyn_ivars;
  const char **mconst;
  int nmconst, cmconst;
  int unknown;
  int closed;          /* unions with UNKNOWN are dropped (the stats' second build) */
  int union_stack_cap;
  int *union_stack;
} ShareFacts;

/* ---- the union-find ---- */

static int sh_find(ShareFacts *F, int x) {
  while (F->parent[x] != x) {
    F->parent[x] = F->parent[F->parent[x]];
    x = F->parent[x];
  }
  return x;
}

static int sh_storing_kind(int k) {
  return k == SHK_LOCAL || k == SHK_IVAR || k == SHK_GVAR || k == SHK_CVAR ||
         k == SHK_CONST || k == SHK_ELEM;
}

static int sh_new(ShareFacts *F, int kind) {
  if (F->n >= F->cap) {
    int nc = F->cap ? F->cap * 2 : 1024;
    F->parent = realloc(F->parent, sizeof(int) * (size_t)nc);
    F->elem = realloc(F->elem, sizeof(int) * (size_t)nc);
    F->nhold = realloc(F->nhold, sizeof(int) * (size_t)nc);
    F->nmem = realloc(F->nmem, sizeof(int) * (size_t)nc);
    F->nelem = realloc(F->nelem, sizeof(int) * (size_t)nc);
    F->hidx = realloc(F->hidx, sizeof(int) * (size_t)nc);
    F->owner = realloc(F->owner, sizeof(int) * (size_t)nc);
    F->kind = realloc(F->kind, (size_t)nc);
    F->flags = realloc(F->flags, (size_t)nc);
    F->own = realloc(F->own, (size_t)nc);
    F->cap = nc;
  }
  int e = F->n++;
  F->parent[e] = e;
  F->elem[e] = -1;
  F->nhold[e] = sh_storing_kind(kind);
  F->nmem[e] = 1;
  F->nelem[e] = kind == SHK_ELEM;
  F->hidx[e] = -1;
  F->owner[e] = -1;
  F->kind[e] = (unsigned char)kind;
  F->flags[e] = 0;
  F->own[e] = 0;
  return e;
}

static void sh_union(ShareFacts *F, int a, int b) {
  if (a < 0 || b < 0) return;
  int sp = 0;
  if (F->union_stack_cap < 64) {
    F->union_stack_cap = 64;
    F->union_stack = realloc(F->union_stack, sizeof(int) * 2 * 64);
  }
  F->union_stack[sp++] = a; F->union_stack[sp++] = b;
  while (sp > 0) {
    int y = F->union_stack[--sp], x = F->union_stack[--sp];
    int rx = sh_find(F, x), ry = sh_find(F, y);
    if (rx == ry) continue;
    if (F->closed) {
      int ru = sh_find(F, F->unknown);
      if (rx == ru || ry == ru) continue;
    }
    if (F->nmem[rx] < F->nmem[ry]) { int t = rx; rx = ry; ry = t; }
    F->parent[ry] = rx;
    F->flags[rx] |= F->flags[ry];
    F->nhold[rx] += F->nhold[ry];
    F->nmem[rx] += F->nmem[ry];
    F->nelem[rx] += F->nelem[ry];
    int ex = F->elem[rx], ey = F->elem[ry];
    if (ex < 0) F->elem[rx] = ey;
    else if (ey >= 0) {
      if (sp + 2 > F->union_stack_cap * 2) {
        F->union_stack_cap *= 2;
        F->union_stack = realloc(F->union_stack, sizeof(int) * 2 * (size_t)F->union_stack_cap);
      }
      F->union_stack[sp++] = ex; F->union_stack[sp++] = ey;
    }
  }
}

/* the element of x's containers' elements, made on first use */
static int sh_elem(ShareFacts *F, int x) {
  if (x < 0) return -1;
  int r = sh_find(F, x);
  if (F->elem[r] < 0) {
    int e = sh_new(F, SHK_ELEM);
    r = sh_find(F, x);
    F->elem[r] = e;
    F->owner[e] = r;
  }
  return F->elem[r];
}

static void sh_mark_at(ShareFacts *F, int x, unsigned fl, int node) {
  if (x < 0) return;
  if (F->nmut >= F->cmut) {
    F->cmut = F->cmut ? F->cmut * 2 : 64;
    F->mut_n = realloc(F->mut_n, sizeof(int) * (size_t)F->cmut);
    F->mut_v = realloc(F->mut_v, sizeof(int) * (size_t)F->cmut);
  }
  F->mut_n[F->nmut] = node;
  F->mut_v[F->nmut] = x;
  F->nmut++;
  F->flags[sh_find(F, x)] |= (unsigned char)fl;
}

/* ---- holders ---- */

static unsigned sh_key_hash(int kind, int a, const char *name) {
  unsigned h = (unsigned)kind * 2654435761u ^ (unsigned)a * 40503u;
  if (name) h ^= sp_strhash(name);
  return h;
}

static int sh_holder(ShareFacts *F, int kind, int a, int b, const char *name, int node) {
  if (!name && (kind == SHK_IVAR || kind == SHK_GVAR || kind == SHK_CVAR || kind == SHK_CONST)) return -1;
  if (!F->bucket) {
    F->nbucket = 4096;
    F->bucket = malloc(sizeof(int) * (size_t)F->nbucket);
    for (int i = 0; i < F->nbucket; i++) F->bucket[i] = -1;
  }
  unsigned hb = sh_key_hash(kind, a, name) & (unsigned)(F->nbucket - 1);
  for (int i = F->bucket[hb]; i >= 0; i = F->hnext[i]) {
    ShareHolder *h = &F->h[i];
    if (h->kind != kind) continue;
    if (kind == SHK_LOCAL ? (h->scope == a && h->local == b) :
        kind == SHK_IVAR ? (h->cid == a && sp_streq(h->name, name)) :
        (kind == SHK_RET || kind == SHK_YIELD || kind == SHK_BLKRET) ? h->scope == a :
        sp_streq(h->name, name))
      return F->helem[i];
  }
  if (F->nh >= F->ch) {
    F->ch = F->ch ? F->ch * 2 : 256;
    F->h = realloc(F->h, sizeof(ShareHolder) * (size_t)F->ch);
    F->helem = realloc(F->helem, sizeof(int) * (size_t)F->ch);
    F->hnext = realloc(F->hnext, sizeof(int) * (size_t)F->ch);
  }
  int i = F->nh++;
  ShareHolder *h = &F->h[i];
  memset(h, 0, sizeof *h);
  h->kind = (unsigned char)kind;
  h->scope = kind == SHK_IVAR ? -1 : a;
  h->local = b;
  h->cid = kind == SHK_IVAR ? a : -1;
  h->name = name ? strdup(name) : NULL;
  h->node = node;
  int e = sh_new(F, kind);
  F->helem[i] = e;
  F->hidx[e] = i;
  F->hnext[i] = F->bucket[hb];
  F->bucket[hb] = i;
  return e;
}

/* Can a value of type t hold a String, or a container of them? An object's
   Strings sit in its ivars, which are holders of their own. */
static int sh_may_hold(TyKind t) {
  if (ty_is_object(t) || ty_is_obj_array(t)) return 0;
  switch (t) {
  case TY_VOID: case TY_NIL: case TY_INT: case TY_BIGINT: case TY_FLOAT: case TY_SYMBOL:
  case TY_BOOL: case TY_RANGE: case TY_FLOAT_RANGE: case TY_TIME: case TY_COMPLEX:
  case TY_RATIONAL: case TY_MATCHDATA: case TY_REGEX: case TY_EXCEPTION:
  case TY_INT_ARRAY: case TY_FLOAT_ARRAY: case TY_INT_ARRAY_ARRAY: case TY_FLOAT_ARRAY_ARRAY:
  case TY_STR_INT_HASH: case TY_INT_INT_HASH: case TY_PROC: case TY_CURRY: case TY_FIBER:
  case TY_THREAD: case TY_QUEUE: case TY_MUTEX: case TY_CONDVAR: case TY_RANDOM: case TY_DIR:
  case TY_ADDRINFO: case TY_SOCKOPT: case TY_TMS: case TY_PROCESS_STATUS: case TY_OPENSTRUCT:
  case TY_METHOD: case TY_IO: case TY_ARGF: case TY_CLASS:
    return 0;
  default:
    return 1;
  }
}

static int sh_local_of(ShareFacts *F, Compiler *c, Scope *s, const char *name, int node) {
  if (!s || !name) return -1;
  LocalVar *lv = scope_local(s, name);
  if (!lv || !sh_may_hold(lv->type)) return -1;
  return sh_holder(F, SHK_LOCAL, (int)(s - c->scopes), (int)(lv - s->locals), NULL, node);
}

static int sh_local_at(ShareFacts *F, Compiler *c, int node) {
  return sh_local_of(F, c, comp_scope_of(c, node), nt_str(c->nt, node, "name"), node);
}

/* the class whose ivar slot an ivar node names, as the emitters store it */
static int sh_ivar_owner(Compiler *c, int node) {
  Scope *s = comp_scope_of(c, node);
  if (s && s->class_id >= 0) return s->class_id;
  return comp_class_index(c, "Toplevel");
}

static int sh_ivar(ShareFacts *F, Compiler *c, int cid, const char *name, int node) {
  if (cid < 0 || !name) return -1;
  int iv = comp_ivar_index(&c->classes[cid], name);
  if (iv >= 0 && !sh_may_hold(c->classes[cid].ivar_types[iv])) return -1;
  return sh_holder(F, SHK_IVAR, cid, -1, name, node);
}

static int sh_gvar(ShareFacts *F, Compiler *c, const char *name, int node) {
  if (!name) return -1;
  LocalVar *gv = comp_gvar(c, name[0] == '$' ? name + 1 : name);
  if (gv && !sh_may_hold(gv->type)) return -1;
  return sh_holder(F, SHK_GVAR, 0, -1, name, node);
}

static int sh_scope_holder(ShareFacts *F, int kind, int mi) {
  return mi < 0 ? -1 : sh_holder(F, kind, mi, -1, NULL, -1);
}

static int sh_method_index(Compiler *c, int node) {
  Scope *s = comp_scope_of(c, node);
  return s && s->def_node >= 0 ? (int)(s - c->scopes) : -1;
}

static int sh_holder_read(const NodeTable *nt, int n) {
  NodeKind k = n >= 0 ? nt_kind(nt, n) : NK_NONE;
  return k == NK_LocalVariableReadNode || k == NK_InstanceVariableReadNode ||
         k == NK_GlobalVariableReadNode || k == NK_ClassVariableReadNode;
}

static void sh_dyn_name(ShareFacts *F, const char *name) {
  if (!name) { F->dyn_all = 1; return; }
  if (F->ndyn >= F->cdyn) {
    F->cdyn = F->cdyn ? F->cdyn * 2 : 16;
    F->dyn = realloc(F->dyn, sizeof(char *) * (size_t)F->cdyn);
  }
  F->dyn[F->ndyn++] = name;
}

/* ---- node values ---- */

static int sh_val(ShareFacts *F, Compiler *c, int n);
static int sh_const_read(ShareFacts *F, Compiler *c, int n);

static int sh_join(ShareFacts *F, int a, int b) {
  if (a < 0) return b;
  if (b < 0) return a;
  sh_union(F, a, b);
  return a;
}

static int sh_stmts_val(ShareFacts *F, Compiler *c, int st) {
  if (st < 0) return -1;
  if (nt_kind(c->nt, st) != NK_StatementsNode) return sh_val(F, c, st);
  int n = 0; const int *b = nt_arr(c->nt, st, "body", &n);
  return n > 0 ? sh_val(F, c, b[n - 1]) : -1;
}

/* the value an argument hands over: a splat's elements, or the value */
static int sh_arg_val(ShareFacts *F, Compiler *c, int a) {
  const NodeTable *nt = c->nt;
  NodeKind k = nt_kind(nt, a);
  if (k == NK_SplatNode) return sh_elem(F, sh_val(F, c, nt_ref(nt, a, "expression")));
  if (k == NK_AssocSplatNode) return sh_elem(F, sh_val(F, c, nt_ref(nt, a, "value")));
  return sh_val(F, c, a);
}

/* every value a call's arguments hand over, keyword values included */
static int sh_args_vals(ShareFacts *F, Compiler *c, int call, int *out, int cap) {
  const NodeTable *nt = c->nt;
  int args = nt_ref(nt, call, "arguments");
  int argc = 0; const int *argv = args >= 0 ? nt_arr(nt, args, "arguments", &argc) : NULL;
  int n = 0;
  for (int i = 0; i < argc && n < cap; i++) {
    NodeKind k = nt_kind(nt, argv[i]);
    if (k == NK_KeywordHashNode) {
      int en = 0; const int *el = nt_arr(nt, argv[i], "elements", &en);
      for (int e = 0; e < en && n < cap; e++) {
        if (nt_kind(nt, el[e]) == NK_AssocNode) out[n++] = sh_val(F, c, nt_ref(nt, el[e], "value"));
        else out[n++] = sh_arg_val(F, c, el[e]);
      }
      continue;
    }
    if (k == NK_BlockArgumentNode) continue;
    out[n++] = sh_arg_val(F, c, argv[i]);
  }
  return n;
}

/* Bind a target (a write's target node inside a multiple assignment, a
   block's parameter, a for loop's index) to value v. */
static void sh_target(ShareFacts *F, Compiler *c, int t, int v);

static void sh_targets_of(ShareFacts *F, Compiler *c, int t, int v) {
  const NodeTable *nt = c->nt;
  static const char *const fields[] = { "lefts", "rights" };
  int ev = sh_elem(F, v);
  for (int f = 0; f < 2; f++) {
    int n = 0; const int *ts = nt_arr(nt, t, fields[f], &n);
    for (int i = 0; i < n; i++) sh_target(F, c, ts[i], ev);
  }
  int rest = nt_ref(nt, t, "rest");
  if (rest >= 0) sh_target(F, c, rest, v);
}

static void sh_target(ShareFacts *F, Compiler *c, int t, int v) {
  const NodeTable *nt = c->nt;
  if (t < 0) return;
  switch (nt_kind(nt, t)) {
  case NK_LocalVariableTargetNode: case NK_RequiredParameterNode: case NK_OptionalParameterNode:
  case NK_RestParameterNode: case NK_OptionalKeywordParameterNode: case NK_KeywordRestParameterNode:
  sh_param: {
    int l = sh_local_at(F, c, t);
    if (l >= 0) F->own[l] |= SHE_WRITTEN;
    NodeKind k = nt_kind(nt, t);
    /* a rest gathers values: its elements are them */
    if (k == NK_RestParameterNode || k == NK_KeywordRestParameterNode) sh_union(F, sh_elem(F, l), v);
    else sh_union(F, l, v);
    int dv = nt_ref(nt, t, "value");   /* an optional parameter's default */
    if (dv >= 0 && k != NK_LocalVariableTargetNode) sh_union(F, l, sh_val(F, c, dv));
    return;
  }
  case NK_InstanceVariableTargetNode:
    sh_union(F, sh_ivar(F, c, sh_ivar_owner(c, t), nt_str(nt, t, "name"), t), v);
    return;
  case NK_GlobalVariableTargetNode:
    sh_union(F, sh_gvar(F, c, nt_str(nt, t, "name"), t), v);
    return;
  case NK_ClassVariableTargetNode:
    sh_union(F, sh_holder(F, SHK_CVAR, 0, -1, nt_str(nt, t, "name"), t), v);
    return;
  case NK_ConstantTargetNode:
    sh_union(F, sh_holder(F, SHK_CONST, 0, -1, nt_str(nt, t, "name"), t), v);
    return;
  case NK_IndexTargetNode:
    sh_union(F, sh_elem(F, sh_val(F, c, nt_ref(nt, t, "receiver"))), v);
    return;
  case NK_SplatNode:
    sh_target(F, c, nt_ref(nt, t, "expression"), v);
    return;
  case NK_MultiTargetNode:
    sh_targets_of(F, c, t, v);
    return;
  default:
    if (nt_type(nt, t) && sp_streq(nt_type(nt, t), "RequiredKeywordParameterNode")) goto sh_param;
    /* a call target (`o.x, y = ...`) or anything else: not followed */
    sh_union(F, v, F->unknown);
    return;
  }
}

/* A block's parameters, each bound to v (a destructured one to v's
   elements); `deep` also binds each to the elements of v's elements, for an
   iterator that splats an element over several parameters. */
static void sh_block_params(ShareFacts *F, Compiler *c, int blk, int v, int deep) {
  const NodeTable *nt = c->nt;
  if (blk < 0 || v < 0) return;
  int bp = nt_ref(nt, blk, "parameters");
  if (bp < 0) return;
  if (nt_kind(nt, bp) != NK_BlockParametersNode) {
    /* `_1` / `it`: the parameters by name */
    for (int i = 0; ; i++) {
      const char *pn = block_param_name(c, blk, i);
      if (!pn) break;
      sh_union(F, sh_local_of(F, c, comp_scope_of(c, blk), pn, blk), v);
    }
    return;
  }
  int pn = nt_ref(nt, bp, "parameters");
  if (pn < 0) return;
  int nreq = 0; const int *reqs = nt_arr(nt, pn, "requireds", &nreq);
  int nopt = 0; nt_arr(nt, pn, "optionals", &nopt);
  int many = nreq + nopt > 1 || nt_ref(nt, pn, "rest") >= 0;
  for (int i = 0; i < nreq; i++)
    if (nt_kind(nt, reqs[i]) == NK_MultiTargetNode) many = 1;
  int ev = deep && many ? sh_elem(F, v) : -1;
  static const char *const lists[] = { "requireds", "optionals", "posts", "keywords" };
  for (int f = 0; f < 4; f++) {
    int n = 0; const int *ps = nt_arr(nt, pn, lists[f], &n);
    for (int i = 0; i < n; i++) {
      sh_target(F, c, ps[i], v);
      if (ev >= 0) sh_target(F, c, ps[i], ev);
    }
  }
  int rest = nt_ref(nt, pn, "rest");
  if (rest >= 0) sh_target(F, c, rest, v);
  int kwr = nt_ref(nt, pn, "keyword_rest");
  if (kwr >= 0) sh_target(F, c, kwr, v);
}

static int sh_block_val(ShareFacts *F, Compiler *c, int blk) {
  return blk >= 0 ? sh_stmts_val(F, c, nt_ref(c->nt, blk, "body")) : -1;
}

/* the literal name a `send`, `method` or `instance_variable_*` names */
static const char *sh_lit_name(const NodeTable *nt, int a) {
  if (a < 0) return NULL;
  NodeKind k = nt_kind(nt, a);
  if (k == NK_SymbolNode) return nt_str(nt, a, "value") ? nt_str(nt, a, "value") : nt_str(nt, a, "unescaped");
  if (k == NK_StringNode) return nt_str(nt, a, "content");
  return NULL;
}

/* The ivars the attr readers (or, for `x=`, the writers) of the name on any
   class read or write, joined; -1 when no class has one. */
static int sh_attr_ivars(ShareFacts *F, Compiler *c, const char *name, int node, int *writer) {
  size_t ln = strlen(name);
  *writer = ln > 1 && name[ln - 1] == '=' && name[0] != '=' && name[0] != '!' &&
            name[0] != '<' && name[0] != '>' && name[0] != '[';
  char base[256];
  if (ln >= sizeof base - 2) return -1;
  base[0] = '@';
  memcpy(base + 1, name, ln - (size_t)*writer);
  base[1 + ln - (size_t)*writer] = 0;
  int r = -1;
  for (int k = 0; k < c->nclasses; k++) {
    ClassInfo *ci = &c->classes[k];
    char **names = *writer ? ci->writers : ci->readers;
    int nn = *writer ? ci->nwriters : ci->nreaders;
    for (int i = 0; i < nn; i++)
      if (names[i] && sp_streq(names[i], base + 1)) r = sh_join(F, r, sh_ivar(F, c, k, base, node));
  }
  return r;
}

/* A call the walk does not follow: what it is handed and what it answers
   are UNKNOWN. */
static int sh_unknown_call(ShareFacts *F, Compiler *c, int n, int blk) {
  int vals[64];
  int nv = sh_args_vals(F, c, n, vals, 64);
  for (int i = 0; i < nv; i++) sh_union(F, vals[i], F->unknown);
  if (blk >= 0 && nt_kind(c->nt, blk) == NK_BlockNode) {
    sh_block_params(F, c, blk, F->unknown, 1);
    sh_union(F, sh_block_val(F, c, blk), F->unknown);
  }
  return F->unknown;
}

static int sh_call(ShareFacts *F, Compiler *c, int n) {
  const NodeTable *nt = c->nt;
  const char *name = nt_str(nt, n, "name");
  if (!name) return F->unknown;
  int recv = nt_ref(nt, n, "receiver");
  int blk = nt_ref(nt, n, "block");
  int args = nt_ref(nt, n, "arguments");
  int argc = 0; const int *argv = args >= 0 ? nt_arr(nt, args, "arguments", &argc) : NULL;
  int rv = recv >= 0 ? sh_val(F, c, recv) : -1;
  TyKind rt = recv >= 0 ? c->ntype[recv] : TY_VOID;
  int maybe_str = recv >= 0 && (rt == TY_STRING || rt == TY_STRBUF || rt == TY_POLY || rt == TY_UNKNOWN);

  /* an in-place String mutation of the receiver */
  if (maybe_str && sp_str_mutator(name, 0))
    sh_mark_at(F, rv, SHF_MUT | (sh_holder_read(nt, recv) ? 0 : SHF_INDIRECT), n);

  /* a block passed as a value: a proc or a Method, called from wherever */
  if (blk >= 0 && nt_kind(nt, blk) == NK_BlockArgumentNode) {
    int bx = nt_ref(nt, blk, "expression");
    const char *sym = sh_lit_name(nt, bx);
    if (sym && bx >= 0 && nt_kind(nt, bx) == NK_SymbolNode) {
      /* `&:upcase!` runs the name on each element */
      if (sp_str_mutator(sym, 0)) sh_mark_at(F, sh_elem(F, rv), SHF_MUT | SHF_INDIRECT, n);
      sh_dyn_name(F, sym);
    }
    else sh_union(F, sh_elem(F, rv), F->unknown);
  }

  /* the reflective names */
  if (is_send_family(name)) {
    const char *lit = argc >= 1 ? sh_lit_name(nt, argv[0]) : NULL;
    sh_dyn_name(F, lit);
    return sh_unknown_call(F, c, n, blk);
  }
  /* a C function the program binds (ffi_func, a package's native_func):
     it reads a String argument for the length of the call and keeps none */
  if (recv >= 0 && (nt_kind(nt, recv) == NK_ConstantReadNode || nt_kind(nt, recv) == NK_ConstantPathNode)) {
    const char *mod = nt_str(nt, recv, "name");
    if (mod && (ffi_find_func(c, mod, name) >= 0 || comp_native_find(c, mod, name) >= 0)) return -1;
  }

  /* a user method or a builtin */
  return sh_unknown_call(F, c, n, blk);
}

static int sh_val_compute(ShareFacts *F, Compiler *c, int n) {
  const NodeTable *nt = c->nt;
  switch (nt_kind(nt, n)) {
  case NK_LocalVariableReadNode:
    return sh_local_at(F, c, n);
  case NK_LocalVariableWriteNode: case NK_LocalVariableOrWriteNode:
  case NK_LocalVariableAndWriteNode: case NK_LocalVariableOperatorWriteNode: {
    int l = sh_local_at(F, c, n);
    if (l >= 0) F->own[l] |= SHE_WRITTEN;
    int v = sh_val(F, c, nt_ref(nt, n, "value"));
    if (nt_kind(nt, n) != NK_LocalVariableOperatorWriteNode) sh_union(F, l, v);
    return l;
  }
  case NK_InstanceVariableReadNode:
    return sh_ivar(F, c, sh_ivar_owner(c, n), nt_str(nt, n, "name"), n);
  case NK_InstanceVariableWriteNode: case NK_InstanceVariableOrWriteNode:
  case NK_InstanceVariableAndWriteNode: case NK_InstanceVariableOperatorWriteNode: {
    int l = sh_ivar(F, c, sh_ivar_owner(c, n), nt_str(nt, n, "name"), n);
    int v = sh_val(F, c, nt_ref(nt, n, "value"));
    if (nt_kind(nt, n) != NK_InstanceVariableOperatorWriteNode) sh_union(F, l, v);
    return l;
  }
  case NK_GlobalVariableReadNode:
    return sh_gvar(F, c, nt_str(nt, n, "name"), n);
  case NK_GlobalVariableWriteNode: case NK_GlobalVariableOrWriteNode:
  case NK_GlobalVariableAndWriteNode: case NK_GlobalVariableOperatorWriteNode: {
    int l = sh_gvar(F, c, nt_str(nt, n, "name"), n);
    int v = sh_val(F, c, nt_ref(nt, n, "value"));
    if (nt_kind(nt, n) != NK_GlobalVariableOperatorWriteNode) sh_union(F, l, v);
    return l;
  }
  case NK_ClassVariableReadNode:
    return c->ntype[n] == TY_UNKNOWN || sh_may_hold(c->ntype[n])
           ? sh_holder(F, SHK_CVAR, 0, -1, nt_str(nt, n, "name"), n) : -1;
  case NK_ClassVariableWriteNode: case NK_ClassVariableOrWriteNode:
  case NK_ClassVariableAndWriteNode: case NK_ClassVariableOperatorWriteNode: {
    int l = sh_holder(F, SHK_CVAR, 0, -1, nt_str(nt, n, "name"), n);
    int v = sh_val(F, c, nt_ref(nt, n, "value"));
    if (nt_kind(nt, n) != NK_ClassVariableOperatorWriteNode) sh_union(F, l, v);
    return l;
  }
  case NK_ConstantReadNode: case NK_ConstantPathNode:
    return sh_const_read(F, c, n);
  case NK_ConstantWriteNode: case NK_ConstantOrWriteNode: case NK_ConstantAndWriteNode: {
    int v = sh_val(F, c, nt_ref(nt, n, "value"));
    if (v < 0) return -1;
    int l = sh_holder(F, SHK_CONST, 0, -1, nt_str(nt, n, "name"), n);
    sh_union(F, l, v);
    return l;
  }
  case NK_ConstantPathWriteNode: {
    int t = nt_ref(nt, n, "target");
    int v = sh_val(F, c, nt_ref(nt, n, "value"));
    if (v < 0 || t < 0) return -1;
    int l = sh_holder(F, SHK_CONST, 0, -1, nt_str(nt, t, "name"), n);
    sh_union(F, l, v);
    return l;
  }
  case NK_ParenthesesNode:
    return sh_stmts_val(F, c, nt_ref(nt, n, "body"));
  case NK_StatementsNode:
    return sh_stmts_val(F, c, n);
  case NK_BeginNode: {
    int r = sh_stmts_val(F, c, nt_ref(nt, n, "statements"));
    for (int rc = nt_ref(nt, n, "rescue_clause"); rc >= 0; rc = nt_ref(nt, rc, "subsequent"))
      r = sh_join(F, r, sh_stmts_val(F, c, nt_ref(nt, rc, "statements")));
    int el = nt_ref(nt, n, "else_clause");
    if (el >= 0) r = sh_join(F, r, sh_stmts_val(F, c, nt_ref(nt, el, "statements")));
    return r;
  }
  case NK_IfNode:
    return sh_join(F, sh_stmts_val(F, c, nt_ref(nt, n, "statements")), sh_val(F, c, nt_ref(nt, n, "subsequent")));
  case NK_UnlessNode:
    return sh_join(F, sh_stmts_val(F, c, nt_ref(nt, n, "statements")), sh_val(F, c, nt_ref(nt, n, "else_clause")));
  case NK_ElseNode:
    return sh_stmts_val(F, c, nt_ref(nt, n, "statements"));
  case NK_CaseNode: case NK_CaseMatchNode: {
    int r = -1;
    int nw = 0; const int *ws = nt_arr(nt, n, "conditions", &nw);
    for (int i = 0; i < nw; i++) r = sh_join(F, r, sh_stmts_val(F, c, nt_ref(nt, ws[i], "statements")));
    return sh_join(F, r, sh_val(F, c, nt_ref(nt, n, "else_clause")));
  }
  case NK_AndNode:
    return sh_val(F, c, nt_ref(nt, n, "right"));
  case NK_OrNode:
    return sh_join(F, sh_val(F, c, nt_ref(nt, n, "left")), sh_val(F, c, nt_ref(nt, n, "right")));
  case NK_RescueModifierNode:
    return sh_join(F, sh_val(F, c, nt_ref(nt, n, "expression")), sh_val(F, c, nt_ref(nt, n, "rescue_expression")));
  case NK_ArrayNode: {
    int r = sh_new(F, SHK_VALUE);
    int en = 0; const int *el = nt_arr(nt, n, "elements", &en);
    for (int i = 0; i < en; i++) sh_union(F, sh_elem(F, r), sh_arg_val(F, c, el[i]));
    return r;
  }
  case NK_HashNode: case NK_KeywordHashNode: {
    int r = sh_new(F, SHK_VALUE);
    int en = 0; const int *el = nt_arr(nt, n, "elements", &en);
    for (int i = 0; i < en; i++) {
      /* a String key is dup'd and frozen as it is stored: only values */
      int v = nt_kind(nt, el[i]) == NK_AssocNode ? sh_val(F, c, nt_ref(nt, el[i], "value"))
                                                 : sh_arg_val(F, c, el[i]);
      sh_union(F, sh_elem(F, r), v);
    }
    return r;
  }
  case NK_RangeNode: {
    int l = sh_val(F, c, nt_ref(nt, n, "left")), rr = sh_val(F, c, nt_ref(nt, n, "right"));
    if (l < 0 && rr < 0) return -1;
    int r = sh_new(F, SHK_VALUE);
    sh_union(F, sh_elem(F, r), l);
    sh_union(F, sh_elem(F, r), rr);
    return r;
  }
  case NK_MultiWriteNode: {
    int value = nt_ref(nt, n, "value");
    int v = sh_val(F, c, value);
    int en = 0; const int *el = value >= 0 && nt_kind(nt, value) == NK_ArrayNode
                                ? nt_arr(nt, value, "elements", &en) : NULL;
    int plain = el != NULL && nt_ref(nt, n, "rest") < 0;
    for (int i = 0; plain && i < en; i++) if (nt_kind(nt, el[i]) == NK_SplatNode) plain = 0;
    int nl = 0; const int *lefts = nt_arr(nt, n, "lefts", &nl);
    int nr = 0; nt_arr(nt, n, "rights", &nr);
    if (plain && nr == 0) {
      /* `a, b = x, y`: each target takes its own value */
      for (int i = 0; i < nl; i++) {
        int src = i < en ? sh_val(F, c, el[i]) : -1;
        if (nt_kind(nt, lefts[i]) == NK_MultiTargetNode && i < en && nt_kind(nt, el[i]) == NK_ArrayNode)
          sh_targets_of(F, c, lefts[i], src);
        else sh_target(F, c, lefts[i], src);
      }
      return v;
    }
    /* any other value: a target may take it or one of its elements */
    int ev = sh_elem(F, v);
    for (int i = 0; i < nl; i++) { sh_target(F, c, lefts[i], ev); sh_target(F, c, lefts[i], v); }
    int nr2 = 0; const int *rs = nt_arr(nt, n, "rights", &nr2);
    for (int i = 0; i < nr2; i++) sh_target(F, c, rs[i], ev);
    int rest = nt_ref(nt, n, "rest");
    if (rest >= 0) sh_target(F, c, rest, v);
    return v;
  }
  case NK_IndexOperatorWriteNode: case NK_IndexOrWriteNode: case NK_IndexAndWriteNode: {
    int e = sh_elem(F, sh_val(F, c, nt_ref(nt, n, "receiver")));
    sh_union(F, e, sh_val(F, c, nt_ref(nt, n, "value")));
    return e;
  }
  case NK_OperatorWriteNode: case NK_CallOrWriteNode: case NK_CallAndWriteNode: {
    int v = sh_val(F, c, nt_ref(nt, n, "value"));
    const char *rn = nt_str(nt, n, "read_name");
    int writer = 0;
    int iv = rn ? sh_attr_ivars(F, c, rn, n, &writer) : -1;
    if (iv < 0) { sh_union(F, v, F->unknown); return F->unknown; }
    sh_union(F, iv, v);
    return iv;
  }
  case NK_ForNode:
    sh_target(F, c, nt_ref(nt, n, "index"), sh_elem(F, sh_val(F, c, nt_ref(nt, n, "collection"))));
    return -1;
  case NK_YieldNode: {
    int mi = sh_method_index(c, n);
    int y = mi >= 0 ? sh_scope_holder(F, SHK_YIELD, mi) : F->unknown;
    int vals[64];
    int nv = sh_args_vals(F, c, n, vals, 64);
    for (int i = 0; i < nv; i++) sh_union(F, y, vals[i]);
    return mi >= 0 ? sh_scope_holder(F, SHK_BLKRET, mi) : F->unknown;
  }
  case NK_ReturnNode: {
    int mi = sh_method_index(c, n);
    int vals[64];
    int nv = sh_args_vals(F, c, n, vals, 64);
    for (int i = 0; i < nv; i++) {
      sh_union(F, mi >= 0 ? sh_scope_holder(F, SHK_RET, mi) : -1, vals[i]);
      if (nv > 1 && mi >= 0) sh_union(F, sh_elem(F, sh_scope_holder(F, SHK_RET, mi)), vals[i]);
    }
    return -1;
  }
  case NK_BreakNode: case NK_NextNode: {
    int vals[64];
    int nv = sh_args_vals(F, c, n, vals, 64);
    for (int i = 0; i < nv; i++) sh_union(F, vals[i], F->unknown);
    return -1;
  }
  case NK_LambdaNode:
    sh_block_params(F, c, n, F->unknown, 1);
    sh_union(F, sh_block_val(F, c, n), F->unknown);
    return -1;
  case NK_CallNode:
    return sh_call(F, c, n);
  case NK_SuperNode: case NK_ForwardingSuperNode:
    return sh_unknown_call(F, c, n, nt_ref(nt, n, "block"));
  case NK_SelfNode: {
    Scope *s = comp_scope_of(c, n);
    int cid = s ? s->class_id : -1;
    return cid >= 0 && cid == comp_class_index(c, "String") ? F->unknown : -1;
  }
  default:
    return -1;
  }
}

static int sh_val(ShareFacts *F, Compiler *c, int n) {
  if (n < 0 || n >= F->nnodes) return -1;
  if (F->nval[n] != -2) return F->nval[n];
  F->nval[n] = -1;
  int v = sh_val_compute(F, c, n);
  /* a value whose type holds no String is none, whatever it flowed
     through (a write's target is still unified above) */
  if (v >= 0 && c->ntype[n] != TY_UNKNOWN && !sh_may_hold(c->ntype[n]) &&
      nt_kind(c->nt, n) != NK_StatementsNode && nt_kind(c->nt, n) != NK_ParenthesesNode)
    v = -1;
  F->nval[n] = v;
  return v;
}

/* ---- the build ---- */

static int sh_root(const ShareFacts *F, int x) {
  while (F->parent[x] != x) x = F->parent[x];
  return x;
}

/* How many holders of each class store a String. A variable, an ivar, a
   global, a class variable and a constant each count. An element slot
   counts only while its container can be reached again -- a container a
   holder keeps, or one UNKNOWN may keep: the elements of an Array literal
   handed to `p` die with the call, and are no second name. A class that is
   its own elements' class (a value that may be a container or one of its
   elements, unified as one) counts no element slot of its own either. */
static void sh_finalize(ShareFacts *F) {
  int n = F->n;
  unsigned char *anchored = calloc((size_t)(n > 0 ? n : 1), 1);
  F->hcount = calloc((size_t)(n > 0 ? n : 1), sizeof(int));
  for (int e = 0; e < n; e++)
    if (F->parent[e] == e)
      anchored[e] = F->nhold[e] - F->nelem[e] > 0 || (F->flags[e] & SHF_UNKNOWN);
  for (int changed = 1; changed; ) {
    changed = 0;
    for (int e = 0; e < n; e++) {
      if (F->kind[e] != SHK_ELEM || F->owner[e] < 0) continue;
      int o = sh_root(F, F->owner[e]), r = sh_root(F, e);
      if (anchored[o] && !anchored[r]) { anchored[r] = 1; changed = 1; }
    }
  }
  for (int e = 0; e < n; e++)
    if (F->parent[e] == e) F->hcount[e] = F->nhold[e] - F->nelem[e];
  for (int e = 0; e < n; e++) {
    if (F->kind[e] != SHK_ELEM || F->owner[e] < 0) continue;
    int o = sh_root(F, F->owner[e]), r = sh_root(F, e);
    if (anchored[o] && o != r) F->hcount[r]++;
  }
  free(anchored);
}

/* A value that is a frozen String (a literal, a freeze, a -@): nothing can
   change it in place, so a name holding only such values needs no handle. */
static int sh_frozen_value(Compiler *c, int v) {
  const NodeTable *nt = c->nt;
  if (v < 0) return 1;
  NodeKind k = nt_kind(nt, v);
  if (k == NK_StringNode) return 1;
  return c->ntype[v] != TY_UNKNOWN && !sh_may_hold(c->ntype[v]);
}

/* The constants some write gives a value that is no frozen String. */
static void sh_mutable_consts(ShareFacts *F, Compiler *c) {
  const NodeTable *nt = c->nt;
  static const NodeKind kinds[] = { NK_ConstantWriteNode, NK_ConstantOrWriteNode, NK_ConstantAndWriteNode,
                                    NK_ConstantPathWriteNode };
  for (unsigned i = 0; i < sizeof kinds / sizeof kinds[0]; i++)
    for (int w = comp_kind_first(c, kinds[i]); w >= 0; w = comp_kind_next(c, w)) {
      if (nt_kind(nt, w) != kinds[i] || sh_frozen_value(c, nt_ref(nt, w, "value"))) continue;
      int t = kinds[i] == NK_ConstantPathWriteNode ? nt_ref(nt, w, "target") : w;
      const char *nm = t >= 0 ? nt_str(nt, t, "name") : NULL;
      if (!nm) continue;
      if (F->nmconst >= F->cmconst) {
        F->cmconst = F->cmconst ? F->cmconst * 2 : 16;
        F->mconst = realloc(F->mconst, sizeof(char *) * (size_t)F->cmconst);
      }
      F->mconst[F->nmconst++] = nm;
    }
}

/* A constant read's holder: one some write makes mutable, or a container
   the program never writes (ARGV); a constant holding a frozen String is
   none. */
static int sh_const_read(ShareFacts *F, Compiler *c, int n) {
  const char *nm = nt_str(c->nt, n, "name");
  TyKind t = c->ntype[n];
  if (!nm || !sh_may_hold(t)) return -1;
  for (int i = 0; i < F->nmconst; i++)
    if (sp_streq(F->mconst[i], nm)) return sh_holder(F, SHK_CONST, 0, -1, nm, n);
  return t == TY_STRING || t == TY_STRBUF ? -1 : sh_holder(F, SHK_CONST, 0, -1, nm, n);
}

static void sh_free(ShareFacts *F) {
  if (!F) return;
  for (int i = 0; i < F->nh; i++) free((char *)F->h[i].name);
  free(F->parent); free(F->elem); free(F->nhold); free(F->nmem); free(F->nelem); free(F->hidx);
  free(F->owner); free(F->hcount); free(F->mconst);
  free(F->mut_n); free(F->mut_v);
  free(F->kind); free(F->flags); free(F->own);
  free(F->h); free(F->helem); free(F->bucket); free(F->hnext); free(F->nval);
  free(F->dyn); free(F->union_stack);
  free(F);
}

static ShareFacts *sh_build(Compiler *c, int closed) {
  const NodeTable *nt = c->nt;
  ShareFacts *F = calloc(1, sizeof *F);
  F->closed = closed;
  F->unknown = sh_new(F, SHK_UNKNOWN);
  F->flags[F->unknown] = SHF_UNKNOWN;
  F->elem[F->unknown] = F->unknown;
  F->nnodes = nt->count;
  F->nval = malloc(sizeof(int) * (size_t)(F->nnodes > 0 ? F->nnodes : 1));
  for (int i = 0; i < F->nnodes; i++) F->nval[i] = -2;
  sh_mutable_consts(F, c);
  for (int n = 0; n < F->nnodes; n++) sh_val(F, c, n);
  /* each method's value is its body's last, and its defaults bind its
     parameters */
  for (int mi = 0; mi < c->nscopes; mi++) {
    Scope *m = &c->scopes[mi];
    if (m->def_node < 0) continue;
    if (m->body >= 0) sh_union(F, sh_scope_holder(F, SHK_RET, mi), sh_stmts_val(F, c, m->body));
    for (int j = 0; j < m->nparams; j++) {
      if (!m->pdefault || m->pdefault[j] < 0 || !m->pnames[j]) continue;
      int p = sh_local_of(F, c, m, m->pnames[j], m->def_node);
      if (p >= 0) F->own[p] |= SHE_WRITTEN;
      sh_union(F, p, sh_val(F, c, m->pdefault[j]));
    }
  }
  /* what a Method, a `send` or define_method can reach is called with what
     the walk does not see; so is a method_missing */
  for (int mi = 0; mi < c->nscopes; mi++) {
    Scope *m = &c->scopes[mi];
    if (m->def_node < 0 || !m->name) continue;
    int reach = F->dyn_all || sp_streq(m->name, "method_missing");
    for (int k = 0; k < F->ndyn && !reach; k++) reach = sp_streq(F->dyn[k], m->name);
    if (!reach) continue;
    for (int j = 0; j < m->nparams; j++)
      sh_union(F, m->pnames[j] ? sh_local_of(F, c, m, m->pnames[j], m->def_node) : -1, F->unknown);
    sh_union(F, sh_scope_holder(F, SHK_RET, mi), F->unknown);
    if (m->yields) {
      sh_union(F, sh_scope_holder(F, SHK_YIELD, mi), F->unknown);
      sh_union(F, sh_scope_holder(F, SHK_BLKRET, mi), F->unknown);
    }
  }
  /* a Struct's members are read and written through `[]`, `to_a`, `each`
     and the rest, which the walk does not follow; every ivar when an ivar
     is read or written by a runtime name */
  for (int k = 0; k < c->nclasses; k++) {
    ClassInfo *ci = &c->classes[k];
    if (!ci->is_struct && !F->dyn_ivars) continue;
    for (int i = 0; i < ci->nivars; i++) sh_union(F, sh_ivar(F, c, k, ci->ivars[i], -1), F->unknown);
  }
  sh_finalize(F);
  return F;
}

void share_facts_build(Compiler *c) {
  share_facts_free(c);
  c->share = sh_build(c, 0);
}

void share_facts_free(Compiler *c) {
  sh_free(c->share);
  c->share = NULL;
}

/* the same facts with what the walk does not follow left out: the stats'
   count of holders shared only because of UNKNOWN */
ShareFacts *share_facts_build_closed(Compiler *c) { return sh_build(c, 1); }
void share_facts_drop(ShareFacts *F) { sh_free(F); }

int share_holder_count(const Compiler *c) { return c->share ? c->share->nh : 0; }
const ShareHolder *share_holder(const Compiler *c, int h) {
  return c->share && h >= 0 && h < c->share->nh ? &c->share->h[h] : NULL;
}

static int sh_lookup(const ShareFacts *F, int kind, int a, int b, const char *name) {
  if (!F || !F->bucket) return -1;
  unsigned hb = sh_key_hash(kind, a, name) & (unsigned)(F->nbucket - 1);
  for (int i = F->bucket[hb]; i >= 0; i = F->hnext[i]) {
    const ShareHolder *h = &F->h[i];
    if (h->kind != kind) continue;
    if (kind == SHK_LOCAL ? (h->scope == a && h->local == b) : (h->cid == a && sp_streq(h->name, name)))
      return i;
  }
  return -1;
}
int share_local_holder(const Compiler *c, int scope, int local) {
  return sh_lookup(c->share, SHK_LOCAL, scope, local, NULL);
}
int share_ivar_holder(const Compiler *c, int cid, const char *name) {
  return name ? sh_lookup(c->share, SHK_IVAR, cid, -1, name) : -1;
}

/* The holders of root r's class that store a String (sh_finalize). */
static int sh_class_holders(const ShareFacts *F, int r) {
  return F->hcount ? F->hcount[r] : F->nhold[r];
}

static int sh_root_of_holder(const ShareFacts *F, int h) {
  int x = F->helem[h];
  while (F->parent[x] != x) x = F->parent[x];
  return x;
}
int share_elem_holder_root(const Compiler *c, int h) {
  const ShareFacts *F = c->share;
  if (!F || h < 0 || h >= F->nh) return -1;
  return F->elem[sh_root_of_holder(F, h)];
}
unsigned share_class_flags(const Compiler *c, int h) {
  const ShareFacts *F = c->share;
  if (!F || h < 0 || h >= F->nh) return 0;
  return F->flags[sh_root_of_holder(F, h)];
}
int share_class_holders(const Compiler *c, int h) {
  const ShareFacts *F = c->share;
  if (!F || h < 0 || h >= F->nh) return 0;
  return sh_class_holders(F, sh_root_of_holder(F, h));
}
/* the facts of an element (a container's elements), not a holder */
unsigned share_elem_flags(const Compiler *c, int e) {
  const ShareFacts *F = c->share;
  if (!F || e < 0 || e >= F->n) return 0;
  while (F->parent[e] != e) e = F->parent[e];
  return F->flags[e];
}
int share_elem_holders(const Compiler *c, int e) {
  const ShareFacts *F = c->share;
  if (!F || e < 0 || e >= F->n) return 0;
  while (F->parent[e] != e) e = F->parent[e];
  return sh_class_holders(F, e);
}
int share_elem_holder(const Compiler *c, int h) { return share_elem_holder_root(c, h); }

/* Under SPINEL_SHARE_STATS, a holder of `closed` (a build without UNKNOWN)
   with the same key as holder h of c->share: its class's facts. */
int share_closed_shares(const ShareFacts *F, const ShareHolder *h) {
  if (!F || !h) return 0;
  int i = h->kind == SHK_LOCAL ? sh_lookup(F, SHK_LOCAL, h->scope, h->local, NULL)
        : h->kind == SHK_IVAR ? sh_lookup(F, SHK_IVAR, h->cid, -1, h->name) : -1;
  if (i < 0) return 0;
  int x = F->helem[i];
  while (F->parent[x] != x) x = F->parent[x];
  unsigned f = F->flags[x];
  return (f & SHF_MUT) && (sh_class_holders(F, x) >= 2 || (f & SHF_INDIRECT));
}

/* SPINEL_SHARE_STATS=3: each in-place mutation whose class is UNKNOWN's,
   which makes every String that meets what the walk does not follow a
   handle (#6765's never-mutated proof under dynamic calls) */
void share_dump_unknown_mutations(Compiler *c) {
  const ShareFacts *F = c->share;
  if (!F) return;
  int ru = sh_root(F, F->unknown);
  for (int i = 0; i < F->nmut; i++) {
    if (sh_root(F, F->mut_v[i]) != ru) continue;
    int n = F->mut_n[i];
    int recv = nt_ref(c->nt, n, "receiver");
    fprintf(stderr, "share-unknown-mut: line %d `%s` on %s (%s)\n", (int)nt_int(c->nt, n, "node_line", 0),
            nt_str(c->nt, n, "name") ? nt_str(c->nt, n, "name") : "?",
            recv >= 0 ? nt_type(c->nt, recv) : "-", recv >= 0 ? ty_name(c->ntype[recv]) : "-");
  }
}
