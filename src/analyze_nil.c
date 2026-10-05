/* analyze_nil.c -- whether an object-typed value may be nil (#7444).

   One fact, decided once by the analysis: for every node, and for every
   slot a value is read back from (a local, a parameter, a block parameter,
   a global, a constant, an ivar, a method's value), whether the value may
   be nil. Today the question is asked again where each answer is needed --
   codegen's nil receiver guards (local_obj_nil_written, nil_value_node,
   method_ret_nilable), the value-type selection's nil witness, parameter
   tracking's obj_nilable -- and each asks it about the shapes it knows.
   Step 1 computes the fact and changes nothing that reads those answers:
   --nil-check holds it against them (nil_check_report, codegen_call.c, and
   vt_nil_witness_check, analyze.c).

   The fact is a may-be-nil over-approximation. Where the analysis cannot
   see what reaches a slot it answers "may be nil": an object a builtin call
   it does not model answers, a parameter a call it cannot see binds (a
   method named in a send or a method(:m), a method the runtime calls back),
   a block a proc or a define_method takes, a splat's element, a pattern's
   binding, a class-level ivar. Two shapes are taken as not nil without
   proof, listed here so a later step can model them: an element a builtin
   iteration binds to a block parameter (`boxes.each { |b| }` over an Array
   that holds nil), and a container call other than the element reads and
   picks that can miss (an Array's or a Hash's own methods).

   Flow: the slots are flow-insensitive (a slot one write leaves nil may be
   nil at every read), except that a read of a local inside a truthiness
   guard of it (`if b`, `b && b.v`, `return unless b`, `unless b.nil?`) is
   not nil when nothing in the guarded region writes it. A read the
   definite-assignment walk (du_read_maybe_unset) finds can run before any
   write makes its slot may-be-nil, as maybe_unset does for an Integer.

   The slots, the method values and the parameters a call binds feed one
   another, so they are settled by a fixpoint: every round recomputes the
   node facts from the slots and only ever sets a slot's flag, so the rounds
   are bounded by the number of flags.

   Each may-be-nil answer carries where its nil comes from (NFW_*, the first
   source found), which --nil-check reports beside a disagreement. */

#include "analyze_internal.h"
#include "call_plan.h"

/* ---- (class, ivar) and per-name side tables ---- */

typedef struct { int cls; const char *name; unsigned char wr, init, val; int val_round; } NFIvar;
/* a guarded region's writes of a name, memoized: a long branch read many
   times is scanned once per name */
typedef struct { int region; const char *name; unsigned char w; } NFRegion;

typedef struct {
  Compiler *c;
  const NodeTable *nt;
  int *par;               /* du_parent_map */
  DUPos dp;
  unsigned char *memo;    /* per node, this round: nf_code(), NF_BUSY while computed */
  int *def_mi;            /* DefNode id -> its method scope, or -1 */
  NFIvar *iv; int iv_cap, iv_n;
  NFRegion *rg; int rg_cap, rg_n;
  int guarded;            /* the read just computed is not nil by a guard */
  int *pl_mi;             /* per call node: its plan's method (-2: not asked) */
  short *pl_owner;
  unsigned char *pl_disp;
  int *yield_nil;         /* per method scope: a value its yields may answer is nil */
  int *byname; int nbyname; /* the instance methods, sorted by name */
  int *kid_head, *kid_next, *kid_to; /* per class: the classes right below it
                             (subclasses, and includers of a module) */
  int *dfs, *seen, stamp; /* nf_ivar's walk: its stack, and the classes it met */
  int round;
  int changed;
  int all_ivars_nil;      /* an instance_variable_set the program makes */
  const char **dyn; int ndyn, cdyn; /* method names a send or a method(:m) reaches */
} NF;

/* the (class, name) keys of the slots the side table holds besides an
   instance's ivars: a class variable by name, a top-level ivar */
enum { NF_CVAR = -2, NF_TOP_IVAR = -3 };

static unsigned nf_ivar_hash(int cls, const char *name) {
  return sp_strhash(name) * 31u + (unsigned)(cls + 1);
}

/* The (class, ivar) entry, made on first need. */
static NFIvar *nf_ivar_slot(NF *f, int cls, const char *name) {
  if (f->iv_n * 2 >= f->iv_cap) {
    int ncap = f->iv_cap ? f->iv_cap * 2 : 256;
    NFIvar *nv = calloc((size_t)ncap, sizeof *nv);
    if (!nv) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
    for (int k = 0; k < f->iv_cap; k++) {
      if (!f->iv[k].name) continue;
      unsigned j = nf_ivar_hash(f->iv[k].cls, f->iv[k].name) & (unsigned)(ncap - 1);
      while (nv[j].name) j = (j + 1) & (unsigned)(ncap - 1);
      nv[j] = f->iv[k];
    }
    free(f->iv); f->iv = nv; f->iv_cap = ncap;
  }
  unsigned j = nf_ivar_hash(cls, name) & (unsigned)(f->iv_cap - 1);
  while (f->iv[j].name) {
    if (f->iv[j].cls == cls && sp_streq(f->iv[j].name, name)) return &f->iv[j];
    j = (j + 1) & (unsigned)(f->iv_cap - 1);
  }
  f->iv[j].cls = cls; f->iv[j].name = name; f->iv[j].wr = 0; f->iv[j].init = 0;
  f->iv[j].val = 0; f->iv[j].val_round = -1;
  f->iv_n++;
  return &f->iv[j];
}

/* A slot's flag holds the source of its nil (NFW_*), 0 when it cannot be
   nil: set it for a nil from source `why` (none when 0). */
static void nf_set(NF *f, int *flag, int why) {
  if (!why || *flag) return;
  *flag = why;
  f->changed = 1;
}
static int nf_slot_why(NF *f, const int *flag) {
  (void)f;
  return *flag;
}

static int nf_unparen(const NodeTable *nt, int v) {
  while (v >= 0 && nt_kind(nt, v) == NK_ParenthesesNode) {
    int b = nt_ref(nt, v, "body");
    int n = 0; const int *bd = b >= 0 && nt_kind(nt, b) == NK_StatementsNode ? nt_arr(nt, b, "body", &n) : NULL;
    if (b >= 0 && nt_kind(nt, b) != NK_StatementsNode) { v = b; continue; }
    if (n != 1) break;
    v = bd[0];
  }
  return v;
}

/* Does class y's chain reach class or module x (itself, an ancestor, or a
   module one of them includes)? */
static int nf_class_reaches(Compiler *c, int y, int x) {
  for (int k = y, d = 0; k >= 0 && d < 256; k = c->classes[k].parent, d++) {
    if (k == x) return 1;
    for (int m = 0; m < c->classes[k].nincluded_mods; m++)
      if (c->classes[k].included_mods[m] == x) return 1;
  }
  return 0;
}

static int nf_expr(NF *f, int v);

/* the statement list of a program, directly under its ProgramNode */
static int nf_is_program_list(NF *f, int n) {
  int p = n >= 0 ? f->par[n] : -1;
  const char *ty = p >= 0 ? nt_type(f->nt, p) : NULL;
  return nt_kind(f->nt, n) == NK_StatementsNode && ty && sp_streq(ty, "ProgramNode");
}

/* Does a statement of the program's own list, ahead of the one holding
   read rd, write the name (a write of kind wk)? A top-level read outside a
   block runs after it; anything else cannot be shown to. */
static int nf_written_before(NF *f, int rd, NodeKind wk, const char *name) {
  const NodeTable *nt = f->nt;
  if (comp_scope_of(f->c, rd) != &f->c->scopes[0]) return 0;
  int top = rd;
  for (; top >= 0 && f->par[top] >= 0 && !nf_is_program_list(f, f->par[top]); top = f->par[top]) {
    NodeKind k = nt_kind(nt, f->par[top]);
    if (k == NK_BlockNode || k == NK_LambdaNode || k == NK_DefNode) return 0;
  }
  if (top < 0 || f->par[top] < 0) return 0;
  int bn = 0; const int *b = nt_arr(nt, f->par[top], "body", &bn);
  for (int i = 0; i < bn && b[i] != top; i++) {
    int w = nf_unparen(nt, b[i]);
    const char *wn = nt_kind(nt, w) == wk ? nt_str(nt, w, "name") : NULL;
    if (wn && sp_streq(wn, name)) return 1;
  }
  return 0;
}

/* The user method call node id reaches (cplan_user_fresh), asked once: the
   plan reads the settled types and tables, which the rounds do not change */
static int nf_plan(NF *f, int id, int *owner, int *dispatch) {
  if (f->pl_mi[id] == -2) {
    const CallPlan *p = cplan_user_fresh(f->c, id);
    f->pl_mi[id] = p->dispatch == CP_REFUSE ? -1 : p->mi;
    f->pl_owner[id] = p->owner_ci;
    f->pl_disp[id] = p->dispatch;
  }
  if (owner) *owner = f->pl_owner[id];
  if (dispatch) *dispatch = f->pl_disp[id];
  return f->pl_mi[id];
}

/* ---- an ivar initialize sets on every path ---- */

/* Does subtree n hold a `return` of the method it runs in (not of a def or
   a lambda inside it)? */
static int nf_has_return(const NodeTable *nt, int n, int depth) {
  if (n < 0 || depth > 512) return 0;
  NodeKind k = nt_kind(nt, n);
  if (k == NK_ReturnNode) return 1;
  if (k == NK_DefNode || k == NK_LambdaNode || k == NK_ClassNode || k == NK_ModuleNode) return 0;
  for (int i = 0; i < nt_num_refs(nt, n); i++)
    if (nf_has_return(nt, nt_ref_at(nt, n, i), depth + 1)) return 1;
  for (int i = 0; i < nt_num_arrs(nt, n); i++) {
    int an = 0; const int *av = nt_arr_at(nt, n, i, &an);
    for (int j = 0; j < an; j++) if (nf_has_return(nt, av[j], depth + 1)) return 1;
  }
  return 0;
}

static int nf_ivar_def(NF *f, int n, const char *ivn, int mi, int depth);

/* the method body or list st writes ivar ivn on every path that ends it
   normally: a statement that writes it, before any that can return */
static int nf_ivar_def_list(NF *f, int st, const char *ivn, int mi, int depth) {
  const NodeTable *nt = f->nt;
  if (st < 0) return 0;
  if (nt_kind(nt, st) != NK_StatementsNode) return nf_ivar_def(f, st, ivn, mi, depth);
  int n = 0; const int *b = nt_arr(nt, st, "body", &n);
  for (int i = 0; i < n; i++) {
    if (nf_ivar_def(f, b[i], ivn, mi, depth)) return 1;
    if (nf_has_return(nt, b[i], 0)) return 0;
  }
  return 0;
}

/* A raise ends no path normally: it writes every ivar. */
static int nf_raises(const NodeTable *nt, int n) {
  n = nf_unparen(nt, n);
  if (n >= 0 && nt_kind(nt, n) == NK_StatementsNode) {
    int bn = 0; const int *b = nt_arr(nt, n, "body", &bn);
    return bn > 0 && nf_raises(nt, b[bn - 1]);
  }
  const char *cn = n >= 0 && nt_kind(nt, n) == NK_CallNode && nt_ref(nt, n, "receiver") < 0 ? nt_str(nt, n, "name") : NULL;
  return cn && (sp_streq(cn, "raise") || sp_streq(cn, "fail"));
}

/* Does evaluating n, in method mi, write ivar ivn of self on every path
   that completes it? It follows `super` into the parent's method and a
   call of one of self's own methods (a `reset`, a `setup`) into its body. */
static int nf_ivar_def(NF *f, int n, const char *ivn, int mi, int depth) {
  Compiler *c = f->c;
  const NodeTable *nt = f->nt;
  if (n < 0 || depth > 8) return 0;
  switch (nt_kind(nt, n)) {
  case NK_InstanceVariableWriteNode: case NK_InstanceVariableOrWriteNode: {
    const char *wn = nt_str(nt, n, "name");
    if (wn && sp_streq(wn, ivn)) return 1;
    return nf_ivar_def(f, nt_ref(nt, n, "value"), ivn, mi, depth);
  }
  case NK_LocalVariableWriteNode:
    return nf_ivar_def(f, nt_ref(nt, n, "value"), ivn, mi, depth);
  case NK_MultiWriteNode: {
    int ln = 0; const int *l = nt_arr(nt, n, "lefts", &ln);
    for (int i = 0; i < ln; i++) {
      const char *wn = nt_kind(nt, l[i]) == NK_InstanceVariableTargetNode ? nt_str(nt, l[i], "name") : NULL;
      if (wn && sp_streq(wn, ivn)) return 1;
    }
    return 0;
  }
  case NK_StatementsNode: return nf_ivar_def_list(f, n, ivn, mi, depth);
  case NK_ParenthesesNode: return nf_ivar_def_list(f, nt_ref(nt, n, "body"), ivn, mi, depth);
  case NK_ElseNode: return nf_ivar_def_list(f, nt_ref(nt, n, "statements"), ivn, mi, depth);
  case NK_BeginNode: {
    int en = nt_ref(nt, n, "ensure_clause");
    if (en >= 0 && nf_ivar_def_list(f, nt_ref(nt, en, "statements"), ivn, mi, depth)) return 1;
    if (nt_ref(nt, n, "rescue_clause") >= 0) return 0;
    return nf_ivar_def_list(f, nt_ref(nt, n, "statements"), ivn, mi, depth);
  }
  case NK_IfNode: case NK_UnlessNode: {
    if (nf_ivar_def(f, nt_ref(nt, n, "predicate"), ivn, mi, depth)) return 1;
    int st = nt_ref(nt, n, "statements");
    int els = nt_ref(nt, n, nt_kind(nt, n) == NK_IfNode ? "subsequent" : "else_clause");
    if (st < 0 || els < 0) return 0;
    return (nf_raises(nt, st) || nf_ivar_def_list(f, st, ivn, mi, depth)) &&
           (nf_raises(nt, els) || nf_ivar_def(f, els, ivn, mi, depth));
  }
  case NK_CaseNode: {
    int els = nt_ref(nt, n, "else_clause");
    if (els < 0 || !(nf_raises(nt, nt_ref(nt, els, "statements")) || nf_ivar_def(f, els, ivn, mi, depth))) return 0;
    int wn = 0; const int *w = nt_arr(nt, n, "conditions", &wn);
    for (int i = 0; i < wn; i++) {
      int ws = nt_ref(nt, w[i], "statements");
      if (!nf_raises(nt, ws) && !nf_ivar_def_list(f, ws, ivn, mi, depth)) return 0;
    }
    return 1;
  }
  case NK_SuperNode: case NK_ForwardingSuperNode: {
    int pmi = nf_plan(f, n, NULL, NULL);
    return pmi >= 0 && pmi != mi && c->scopes[pmi].body >= 0 &&
           nf_ivar_def_list(f, c->scopes[pmi].body, ivn, pmi, depth + 1);
  }
  case NK_CallNode: {
    int r = nt_ref(nt, n, "receiver");
    const char *cn = nt_str(nt, n, "name");
    if (!cn || (r >= 0 && nt_kind(nt, r) != NK_SelfNode)) return 0;
    /* `self.x = v` through an attr writer of x */
    size_t cl = strlen(cn);
    if (cl > 1 && cn[cl - 1] == '=' && !strncmp(cn, ivn + 1, cl - 1) && ivn[cl] == 0 &&
        c->scopes[mi].class_id >= 0 && comp_writer_in_chain(c, c->scopes[mi].class_id, ivn + 1, NULL))
      return 1;
    /* one of self's own methods, called with no block */
    int tmi = nf_plan(f, n, NULL, NULL);
    if (tmi < 0 || tmi == mi || nt_ref(nt, n, "block") >= 0 || c->scopes[tmi].body < 0) return 0;
    return nf_ivar_def_list(f, c->scopes[tmi].body, ivn, tmi, depth + 1);
  }
  default: return 0;
  }
}

/* Does `new` on class k leave ivar ivn set: k's initialize writes it on
   every path? */
static int nf_init_sets(NF *f, int k, const char *ivn) {
  int mi = comp_method_in_chain(f->c, k, "initialize", NULL);
  if (mi < 0 || f->c->scopes[mi].body < 0) return 0;
  return nf_ivar_def_list(f, f->c->scopes[mi].body, ivn, mi, 0);
}

/* A write of ivar `ivn` into an instance of class k may store nil: a write
   in a method of k, of an ancestor, or of a module they include. */
static int nf_chain_writes(NF *f, int k, const char *ivn) {
  Compiler *c = f->c;
  for (int d = 0; k >= 0 && d < 256; k = c->classes[k].parent, d++) {
    NFIvar *e = nf_ivar_slot(f, k, ivn);
    if (e->wr) return e->wr;
    for (int m = 0; m < c->classes[k].nincluded_mods; m++)
      if ((e = nf_ivar_slot(f, c->classes[k].included_mods[m], ivn))->wr) return e->wr;
  }
  return NFW_NONE;
}

/* The ivar `ivn` read in a method of class cls, whose self is an instance
   of cls or of a class below it (or including it, for a module): nil until
   a write, unless that class's initialize writes it first; or a write the
   instance's chain makes stores a value that may be nil. */
static int nf_ivar(NF *f, int cls, const char *ivn) {
  Compiler *c = f->c;
  if (!ivn || cls < 0 || cls >= c->nclasses) return NFW_IVAR;
  if (f->all_ivars_nil) return NFW_OPAQUE;
  NFIvar *e = nf_ivar_slot(f, cls, ivn);
  if (e->val_round == f->round) return e->val;
  /* every class whose instances run cls's methods: cls, its subclasses,
     the classes including it, walked down the class tree */
  int r = 0, sp = 0;
  f->stamp++;
  f->dfs[sp++] = cls;
  f->seen[cls] = f->stamp;
  while (sp > 0 && !r) {
    int k = f->dfs[--sp];
    for (int ed = f->kid_head[k]; ed >= 0; ed = f->kid_next[ed]) {
      int kid = f->kid_to[ed];
      if (f->seen[kid] != f->stamp) { f->seen[kid] = f->stamp; f->dfs[sp++] = kid; }
    }
    if (c->classes[k].is_struct) { r = NFW_OPAQUE; break; }   /* a member `new` was not handed */
    NFIvar *ek = nf_ivar_slot(f, k, ivn);
    if (!ek->init) ek->init = nf_init_sets(f, k, ivn) ? 2 : 1;
    ek = nf_ivar_slot(f, k, ivn);
    r = ek->init == 1 ? NFW_IVAR : nf_chain_writes(f, k, ivn);
  }
  /* the slot table may have moved under e */
  e = nf_ivar_slot(f, cls, ivn);
  e->val = (unsigned char)r; e->val_round = f->round;
  return r;
}

/* ---- the guard a read of a local sits under ---- */

static int nf_is_read_of(const NodeTable *nt, int n, const char *nm) {
  n = nf_unparen(nt, n);
  if (n < 0) return 0;
  NodeKind k = nt_kind(nt, n);
  if (k != NK_LocalVariableReadNode && k != NK_LocalVariableWriteNode) return 0;
  const char *rn = nt_str(nt, n, "name");
  return rn && sp_streq(rn, nm);
}
static int nf_falsy_implies(const NodeTable *nt, int p, const char *nm);
/* p truthy => local nm is not nil */
static int nf_truthy_implies(const NodeTable *nt, int p, const char *nm) {
  p = nf_unparen(nt, p);
  if (p < 0) return 0;
  if (nf_is_read_of(nt, p, nm)) return 1;
  NodeKind k = nt_kind(nt, p);
  if (k == NK_AndNode)
    return nf_truthy_implies(nt, nt_ref(nt, p, "left"), nm) || nf_truthy_implies(nt, nt_ref(nt, p, "right"), nm);
  if (k == NK_CallNode) {
    const char *cn = nt_str(nt, p, "name");
    int r = nt_ref(nt, p, "receiver");
    if (!cn || r < 0) return 0;
    if (sp_streq(cn, "!")) return nf_falsy_implies(nt, r, nm);
    if (!nf_is_read_of(nt, r, nm) || nt_kind(nt, nf_unparen(nt, r)) != NK_LocalVariableReadNode) return 0;
    if (sp_streq(cn, "is_a?") || sp_streq(cn, "kind_of?") || sp_streq(cn, "instance_of?")) return 1;
    if (sp_streq(cn, "!=")) {
      int a = nt_ref(nt, p, "arguments"), an = 0;
      const int *av = a >= 0 ? nt_arr(nt, a, "arguments", &an) : NULL;
      return an == 1 && nt_kind(nt, av[0]) == NK_NilNode;
    }
  }
  return 0;
}
/* p falsy => local nm is not nil */
static int nf_falsy_implies(const NodeTable *nt, int p, const char *nm) {
  p = nf_unparen(nt, p);
  if (p < 0) return 0;
  NodeKind k = nt_kind(nt, p);
  if (k == NK_OrNode)
    return nf_falsy_implies(nt, nt_ref(nt, p, "left"), nm) || nf_falsy_implies(nt, nt_ref(nt, p, "right"), nm);
  if (k == NK_CallNode) {
    const char *cn = nt_str(nt, p, "name");
    int r = nt_ref(nt, p, "receiver");
    if (!cn || r < 0) return 0;
    if (sp_streq(cn, "!")) return nf_truthy_implies(nt, r, nm);
    if (!nf_is_read_of(nt, r, nm) || nt_kind(nt, nf_unparen(nt, r)) != NK_LocalVariableReadNode) return 0;
    if (sp_streq(cn, "nil?")) return 1;
    if (sp_streq(cn, "==")) {
      int a = nt_ref(nt, p, "arguments"), an = 0;
      const int *av = a >= 0 ? nt_arr(nt, a, "arguments", &an) : NULL;
      return an == 1 && nt_kind(nt, av[0]) == NK_NilNode;
    }
  }
  return 0;
}
/* Does subtree n write local nm (any write, in any nested block)? */
static int nf_writes_local(const NodeTable *nt, int n, const char *nm, int depth) {
  if (n < 0 || depth > 512) return 0;
  switch (nt_kind(nt, n)) {
  case NK_LocalVariableWriteNode: case NK_LocalVariableOrWriteNode:
  case NK_LocalVariableAndWriteNode: case NK_LocalVariableOperatorWriteNode:
  case NK_LocalVariableTargetNode: {
    const char *wn = nt_str(nt, n, "name");
    if (wn && sp_streq(wn, nm)) return 1;
    break;
  }
  case NK_DefNode: return 0;
  default: break;
  }
  for (int i = 0; i < nt_num_refs(nt, n); i++)
    if (nf_writes_local(nt, nt_ref_at(nt, n, i), nm, depth + 1)) return 1;
  for (int i = 0; i < nt_num_arrs(nt, n); i++) {
    int an = 0; const int *av = nt_arr_at(nt, n, i, &an);
    for (int k = 0; k < an; k++) if (nf_writes_local(nt, av[k], nm, depth + 1)) return 1;
  }
  return 0;
}
static int nf_region_writes(NF *f, int region, const char *nm) {
  if (f->rg_n * 2 >= f->rg_cap) {
    int ncap = f->rg_cap ? f->rg_cap * 2 : 256;
    NFRegion *nv = calloc((size_t)ncap, sizeof *nv);
    if (!nv) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
    for (int k = 0; k < f->rg_cap; k++) {
      if (!f->rg[k].name) continue;
      unsigned j = (sp_strhash(f->rg[k].name) * 31u + (unsigned)f->rg[k].region) & (unsigned)(ncap - 1);
      while (nv[j].name) j = (j + 1) & (unsigned)(ncap - 1);
      nv[j] = f->rg[k];
    }
    free(f->rg); f->rg = nv; f->rg_cap = ncap;
  }
  unsigned j = (sp_strhash(nm) * 31u + (unsigned)region) & (unsigned)(f->rg_cap - 1);
  while (f->rg[j].name) {
    if (f->rg[j].region == region && sp_streq(f->rg[j].name, nm)) return f->rg[j].w;
    j = (j + 1) & (unsigned)(f->rg_cap - 1);
  }
  int w = nf_writes_local(f->nt, region, nm, 0);
  f->rg[j].region = region; f->rg[j].name = nm; f->rg[j].w = (unsigned char)w;
  f->rg_n++;
  return w;
}
/* A statement that leaves the list: `return`, `next`, `break`, `raise` */
static int nf_is_jump(const NodeTable *nt, int s) {
  s = nf_unparen(nt, s);
  if (s < 0) return 0;
  if (nt_kind(nt, s) == NK_StatementsNode) {
    int n = 0; const int *b = nt_arr(nt, s, "body", &n);
    return n > 0 && nf_is_jump(nt, b[n - 1]);
  }
  NodeKind k = nt_kind(nt, s);
  if (k == NK_ReturnNode || k == NK_NextNode || k == NK_BreakNode) return 1;
  if (k == NK_CallNode && nt_ref(nt, s, "receiver") < 0) {
    const char *cn = nt_str(nt, s, "name");
    return cn && (sp_streq(cn, "raise") || sp_streq(cn, "fail") || sp_streq(cn, "exit") ||
                  sp_streq(cn, "abort") || sp_streq(cn, "throw"));
  }
  return 0;
}
/* `return unless nm` / `raise ... if nm.nil?`: after it, nm is not nil */
static int nf_exit_guard(const NodeTable *nt, int s, const char *nm) {
  s = nf_unparen(nt, s);
  if (s < 0) return 0;
  NodeKind k = nt_kind(nt, s);
  if (k == NK_OrNode)   /* `nm or return` */
    return nf_is_jump(nt, nt_ref(nt, s, "right")) && nf_truthy_implies(nt, nt_ref(nt, s, "left"), nm);
  if (k != NK_IfNode && k != NK_UnlessNode) return 0;
  int els = nt_ref(nt, s, k == NK_IfNode ? "subsequent" : "else_clause");
  if (els >= 0 || !nf_is_jump(nt, nt_ref(nt, s, "statements"))) return 0;
  int p = nt_ref(nt, s, "predicate");
  return k == NK_IfNode ? nf_falsy_implies(nt, p, nm) : nf_truthy_implies(nt, p, nm);
}

/* Is the read rd of local nm (slot lv) under a guard that proves it is not
   nil, with no write of nm between the guard and the read? Walks out to the
   method, a block or a lambda, which may run after the slot changed. */
static int nf_local_guarded(NF *f, int rd, const char *nm, const LocalVar *lv) {
  const NodeTable *nt = f->nt;
  if (!f->par || lv->proc_rebinds) return 0;
  int cur = rd;
  for (int guard = 0; guard < 4096; guard++) {
    int p = f->par[cur];
    if (p < 0) return 0;
    NodeKind pk = nt_kind(nt, p);
    if (pk == NK_DefNode || pk == NK_LambdaNode || pk == NK_BlockNode || pk == NK_ClassNode ||
        pk == NK_ModuleNode || pk == NK_SingletonClassNode) return 0;
    int region = -1;
    if ((pk == NK_IfNode || pk == NK_UnlessNode) && cur != nt_ref(nt, p, "predicate")) {
      int pr = nt_ref(nt, p, "predicate");
      int in_then = cur == nt_ref(nt, p, "statements");
      int then_ok = pk == NK_IfNode ? nf_truthy_implies(nt, pr, nm) : nf_falsy_implies(nt, pr, nm);
      int else_ok = pk == NK_IfNode ? nf_falsy_implies(nt, pr, nm) : nf_truthy_implies(nt, pr, nm);
      if (in_then ? then_ok : else_ok) region = cur;
    }
    else if (pk == NK_AndNode && cur == nt_ref(nt, p, "right") &&
             nf_truthy_implies(nt, nt_ref(nt, p, "left"), nm)) region = cur;
    else if (pk == NK_OrNode && cur == nt_ref(nt, p, "right") &&
             nf_falsy_implies(nt, nt_ref(nt, p, "left"), nm)) region = cur;
    else if (pk == NK_WhileNode && cur == nt_ref(nt, p, "statements") &&
             nf_truthy_implies(nt, nt_ref(nt, p, "predicate"), nm)) region = cur;
    if (region >= 0) {
      if (!nf_region_writes(f, region, nm)) return 1;
    }
    else if (pk == NK_StatementsNode) {
      int bn = 0; const int *b = nt_arr(nt, p, "body", &bn);
      int at = -1;
      for (int i = 0; i < bn; i++) if (b[i] == cur) { at = i; break; }
      for (int i = at - 1; i >= 0; i--) {
        if (nf_exit_guard(nt, b[i], nm)) {
          int clean = 1;
          for (int j = i + 1; j <= at && clean; j++) clean = !nf_region_writes(f, b[j], nm);
          if (clean) return 1;
          break;
        }
        if (nf_region_writes(f, b[i], nm)) break;
      }
    }
    cur = p;
  }
  return 0;
}

/* ---- the node fact ---- */

/* the value of a list: its last statement, nil when it is empty */
static int nf_list(NF *f, int st) {
  if (st < 0) return NFW_NIL;
  if (nt_kind(f->nt, st) != NK_StatementsNode) return nf_expr(f, st);
  int n = 0; const int *b = nt_arr(f->nt, st, "body", &n);
  return n == 0 ? NFW_NIL : nf_expr(f, b[n - 1]);
}
/* the first source of two */
static int nf_or(int a, int b) { return a ? a : b; }

static Compiler *nf_sort_c;
static int nf_byname_cmp(const void *a, const void *b) {
  int x = *(const int *)a, y = *(const int *)b;
  int r = strcmp(nf_sort_c->scopes[x].name, nf_sort_c->scopes[y].name);
  return r ? r : x - y;
}
/* the first entry of the name index named `name`, or nbyname */
static int nf_byname_first(NF *f, const char *name) {
  int lo = 0, hi = f->nbyname;
  while (lo < hi) {
    int mid = lo + (hi - lo) / 2;
    if (strcmp(f->c->scopes[f->byname[mid]].name, name) < 0) lo = mid + 1;
    else hi = mid;
  }
  return lo;
}

/* the value of a user method mi a call reaches, and of every override a
   switch on the receiver's class may take instead */
static int nf_method_value(NF *f, int mi, int owner, int dispatch, const char *name) {
  Compiler *c = f->c;
  if (mi < 0 || mi >= c->nscopes) return NFW_OPAQUE;
  if (c->scopes[mi].ret_obj_may_nil) return nf_slot_why(f, &c->scopes[mi].ret_obj_may_nil);
  if ((dispatch == CP_SWITCH || dispatch == CP_PER_ARM) && name && owner >= 0)
    for (int j = nf_byname_first(f, name); j < f->nbyname; j++) {
      Scope *s = &c->scopes[f->byname[j]];
      if (!sp_streq(s->name, name)) break;
      if (nf_class_reaches(c, s->class_id, owner) && s->ret_obj_may_nil) return nf_slot_why(f, &s->ret_obj_may_nil);
    }
  return NFW_NONE;
}

/* the receiver's class an element read misses on (Array, Hash) */
static int nf_container(TyKind t) {
  return ty_is_array(t) || ty_is_obj_array(t) || ty_is_hash(t) || t == TY_POLY;
}

static int nf_call(NF *f, int v) {
  Compiler *c = f->c;
  const NodeTable *nt = f->nt;
  const char *nm = nt_str(nt, v, "name");
  const char *op = nt_str(nt, v, "call_operator");
  /* only an object's nil is tracked: the slots it can reach are objects */
  if (!ty_is_object(c->ntype[v])) return NFW_NONE;
  if (op && sp_streq(op, "&.")) return NFW_SAFE_NAV;
  if (!nm) return NFW_OPAQUE;
  int r = nt_ref(nt, v, "receiver");
  int a = nt_ref(nt, v, "arguments"), an = 0;
  const int *av = a >= 0 ? nt_arr(nt, a, "arguments", &an) : NULL;
  int owner = -1, dispatch = CP_NONE;
  int pmi = nf_plan(f, v, &owner, &dispatch);
  if (pmi >= 0) return nf_method_value(f, pmi, owner, dispatch, nm);
  TyKind rt = r >= 0 ? c->ntype[r] : TY_UNKNOWN;
  if (sp_streq(nm, "new") || sp_streq(nm, "allocate")) return NFW_NONE;
  /* an attr reader: its ivar */
  if (ty_is_object(rt) || r < 0) {
    int cls = ty_is_object(rt) ? ty_object_class(rt) : -1;
    if (r < 0) {
      Scope *s = comp_scope_of(c, v);
      cls = s && !s->is_cmethod ? s->class_id : -1;
    }
    if (cls >= 0 && comp_reader_in_chain(c, cls, nm, NULL)) {
      char ivn[256];
      snprintf(ivn, sizeof ivn, "@%s", nm);
      return nf_ivar(f, cls, ivn);
    }
  }
  /* the receiver itself */
  if (r >= 0 && (sp_streq(nm, "itself") || sp_streq(nm, "tap") || sp_streq(nm, "dup") ||
                 sp_streq(nm, "clone") || sp_streq(nm, "freeze")))
    return nf_expr(f, r);
  /* an element read that can miss, a pick that finds nothing */
  if (r >= 0 && nf_container(rt)) {
    static const char *const picks[] = { "find", "detect", "first", "last", "min", "max", "min_by",
      "max_by", "sample", "shift", "pop", "[]", "at", "dig", "delete", "delete_at", "slice",
      "slice!", "inject", "reduce", "sum", "find_index", "key", "fetch", "assoc", "rassoc", "values_at", NULL };
    for (int i = 0; picks[i]; i++) if (sp_streq(nm, picks[i])) return NFW_ELEM;
    return NFW_NONE;
  }
  /* the builtin surface: an object-typed answer of a call it does not model
     (send, instance_variable_get, a Method's or a Proc's call, a yield's
     value through then) may be nil */
  (void)an; (void)av;
  return ty_is_object(c->ntype[v]) ? NFW_OPAQUE : NFW_NONE;
}

static int nf_owner_method(NF *f, int n);

static int nf_expr_uncached(NF *f, int v) {
  Compiler *c = f->c;
  const NodeTable *nt = f->nt;
  switch (nt_kind(nt, v)) {
  case NK_NilNode: return NFW_NIL;
  case NK_SelfNode: case NK_IntegerNode: case NK_FloatNode: case NK_StringNode:
  case NK_SymbolNode: case NK_TrueNode: case NK_FalseNode: case NK_ArrayNode: case NK_HashNode:
  case NK_InterpolatedStringNode: case NK_InterpolatedSymbolNode: case NK_RegularExpressionNode:
  case NK_InterpolatedRegularExpressionNode: case NK_RangeNode: case NK_LambdaNode:
  case NK_RationalNode: case NK_ImaginaryNode: case NK_DefNode: case NK_XStringNode:
  case NK_InterpolatedXStringNode: case NK_SourceFileNode: case NK_SourceLineNode:
  case NK_SourceEncodingNode:
    return NFW_NONE;
  /* no value reaches the slot from a jump */
  case NK_ReturnNode: case NK_NextNode: case NK_BreakNode: case NK_RedoNode: case NK_RetryNode:
    return NFW_NONE;
  case NK_ParenthesesNode: return nf_list(f, nt_ref(nt, v, "body"));
  case NK_StatementsNode: return nf_list(f, v);
  case NK_ElseNode: return nf_list(f, nt_ref(nt, v, "statements"));
  case NK_BeginNode: {
    int r = nf_list(f, nt_ref(nt, v, "statements"));
    int els = nt_ref(nt, v, "else_clause");
    if (els >= 0) r = nf_expr(f, els);
    for (int rc = nt_ref(nt, v, "rescue_clause"), d = 0; rc >= 0 && d < 64;
         rc = nt_ref(nt, rc, "subsequent"), d++)
      r = nf_or(r, nf_list(f, nt_ref(nt, rc, "statements")));
    return r;
  }
  case NK_IfNode: case NK_UnlessNode: {
    int st = nt_ref(nt, v, "statements");
    int els = nt_ref(nt, v, nt_kind(nt, v) == NK_IfNode ? "subsequent" : "else_clause");
    if (st < 0 || els < 0) return NFW_NO_ELSE;   /* no branch: nil when it is not taken */
    return nf_or(nf_list(f, st), nf_expr(f, els));
  }
  case NK_CaseNode: {
    int els = nt_ref(nt, v, "else_clause");
    int r = els < 0 ? NFW_NO_ELSE : nf_expr(f, els);   /* no else: nil when no arm matches */
    int wn = 0; const int *w = nt_arr(nt, v, "conditions", &wn);
    for (int i = 0; i < wn; i++) r = nf_or(r, nf_list(f, nt_ref(nt, w[i], "statements")));
    return r;
  }
  case NK_CaseMatchNode: {
    /* no else: CRuby raises NoMatchingPatternError */
    int els = nt_ref(nt, v, "else_clause");
    int r = els < 0 ? NFW_NONE : nf_expr(f, els);
    int wn = 0; const int *w = nt_arr(nt, v, "conditions", &wn);
    for (int i = 0; i < wn; i++) r = nf_or(r, nf_list(f, nt_ref(nt, w[i], "statements")));
    return r;
  }
  case NK_AndNode: return nf_or(nf_expr(f, nt_ref(nt, v, "left")), nf_expr(f, nt_ref(nt, v, "right")));
  case NK_OrNode: return nf_expr(f, nt_ref(nt, v, "right"));
  case NK_RescueModifierNode:
    return nf_or(nf_expr(f, nt_ref(nt, v, "expression")), nf_expr(f, nt_ref(nt, v, "rescue_expression")));
  case NK_LocalVariableWriteNode: case NK_InstanceVariableWriteNode: case NK_GlobalVariableWriteNode:
  case NK_ConstantWriteNode: case NK_ConstantPathWriteNode: case NK_ClassVariableWriteNode:
  case NK_LocalVariableOrWriteNode: case NK_InstanceVariableOrWriteNode:
  case NK_GlobalVariableOrWriteNode: case NK_ConstantOrWriteNode: case NK_ClassVariableOrWriteNode:
    return nf_expr(f, nt_ref(nt, v, "value"));
  case NK_LocalVariableReadNode: {
    const char *nm = nt_str(nt, v, "name");
    Scope *s = nm ? comp_scope_of(c, v) : NULL;
    LocalVar *lv = s ? scope_local(s, nm) : NULL;
    if (!lv) return NFW_OPAQUE;
    if (!lv->obj_may_nil) return NFW_NONE;
    /* a read a guard narrowed (c->nilnarrow, or a truthiness test here) */
    if ((c->nilnarrow && c->nilnarrow[v] != TY_UNKNOWN) || nf_local_guarded(f, v, nm, lv)) {
      f->guarded = 1;
      return NFW_NONE;
    }
    return nf_slot_why(f, &lv->obj_may_nil);
  }
  case NK_InstanceVariableReadNode: {
    if (c->nilnarrow && c->nilnarrow[v] != TY_UNKNOWN) { f->guarded = 1; return NFW_NONE; }
    Scope *s = comp_scope_of(c, v);
    const char *ivn = nt_str(nt, v, "name");
    /* the main object's ivar: nil until a top-level statement above writes it */
    if (s == &c->scopes[0] && ivn) {
      int w = nf_ivar_slot(f, NF_TOP_IVAR, ivn)->wr;
      return w ? w : nf_written_before(f, v, NK_InstanceVariableWriteNode, ivn) ? NFW_NONE : NFW_UNSET;
    }
    if (!s || s->is_cmethod || s->class_id < 0) return NFW_IVAR;   /* a class-level ivar */
    return nf_ivar(f, s->class_id, ivn);
  }
  case NK_ClassVariableReadNode: {
    /* a class variable read ahead of every write raises: a write's value */
    const char *cvn = nt_str(nt, v, "name");
    return cvn ? nf_ivar_slot(f, NF_CVAR, cvn)->wr : NFW_OPAQUE;
  }
  case NK_YieldNode: {
    int mi = nf_owner_method(f, v);
    return mi < 0 ? NFW_OPAQUE : nf_slot_why(f, &f->yield_nil[mi]);
  }
  case NK_GlobalVariableReadNode: {
    const char *gn = nt_str(nt, v, "name");
    LocalVar *g = gn && gn[0] == '$' ? comp_gvar(c, comp_resolve_gvar(c, gn + 1)) : NULL;
    return g ? nf_slot_why(f, &g->obj_may_nil) : NFW_OPAQUE;
  }
  case NK_ConstantReadNode: {
    if (!ty_is_object(c->ntype[v])) return NFW_NONE;
    LocalVar *k = comp_const(c, nt_str(nt, v, "name"));
    return k ? nf_slot_why(f, &k->obj_may_nil) : NFW_OPAQUE;
  }
  case NK_CallNode: return nf_call(f, v);
  case NK_SuperNode: case NK_ForwardingSuperNode: {
    int pmi = nf_plan(f, v, NULL, NULL);
    if (pmi >= 0) return nf_slot_why(f, &c->scopes[pmi].ret_obj_may_nil);
    /* `def self.new(...) = super`: Class#new's instance */
    Scope *s = comp_scope_of(c, v);
    return s && s->is_cmethod && s->name && sp_streq(s->name, "new") ? NFW_NONE : NFW_OPAQUE;
  }
  default:
    /* a pattern's binding, a loop's value, an operator write's: may be nil
       where it is an object */
    return ty_is_object(c->ntype[v]) ? NFW_OPAQUE : NFW_NONE;
  }
}

/* A node's fact as stored (c->nil_fact): its status in the low two bits
   (NF_NOT_NIL, NF_MAY_NIL, NF_GUARDED), the source of a nil above them. */
#define NF_BUSY 0xff
static unsigned char nf_code(int why, int guarded) {
  return (unsigned char)(why ? NF_MAY_NIL | (why << 2) : guarded ? NF_GUARDED : NF_NOT_NIL);
}

/* The source of a nil node v's value may be, or NFW_NONE when it cannot be */
static int nf_expr(NF *f, int v) {
  if (v < 0 || v >= f->nt->count) return NFW_OPAQUE;
  unsigned char m = f->memo[v];
  if (m == NF_BUSY) return NFW_OPAQUE;   /* met again while computed: may be nil */
  if (m) return (m & 3) == NF_MAY_NIL ? m >> 2 : NFW_NONE;
  f->memo[v] = NF_BUSY;
  int sv = f->guarded;
  f->guarded = 0;
  int r = nf_expr_uncached(f, v);
  f->memo[v] = nf_code(r, f->guarded);
  f->guarded = sv;
  return r;
}

/* ---- the slots ---- */

static LocalVar *nf_local_of(NF *f, int node, const char *nm) {
  Scope *s = nm ? comp_scope_of(f->c, node) : NULL;
  return s ? scope_local(s, nm) : NULL;
}

/* The value a target of a multiple assignment takes (`a, b = x, y`), or -2
   when it is not one value as written (a splat, an element of an array
   value, a rescue's exception, a pattern's binding: -3 for the exception,
   which is never nil). */
static int nf_target_value(NF *f, int t) {
  const NodeTable *nt = f->nt;
  int p = f->par ? f->par[t] : -1;
  if (p < 0) return -2;
  NodeKind pk = nt_kind(nt, p);
  if (pk == NK_RescueNode) return -3;
  if (pk != NK_MultiWriteNode) return -2;
  int val = nf_unparen(nt, nt_ref(nt, p, "value"));
  if (val < 0 || nt_kind(nt, val) != NK_ArrayNode || nt_ref(nt, p, "rest") >= 0) return -2;
  int ln = 0; const int *ls = nt_arr(nt, p, "lefts", &ln);
  int en = 0; const int *es = nt_arr(nt, val, "elements", &en);
  for (int i = 0; i < en; i++) if (nt_kind(nt, es[i]) == NK_SplatNode) return -2;
  for (int i = 0; i < ln; i++)
    if (ls[i] == t) return i < en ? es[i] : -1;
  return -2;
}

static int nf_target_nil(NF *f, int t) {
  int v = nf_target_value(f, t);
  if (v == -3) return NFW_NONE;
  if (v == -1) return NFW_NIL;   /* past the values */
  if (v == -2) return NFW_OPAQUE;
  return nf_expr(f, v);
}

/* the class an ivar write in node's scope fills, or -1 (class level) */
static int nf_ivar_owner(NF *f, int node) {
  Scope *s = comp_scope_of(f->c, node);
  if (s == &f->c->scopes[0]) return NF_TOP_IVAR;
  return s && !s->is_cmethod ? s->class_id : -1;
}

static void nf_ivar_write(NF *f, int cls, const char *ivn, int why) {
  if (!why || (cls < 0 && cls != NF_CVAR && cls != NF_TOP_IVAR) || !ivn) return;
  NFIvar *e = nf_ivar_slot(f, cls, ivn);
  if (!e->wr) { e->wr = (unsigned char)why; f->changed = 1; }
}

static void nf_writes(NF *f) {
  Compiler *c = f->c;
  const NodeTable *nt = f->nt;
  static const NodeKind lw[] = { NK_LocalVariableWriteNode, NK_LocalVariableOrWriteNode,
                                 NK_LocalVariableAndWriteNode };
  for (int q = 0; q < 3; q++)
    NT_FOREACH_KIND(nt, lw[q], w) {
      LocalVar *lv = nf_local_of(f, w, nt_str(nt, w, "name"));
      if (lv && !lv->obj_may_nil) nf_set(f, &lv->obj_may_nil, nf_expr(f, nt_ref(nt, w, "value")));
    }
  NT_FOREACH_KIND(nt, NK_LocalVariableTargetNode, w) {
    LocalVar *lv = nf_local_of(f, w, nt_str(nt, w, "name"));
    if (lv && !lv->obj_may_nil && ty_is_object(lv->type)) nf_set(f, &lv->obj_may_nil, nf_target_nil(f, w));
  }
  NT_FOREACH_KIND(nt, NK_LocalVariableOperatorWriteNode, w) {
    LocalVar *lv = nf_local_of(f, w, nt_str(nt, w, "name"));
    if (lv && !lv->obj_may_nil && ty_is_object(lv->type)) nf_set(f, &lv->obj_may_nil, NFW_OPAQUE);
  }
  static const NodeKind iw[] = { NK_InstanceVariableWriteNode, NK_InstanceVariableOrWriteNode,
                                 NK_InstanceVariableAndWriteNode };
  for (int q = 0; q < 3; q++)
    NT_FOREACH_KIND(nt, iw[q], w)
      nf_ivar_write(f, nf_ivar_owner(f, w), nt_str(nt, w, "name"), nf_expr(f, nt_ref(nt, w, "value")));
  NT_FOREACH_KIND(nt, NK_InstanceVariableTargetNode, w)
    nf_ivar_write(f, nf_ivar_owner(f, w), nt_str(nt, w, "name"), nf_target_nil(f, w));
  NT_FOREACH_KIND(nt, NK_InstanceVariableOperatorWriteNode, w)
    nf_ivar_write(f, nf_ivar_owner(f, w), nt_str(nt, w, "name"), ty_is_object(c->ntype[w]) ? NFW_OPAQUE : 0);
  static const NodeKind cw[] = { NK_ClassVariableWriteNode, NK_ClassVariableOrWriteNode,
                                 NK_ClassVariableAndWriteNode };
  for (int q = 0; q < 3; q++)
    NT_FOREACH_KIND(nt, cw[q], w)
      nf_ivar_write(f, NF_CVAR, nt_str(nt, w, "name"), nf_expr(f, nt_ref(nt, w, "value")));
  NT_FOREACH_KIND(nt, NK_ClassVariableTargetNode, w)
    nf_ivar_write(f, NF_CVAR, nt_str(nt, w, "name"), nf_target_nil(f, w));
  NT_FOREACH_KIND(nt, NK_ClassVariableOperatorWriteNode, w)
    nf_ivar_write(f, NF_CVAR, nt_str(nt, w, "name"), ty_is_object(c->ntype[w]) ? NFW_OPAQUE : 0);
  static const NodeKind gw[] = { NK_GlobalVariableWriteNode, NK_GlobalVariableOrWriteNode,
                                 NK_GlobalVariableAndWriteNode, NK_GlobalVariableTargetNode,
                                 NK_GlobalVariableOperatorWriteNode };
  for (int q = 0; q < 5; q++)
    NT_FOREACH_KIND(nt, gw[q], w) {
      const char *gn = nt_str(nt, w, "name");
      LocalVar *g = gn && gn[0] == '$' ? comp_gvar(c, comp_resolve_gvar(c, gn + 1)) : NULL;
      if (!g || g->obj_may_nil) continue;
      int why = q == 3 ? nf_target_nil(f, w) : q == 4 ? (ty_is_object(g->type) ? NFW_OPAQUE : 0)
              : nf_expr(f, nt_ref(nt, w, "value"));
      nf_set(f, &g->obj_may_nil, why);
    }
  static const NodeKind kw[] = { NK_ConstantWriteNode, NK_ConstantOrWriteNode, NK_ConstantAndWriteNode };
  for (int q = 0; q < 3; q++)
    NT_FOREACH_KIND(nt, kw[q], w) {
      LocalVar *k = comp_const(c, nt_str(nt, w, "name"));
      if (k && !k->obj_may_nil) nf_set(f, &k->obj_may_nil, nf_expr(f, nt_ref(nt, w, "value")));
    }
}

/* Is method m one a call the analysis cannot see may reach: a name a send
   or a method(:m) carries, or one the runtime calls back with any value? */
static int nf_unseen_callers(NF *f, const Scope *m) {
  static const char *const callbacks[] = { "==", "!=", "eql?", "equal?", "<=>", "===", "coerce",
    "method_missing", "respond_to_missing?", "initialize_copy", "inherited", "included", NULL };
  if (!m->name) return 1;
  for (int i = 0; callbacks[i]; i++) if (sp_streq(m->name, callbacks[i])) return 1;
  for (int i = 0; i < f->ndyn; i++) if (sp_streq(f->dyn[i], m->name)) return 1;
  return 0;
}

/* The parameters of method mi that call `id` (its arguments av[0..an))
   binds: each takes its argument's fact, a default its default's, a value
   the layout spreads or gathers may be nil. */
static void nf_bind_params(NF *f, int id, int mi, const int *av, int an) {
  Compiler *c = f->c;
  const NodeTable *nt = f->nt;
  Scope *m = &c->scopes[mi];
  /* only an object parameter not yet known to take nil can learn anything */
  int open = 0;
  for (int k = 0; k < m->nparams && !open; k++) {
    LocalVar *p = m->pnames[k] ? scope_local(m, m->pnames[k]) : NULL;
    open = p && !p->obj_may_nil && ty_is_object(p->type);
  }
  if (!open) return;
  ArgLayout L;
  call_layout(c, m, av, an, &L);
  int kwh = an > 0 && nt_kind(nt, av[an - 1]) == NK_KeywordHashNode ? av[an - 1] : -1;
  for (int k = 0; k < m->nparams; k++) {
    LocalVar *p = m->pnames[k] ? scope_local(m, m->pnames[k]) : NULL;
    if (!p || p->obj_may_nil || !ty_is_object(p->type)) continue;
    int why;
    ArgFrom from = k < L.n ? L.from[k] : ARG_DEFAULT;
    int dflt = m->pdefault && m->pdefault[k] >= 0 ? m->pdefault[k] : -1;
    if (from == ARG_NODE) {
      int a = layout_plain_arg(c, m, av, &L, k);
      why = a < 0 ? NFW_OPAQUE : nf_expr(f, a);
    }
    else if (from == ARG_DEFAULT) why = dflt >= 0 ? nf_expr(f, dflt) : NFW_OPAQUE;
    else if (from == ARG_BY_NAME) {
      int a = ie_kwhash_value(c, kwh, m->pnames[k]);
      why = a >= 0 ? nf_expr(f, a) : dflt >= 0 ? nf_expr(f, dflt) : NFW_OPAQUE;
    }
    else why = NFW_OPAQUE;   /* a splat's element, a gathered value */
    nf_set(f, &p->obj_may_nil, why);
  }
  arg_layout_free(&L);
  (void)id;
}

/* The parameters of the block `blk` call `id` passes: what the callee's
   yields hand them, the receiver for tap and then, an accumulator's start;
   a proc's or a lambda's caller is not seen. */
static void nf_bind_block(NF *f, int id, int blk, int mi, int **yields, int *nyields) {
  Compiler *c = f->c;
  const NodeTable *nt = f->nt;
  const char *cn = nt_str(nt, id, "name");
  int all = 0, from_recv = 0, acc = -1;
  if (mi >= 0) {
    if (!c->scopes[mi].yields) all = 1;
  }
  else if (cn && (sp_streq(cn, "tap") || sp_streq(cn, "then") || sp_streq(cn, "yield_self"))) from_recv = 1;
  else if (cn && (sp_streq(cn, "inject") || sp_streq(cn, "reduce") || sp_streq(cn, "each_with_object"))) {
    int a = nt_ref(nt, id, "arguments"), an = 0;
    const int *av = a >= 0 ? nt_arr(nt, a, "arguments", &an) : NULL;
    acc = an >= 1 ? av[0] : -1;
    if (acc < 0) return;
  }
  else if (cn && (sp_streq(cn, "lambda") || sp_streq(cn, "proc") || sp_streq(cn, "new") ||
                  sp_streq(cn, "define_method") || sp_streq(cn, "define_singleton_method") ||
                  sp_streq(cn, "instance_exec") || sp_streq(cn, "class_exec") ||
                  sp_streq(cn, "module_exec") || sp_streq(cn, "to_proc"))) all = 1;
  else return;   /* a builtin iteration: its elements (see the header) */
  int bp = nt_ref(nt, blk, "parameters");
  if (bp >= 0 && nt_kind(nt, bp) == NK_BlockParametersNode) {
    int pn = nt_ref(nt, bp, "parameters");
    /* an optional, a rest's or a keyword's object: may be nil */
    if (pn >= 0) {
      static const char *const other[] = { "optionals", "posts", "keywords", NULL };
      for (int o = 0; other[o]; o++) {
        int n = 0; const int *ps = nt_arr(nt, pn, other[o], &n);
        for (int i = 0; i < n; i++) {
          LocalVar *lv = nf_local_of(f, ps[i], nt_str(nt, ps[i], "name"));
          if (lv && !lv->obj_may_nil && ty_is_object(lv->type)) nf_set(f, &lv->obj_may_nil, NFW_OPAQUE);
        }
      }
    }
  }
  for (int i = 0; i < 9; i++) {
    const char *pn = block_param_name(c, blk, i);
    if (!pn) break;
    int body = nt_ref(nt, blk, "body");
    LocalVar *lv = nf_local_of(f, body >= 0 ? body : blk, pn);
    if (!lv) lv = nf_local_of(f, blk, pn);
    if (!lv || lv->obj_may_nil || !ty_is_object(lv->type)) continue;
    int why = NFW_NONE;
    if (all) why = NFW_CALLER;
    else if (from_recv) why = i > 0 ? NFW_NIL : nf_expr(f, nt_ref(nt, id, "receiver"));
    else if (acc >= 0) why = i == 0 ? nf_expr(f, acc) : NFW_NONE;
    else {
      /* every yield of the method: argument i, or nil past its arguments */
      for (int y = 0; y < nyields[mi] && !why; y++) {
        int ya = nt_ref(nt, yields[mi][y], "arguments"), yn = 0;
        const int *yv = ya >= 0 ? nt_arr(nt, ya, "arguments", &yn) : NULL;
        int splat = 0;
        for (int j = 0; j < yn; j++) if (nt_kind(nt, yv[j]) == NK_SplatNode) splat = 1;
        if (splat || (yn == 1 && block_param_name(c, blk, 1))) why = NFW_OPAQUE;   /* spread */
        else why = i >= yn ? NFW_NIL : nf_expr(f, yv[i]);
      }
      if (nyields[mi] == 0) why = NFW_CALLER;
    }
    nf_set(f, &lv->obj_may_nil, why);
  }
}

/* a `next` of block body n (not of a block or a method inside it) whose
   value may be nil */
static int nf_next_nil(NF *f, int n, int depth) {
  const NodeTable *nt = f->nt;
  if (n < 0 || depth > 512) return 0;
  NodeKind k = nt_kind(nt, n);
  if (k == NK_BlockNode || k == NK_LambdaNode || k == NK_DefNode) return 0;
  if (k == NK_NextNode) {
    int a = nt_ref(nt, n, "arguments"), an = 0;
    const int *av = a >= 0 ? nt_arr(nt, a, "arguments", &an) : NULL;
    return an == 0 ? NFW_NIL : an == 1 ? nf_expr(f, av[0]) : NFW_NONE;
  }
  for (int i = 0; i < nt_num_refs(nt, n); i++) {
    int w = nf_next_nil(f, nt_ref_at(nt, n, i), depth + 1);
    if (w) return w;
  }
  for (int i = 0; i < nt_num_arrs(nt, n); i++) {
    int an = 0; const int *av = nt_arr_at(nt, n, i, &an);
    for (int k2 = 0; k2 < an; k2++) { int w = nf_next_nil(f, av[k2], depth + 1); if (w) return w; }
  }
  return NFW_NONE;
}

static void nf_calls(NF *f, int **yields, int *nyields) {
  Compiler *c = f->c;
  const NodeTable *nt = f->nt;
  /* a parameter's default, which a call that leaves it out binds: taken
     whether or not a call does, so a call with no argument binds nothing */
  for (int mi = 1; mi < c->nscopes; mi++) {
    Scope *m = &c->scopes[mi];
    for (int k = 0; m->pdefault && k < m->nparams; k++) {
      if (m->pdefault[k] < 0 || !m->pnames[k]) continue;
      LocalVar *p = scope_local(m, m->pnames[k]);
      if (p && !p->obj_may_nil && ty_is_object(p->type)) nf_set(f, &p->obj_may_nil, nf_expr(f, m->pdefault[k]));
    }
  }
  NT_FOREACH_KIND(nt, NK_CallNode, id) {
    const char *cn = nt_str(nt, id, "name");
    if (!cn) continue;
    int r = nt_ref(nt, id, "receiver");
    int a = nt_ref(nt, id, "arguments"), an = 0;
    const int *av = a >= 0 ? nt_arr(nt, a, "arguments", &an) : NULL;
    int blk = nt_ref(nt, id, "block");
    /* a call with no argument and no block binds nothing */
    if (an == 0 && blk < 0) continue;
    int owner = -1, dispatch = CP_NONE;
    int mi = nf_plan(f, id, &owner, &dispatch);
    /* `W.new(k)` binds initialize's parameters */
    if (mi < 0 && r >= 0 && sp_streq(cn, "new")) {
      int rk = nt_kind(nt, r);
      int k = rk == NK_ConstantReadNode || rk == NK_ConstantPathNode ? comp_class_index(c, nt_str(nt, r, "name")) : -1;
      if (k >= 0) mi = comp_method_in_chain(c, k, "initialize", NULL);
      dispatch = CP_DIRECT;
    }
    if (mi >= 0) {
      nf_bind_params(f, id, mi, av, an);
      /* each override a switch may take instead */
      if ((dispatch == CP_SWITCH || dispatch == CP_PER_ARM) && owner >= 0)
        for (int j = nf_byname_first(f, cn); j < f->nbyname; j++) {
          int k = f->byname[j];
          if (!sp_streq(c->scopes[k].name, cn)) break;
          if (k != mi && nf_class_reaches(c, c->scopes[k].class_id, owner)) nf_bind_params(f, id, k, av, an);
        }
    }
    else if (r >= 0 && c->ntype[r] == TY_POLY && an > 0) {
      /* a boxed receiver: every instance method of the name */
      for (int j = nf_byname_first(f, cn); j < f->nbyname; j++) {
        int k = f->byname[j];
        if (!sp_streq(c->scopes[k].name, cn)) break;
        nf_bind_params(f, id, k, av, an);
      }
    }
    /* an attr writer: its ivar */
    size_t cl = strlen(cn);
    if (mi < 0 && an == 1 && cl > 1 && cl < 250 && cn[cl - 1] == '=' && r >= 0 && ty_is_object(c->ntype[r])) {
      char base[256]; memcpy(base, cn, cl - 1); base[cl - 1] = 0;
      int dc = -1;
      if (comp_writer_in_chain(c, ty_object_class(c->ntype[r]), base, &dc) && dc >= 0) {
        char ivn[260]; snprintf(ivn, sizeof ivn, "@%s", base);
        nf_ivar_write(f, dc, ivn, nf_expr(f, av[0]));
      }
    }
    if (blk >= 0 && nt_kind(nt, blk) == NK_BlockNode) nf_bind_block(f, id, blk, mi, yields, nyields);
    /* what the method's yields answer: the block's value, or a `next`'s */
    if (mi >= 0 && !f->yield_nil[mi] && blk >= 0)
      nf_set(f, &f->yield_nil[mi], nt_kind(nt, blk) != NK_BlockNode ? NFW_CALLER
             : nf_or(nf_list(f, nt_ref(nt, blk, "body")), nf_next_nil(f, nt_ref(nt, blk, "body"), 0)));
  }
  /* `super(args)` binds the parent's, a bare `super` hands on the method's own */
  NT_FOREACH_KIND(nt, NK_SuperNode, id) {
    int mi = nf_plan(f, id, NULL, NULL);
    if (mi < 0) continue;
    /* the block a super hands on is its caller's: not seen */
    nf_set(f, &f->yield_nil[mi], NFW_CALLER);
    int a = nt_ref(nt, id, "arguments"), an = 0;
    const int *av = a >= 0 ? nt_arr(nt, a, "arguments", &an) : NULL;
    nf_bind_params(f, id, mi, av, an);
  }
  NT_FOREACH_KIND(nt, NK_ForwardingSuperNode, id) {
    int mi = nf_plan(f, id, NULL, NULL);
    Scope *s = comp_scope_of(c, id);
    if (mi < 0 || !s) continue;
    nf_set(f, &f->yield_nil[mi], NFW_CALLER);
    Scope *m = &c->scopes[mi];
    for (int k = 0; k < m->nparams; k++) {
      LocalVar *pp = m->pnames[k] ? scope_local(m, m->pnames[k]) : NULL;
      LocalVar *own = k < s->nparams && s->pnames[k] ? scope_local(s, s->pnames[k]) : NULL;
      if (pp && !pp->obj_may_nil && ty_is_object(pp->type))
        nf_set(f, &pp->obj_may_nil, own ? nf_slot_why(f, &own->obj_may_nil) : NFW_OPAQUE);
    }
  }
}

/* A method's value: its body's, or a `return`'s */
static void nf_returns(NF *f, int **rets, int *nrets) {
  Compiler *c = f->c;
  const NodeTable *nt = f->nt;
  for (int mi = 1; mi < c->nscopes; mi++) {
    Scope *m = &c->scopes[mi];
    /* `new` drops initialize's value */
    if (m->ret_obj_may_nil || m->def_node < 0 || (m->name && sp_streq(m->name, "initialize"))) continue;
    int why = m->body < 0 ? NFW_NIL : nf_list(f, m->body);
    for (int k = 0; k < nrets[mi] && !why; k++) {
      int ra = nt_ref(nt, rets[mi][k], "arguments"), rn = 0;
      const int *rv = ra >= 0 ? nt_arr(nt, ra, "arguments", &rn) : NULL;
      why = rn == 0 ? NFW_NIL : rn == 1 ? nf_expr(f, rv[0]) : NFW_NONE;
    }
    nf_set(f, &m->ret_obj_may_nil, why);
  }
}

/* the method scope node n's `return` or `yield` belongs to: its DefNode's,
   or -1 inside a lambda */
static int nf_owner_method(NF *f, int n) {
  for (int cur = n, d = 0; cur >= 0 && d < 4096; cur = f->par[cur], d++) {
    NodeKind k = nt_kind(f->nt, cur);
    if (k == NK_LambdaNode) return -1;
    if (k == NK_DefNode) return f->def_mi[cur];
  }
  return -1;
}

/* collect, per method scope, the nodes of kind k that belong to it */
static void nf_collect(NF *f, NodeKind k, int ***out, int **nout) {
  Compiler *c = f->c;
  int **v = calloc((size_t)c->nscopes + 1, sizeof *v);
  int *n = calloc((size_t)c->nscopes + 1, sizeof *n);
  int *cap = calloc((size_t)c->nscopes + 1, sizeof *cap);
  if (!v || !n || !cap) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  NT_FOREACH_KIND(f->nt, k, id) {
    int mi = nf_owner_method(f, id);
    if (mi < 0 || mi >= c->nscopes) continue;
    if (n[mi] >= cap[mi]) {
      cap[mi] = cap[mi] ? cap[mi] * 2 : 4;
      v[mi] = realloc(v[mi], sizeof(int) * (size_t)cap[mi]);
    }
    v[mi][n[mi]++] = id;
  }
  free(cap);
  *out = v; *nout = n;
}

static void nf_free_lists(Compiler *c, int **v, int *n) {
  for (int i = 0; i <= c->nscopes; i++) free(v[i]);
  free(v); free(n);
}

void an_nil_facts(Compiler *c) {
  const NodeTable *nt = c->nt;
  NF f;
  memset(&f, 0, sizeof f);
  f.c = c; f.nt = nt;
  f.par = du_parent_map(nt);
  f.memo = calloc((size_t)nt->count + 1, 1);
  f.def_mi = malloc(sizeof(int) * ((size_t)nt->count + 1));
  f.yield_nil = calloc((size_t)c->nscopes + 1, sizeof *f.yield_nil);
  f.byname = malloc(sizeof(int) * ((size_t)c->nscopes + 1));
  for (int k = 1; f.byname && k < c->nscopes; k++)
    if (c->scopes[k].name && !c->scopes[k].is_cmethod && c->scopes[k].class_id >= 0) f.byname[f.nbyname++] = k;
  nf_sort_c = c;
  if (f.byname) qsort(f.byname, (size_t)f.nbyname, sizeof *f.byname, nf_byname_cmp);
  /* the class tree, downwards */
  int nedges = 0;
  for (int k = 0; k < c->nclasses; k++) nedges += 1 + c->classes[k].nincluded_mods;
  f.kid_head = malloc(sizeof(int) * ((size_t)c->nclasses + 1));
  f.kid_next = malloc(sizeof(int) * ((size_t)nedges + 1));
  f.kid_to = malloc(sizeof(int) * ((size_t)nedges + 1));
  f.dfs = malloc(sizeof(int) * ((size_t)c->nclasses + 1));
  f.seen = calloc((size_t)c->nclasses + 1, sizeof *f.seen);
  if (!f.kid_head || !f.kid_next || !f.kid_to || !f.dfs || !f.seen) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  for (int k = 0; k < c->nclasses; k++) f.kid_head[k] = -1;
  for (int k = 0, e = 0; k < c->nclasses; k++) {
    int ups[1 + 64], nup = 0;
    if (c->classes[k].parent >= 0) ups[nup++] = c->classes[k].parent;
    for (int m = 0; m < c->classes[k].nincluded_mods && nup < 65; m++) ups[nup++] = c->classes[k].included_mods[m];
    for (int u = 0; u < nup; u++) {
      if (ups[u] < 0 || ups[u] >= c->nclasses || ups[u] == k) continue;
      f.kid_to[e] = k; f.kid_next[e] = f.kid_head[ups[u]]; f.kid_head[ups[u]] = e; e++;
    }
  }
  f.pl_mi = malloc(sizeof(int) * ((size_t)nt->count + 1));
  f.pl_owner = calloc((size_t)nt->count + 1, sizeof *f.pl_owner);
  f.pl_disp = calloc((size_t)nt->count + 1, 1);
  if (!f.par || !f.memo || !f.def_mi || !f.pl_mi || !f.pl_owner || !f.pl_disp || !f.yield_nil || !f.byname) {
    fprintf(stderr, "spinel: out of memory\n"); exit(1);
  }
  for (int k = 0; k < nt->count; k++) { f.def_mi[k] = -1; f.pl_mi[k] = -2; }
  for (int mi = 1; mi < c->nscopes; mi++) {
    int d = c->scopes[mi].def_node;
    if (d >= 0 && d < nt->count && f.def_mi[d] < 0) f.def_mi[d] = mi;
  }
  /* the slots start from what is known before any value is: a parameter
     some call hands nil (obj_nilable), a slot a read can reach before any
     write, a parameter a call the analysis cannot see binds */
  NT_FOREACH_KIND(nt, NK_CallNode, id) {
    const char *cn = nt_str(nt, id, "name");
    if (!cn) continue;
    if (sp_streq(cn, "instance_variable_set")) f.all_ivars_nil = 1;
    if (!sp_streq(cn, "send") && !sp_streq(cn, "__send__") && !sp_streq(cn, "public_send") &&
        !sp_streq(cn, "method") && !sp_streq(cn, "public_method") && !sp_streq(cn, "instance_method") &&
        !sp_streq(cn, "define_method") && !sp_streq(cn, "alias_method"))
      continue;
    int a = nt_ref(nt, id, "arguments"), an = 0;
    const int *av = a >= 0 ? nt_arr(nt, a, "arguments", &an) : NULL;
    for (int i = 0; i < an; i++) {
      NodeKind ak = nt_kind(nt, av[i]);
      const char *s = ak == NK_SymbolNode || ak == NK_StringNode ? nt_str(nt, av[i], ak == NK_SymbolNode ? "value" : "content") : NULL;
      if (!s) continue;
      if (f.ndyn >= f.cdyn) {
        f.cdyn = f.cdyn ? f.cdyn * 2 : 16;
        f.dyn = realloc(f.dyn, sizeof *f.dyn * (size_t)f.cdyn);
      }
      f.dyn[f.ndyn++] = s;
    }
  }
  for (int mi = 0; mi < c->nscopes; mi++) {
    Scope *m = &c->scopes[mi];
    m->ret_obj_may_nil = 0;
    int unseen = mi > 0 && m->def_node >= 0 && nf_unseen_callers(&f, m);
    /* a block from a caller not seen: a dynamic call, a proc-form clone's */
    if (unseen || m->is_proc_form || m->is_lowered_yield) nf_set(&f, &f.yield_nil[mi], NFW_CALLER);
    for (int k = 0; k < m->nlocals; k++) m->locals[k].obj_may_nil = 0;
    for (int k = 0; k < m->nlocals; k++) {
      LocalVar *lv = &m->locals[k];
      if (!ty_is_object(lv->type)) continue;
      if (lv->is_param && lv->obj_nilable) nf_set(&f, &lv->obj_may_nil, NFW_NIL);
      if (lv->is_param && unseen) nf_set(&f, &lv->obj_may_nil, NFW_CALLER);
      if (lv->or_written && !lv->is_param && !lv->is_block_param) nf_set(&f, &lv->obj_may_nil, NFW_UNSET);
    }
  }
  for (int g = 0; g < c->ngvars; g++) c->gvars[g].obj_may_nil = 0;
  for (int k = 0; k < c->nconsts; k++) c->consts[k].obj_may_nil = 0;
  /* a read the definite-assignment walk finds can run before any write */
  {
    static const NodeKind rk[] = { NK_LocalVariableReadNode, NK_LocalVariableAndWriteNode,
                                   NK_LocalVariableOperatorWriteNode };
    f.dp.pos = malloc(sizeof(int) * ((size_t)nt->count + 1));
    f.dp.done = calloc((size_t)nt->count + 1, 1);
    if (!f.dp.pos || !f.dp.done) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
    for (int k = 0; k < nt->count; k++) f.dp.pos[k] = -1;
    for (int q = 0; q < 3; q++)
      NT_FOREACH_KIND(nt, rk[q], r) {
        const char *nm = nt_str(nt, r, "name");
        LocalVar *lv = nf_local_of(&f, r, nm);
        if (!lv || lv->is_param || lv->is_block_param || lv->obj_may_nil || !ty_is_object(lv->type)) continue;
        if (du_read_maybe_unset(nt, f.par, &f.dp, r, nm)) nf_set(&f, &lv->obj_may_nil, NFW_UNSET);
      }
    du_memo_free();
  }
  /* globals are nil until their first write, which a method reading one
     cannot be shown to follow: an object global read in a method or a
     block may be nil (top-level reads ahead of every write too) */
  NT_FOREACH_KIND(nt, NK_GlobalVariableReadNode, r) {
    const char *gn = nt_str(nt, r, "name");
    LocalVar *g = gn && gn[0] == '$' ? comp_gvar(c, comp_resolve_gvar(c, gn + 1)) : NULL;
    if (!g || g->obj_may_nil || !ty_is_object(g->type)) continue;
    if (!nf_written_before(&f, r, NK_GlobalVariableWriteNode, gn)) nf_set(&f, &g->obj_may_nil, NFW_UNSET);
  }
  int **yields, *nyields, **rets, *nrets;
  nf_collect(&f, NK_YieldNode, &yields, &nyields);
  nf_collect(&f, NK_ReturnNode, &rets, &nrets);
  /* Every round only sets flags, so it stops; the cap is the backstop
     against a non-monotone round, as mark_nullable_int_locals' is. */
  long rounds_max = c->nscopes + 2 + c->ngvars + c->nconsts + nt->count;
  for (long round = 0; round < rounds_max; round++) {
    f.changed = 0;
    f.round = (int)round;
    memset(f.memo, 0, (size_t)nt->count + 1);
    nf_writes(&f);
    nf_calls(&f, yields, nyields);
    nf_returns(&f, rets, nrets);
    if (!f.changed) break;
  }
  /* the node facts, from the settled slots */
  memset(f.memo, 0, (size_t)nt->count + 1);
  f.round++;
  for (int id = 0; id < nt->count; id++) (void)nf_expr(&f, id);
  free(c->nil_fact);
  c->nil_fact = f.memo;
  c->nil_fact_n = nt->count;
  /* the ivars, by class */
  for (int k = 0; k < c->nclasses; k++) {
    ClassInfo *ci = &c->classes[k];
    free(ci->ivar_obj_may_nil);
    ci->ivar_obj_may_nil = calloc((size_t)ci->nivars + 1, 1);
    ci->n_ivar_obj_may_nil = ci->nivars;
    for (int i = 0; i < ci->nivars; i++)
      ci->ivar_obj_may_nil[i] = (unsigned char)(ty_is_object(ci->ivar_types[i]) && nf_ivar(&f, k, ci->ivars[i]) != NFW_NONE);
  }
  nf_free_lists(c, yields, nyields);
  nf_free_lists(c, rets, nrets);
  free(f.par); free(f.dp.pos); free(f.dp.done); free(f.def_mi); free(f.iv); free(f.dyn); free(f.rg);
  free(f.pl_mi); free(f.pl_owner); free(f.pl_disp); free(f.yield_nil); free(f.byname);
  free(f.kid_head); free(f.kid_next); free(f.kid_to); free(f.dfs); free(f.seen);
}

int nil_fact_node(const Compiler *c, int node) {
  if (node < 0) return 0;
  if (!c->nil_fact || node >= c->nil_fact_n) return ty_is_object(c->ntype[node]);
  return (c->nil_fact[node] & 3) == NF_MAY_NIL;
}

int nil_fact_why(const Compiler *c, int node) {
  if (node < 0 || !c->nil_fact || node >= c->nil_fact_n) return NFW_OPAQUE;
  unsigned char m = c->nil_fact[node];
  return (m & 3) == NF_MAY_NIL ? m >> 2 : (m & 3) == NF_GUARDED ? NFW_GUARDED : NFW_NONE;
}

const char *nil_fact_why_name(int why) {
  static const char *const names[] = { "none", "nil", "no-else", "safe-nav", "elem", "unset",
    "ivar", "caller", "opaque", "guarded" };
  return why >= 0 && why < (int)(sizeof names / sizeof *names) ? names[why] : "?";
}

int nil_fact_ivar(const Compiler *c, int cid, const char *ivn) {
  if (cid < 0 || cid >= c->nclasses || !ivn) return 1;
  const ClassInfo *ci = &c->classes[cid];
  for (int i = 0; i < ci->n_ivar_obj_may_nil && i < ci->nivars; i++)
    if (sp_streq(ci->ivars[i], ivn)) return ci->ivar_obj_may_nil[i];
  return 1;
}
