/* analyze_share.c -- the share classes --share-strings decides by (#6765).

   See share.h. One walk over the node table gives every node a value (an
   element of the union-find, or none) and unifies what flows together:
   each write with its target, each container store with the container's
   elements, each argument with the parameter it binds, each yield with the
   blocks the method is called with, each return with the method's value.
   A builtin call is read off its builtin-op share row (bop_share); a user
   call off its call plan (cplan_user_fresh). What the walk does not follow
   -- a proc or Method call, a runtime `send`, a builtin with no row -- joins
   UNKNOWN, so a case it misses costs a handle, never a silent copy.

   A parameter its method only reads and mutates is lent, as the lent slot
   is: binding it does not unify, and its mutation marks each argument's
   class instead. That keeps `grow(buf)` on a local accumulator a
   `const char *` lent by address, as without the flag. */

#include <stdlib.h>
#include <string.h>
#include "analyze_internal.h"
#include "builtin_ops.h"
#include "builtin_names.h"
#include "call_plan.h"
#include "share.h"
#include "repr.h"

/* element-own flags (not merged by a union) */
enum { SHE_WRITTEN = 1 };
/* a class flag beside share.h's SHF_*: a value of the class leaves a call
   to be read after it (`p(lit.each { |x| x << y })`, `lit.map { }.first`),
   so a container of the class can be reached again (sh_finalize) */
enum { SHF_OUT = 8 };

typedef struct ShareFacts {
  int n, cap;
  int *parent, *elem, *nhold, *nmem, *nelem, *hidx, *owner;
  /* per root: the method scope every holder of the class is a plain local
     of (no parameter, no captured local), or -1 none yet, or -2 when some
     member is anything else */
  int *lsc;
  /* a method's return of a value, held back until the classes settle: one
     whose class is still only that method's own locals hands the caller a
     String nobody else names, and joins no class (sh_settle_rets) */
  int *ret_m, *ret_v, nret, cret;
  unsigned char *ret_done;
  unsigned char *unused;   /* per node: a statement whose value is dropped */
  /* the mutation sites, for SPINEL_SHARE_STATS=3: node, value */
  int *mut_n, *mut_v, nmut, cmut;
  int *hcount;         /* per root, once built: holders storing a String */
  unsigned char *anchored;   /* per root, once built: a container of the class
                                can be reached again (sh_finalize) */
  unsigned char *kind, *flags, *own;
  /* the holders, and their element */
  ShareHolder *h;
  int *helem, nh, ch;
  /* holder keys: a hash over (kind, a, name) */
  int *bucket, *hnext;
  int nbucket;
  /* each node's value: -2 not yet computed, -1 none */
  int *nval, nnodes;
  /* lent bindings: argument value -> parameter holder element */
  int *lend_arg, *lend_par;
  unsigned char *lend_direct, *lend_done;
  int nlend, clend;
  /* the method names a Method, `send` or define_method can reach */
  const char **dyn;
  int ndyn, cdyn, dyn_all, dyn_ivars;
  const char **mconst;
  int nmconst, cmconst;
  int unknown;
  int closed;          /* unions with UNKNOWN are dropped (the stats' second build) */
  int union_stack_cap;
  int *union_stack;
  /* `k.new(...)` with k a class held in a variable reaches any initialize:
     its arguments join any_new_pos (by position; the 16th and later share
     the last) and any_new_kw (its keywords), and its literal blocks
     any_new_blk, which every initialize takes once after the walk
     (sh_settle_any_new) */
  int any_new_pos[16], any_new_kw, any_new_used;
  int *any_new_blk, nany_blk, cany_blk;
  /* the attr readers and writers of every class by name, and the method
     scopes by name, sorted for a binary search (built on first use) */
  struct ShNamed { const char *name; int k; } *attr_r, *attr_w, *scope_nm;
  int nattr_r, nattr_w, nscope_nm, named_built;
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
    F->lsc = realloc(F->lsc, sizeof(int) * (size_t)nc);
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
  F->lsc[e] = -2;
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
    if (F->lsc[rx] == -1 || F->lsc[ry] == -2) F->lsc[rx] = F->lsc[ry];
    else if (F->lsc[ry] != -1 && F->lsc[ry] != F->lsc[rx]) F->lsc[rx] = -2;
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
  if (kind == SHK_LOCAL) F->lsc[e] = a;
  F->helem[i] = e;
  F->hidx[e] = i;
  F->hnext[i] = F->bucket[hb];
  F->bucket[hb] = i;
  /* the buckets grow with the holders, so a lookup stays a short chain */
  if (F->nh > 2 * F->nbucket) {
    F->nbucket *= 2;
    F->bucket = realloc(F->bucket, sizeof(int) * (size_t)F->nbucket);
    for (int k = 0; k < F->nbucket; k++) F->bucket[k] = -1;
    for (int k = 0; k < F->nh; k++) {
      ShareHolder *hk = &F->h[k];
      unsigned b2 = sh_key_hash(hk->kind, hk->kind == SHK_IVAR ? hk->cid : hk->scope, hk->name) &
                    (unsigned)(F->nbucket - 1);
      F->hnext[k] = F->bucket[b2];
      F->bucket[b2] = k;
    }
  }
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
  int e = sh_holder(F, SHK_LOCAL, (int)(s - c->scopes), (int)(lv - s->locals), NULL, node);
  /* a parameter's String is the caller's, a captured local's a proc's too */
  if (e >= 0 && (lv->is_param || lv->is_block_param || lv->is_cell || lv->cell_outlives || s->def_node < 0))
    F->lsc[sh_find(F, e)] = -2;
  return e;
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
  int nh0 = F->nh;
  int e = sh_holder(F, SHK_IVAR, cid, -1, name, node);
  /* a superclass's ivar of the name is the same slot of the same object:
     one written in A#initialize and changed in B#bang (B < A) */
  if (F->nh > nh0)
    for (int k = c->classes[cid].parent; k >= 0; k = c->classes[k].parent)
      if (comp_ivar_index(&c->classes[k], name) >= 0) {
        sh_union(F, e, sh_ivar(F, c, k, name, node));
        break;
      }
  return e;
}

/* A String written into ivar holder l from node vn, whose value is v. The
   holder is one per class but a slot per object: a value the write does
   not make itself -- a call's answer (`k2.v = k1.v`), a member read, a
   yield -- may be the String another object's slot already holds, so the
   class counts as several names (SHF_MULTI). A String of its own (no
   value) and a read of a holder (itself a name the class counts) do not. */
static void sh_ivar_store(ShareFacts *F, Compiler *c, int l, int vn, int v) {
  if (l < 0 || v < 0) return;
  sh_union(F, l, v);
  NodeKind k = vn >= 0 ? nt_kind(c->nt, vn) : NK_NilNode;
  if (k == NK_LocalVariableReadNode || k == NK_InstanceVariableReadNode || k == NK_GlobalVariableReadNode ||
      k == NK_ClassVariableReadNode || k == NK_ConstantReadNode || k == NK_ConstantPathNode)
    return;
  F->flags[sh_find(F, l)] |= SHF_MULTI;
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

static void sh_lend(ShareFacts *F, int arg, int par, int direct) {
  if (arg < 0 || par < 0) return;
  if (F->nlend >= F->clend) {
    F->clend = F->clend ? F->clend * 2 : 64;
    F->lend_arg = realloc(F->lend_arg, sizeof(int) * (size_t)F->clend);
    F->lend_par = realloc(F->lend_par, sizeof(int) * (size_t)F->clend);
    F->lend_direct = realloc(F->lend_direct, (size_t)F->clend);
    F->lend_done = realloc(F->lend_done, (size_t)F->clend);
  }
  F->lend_arg[F->nlend] = arg;
  F->lend_par[F->nlend] = par;
  F->lend_direct[F->nlend] = (unsigned char)direct;
  F->lend_done[F->nlend] = 0;
  F->nlend++;
}

/* method mi returns value v (see ShareFacts.ret_m) */
static void sh_ret(ShareFacts *F, int mi, int v) {
  if (mi < 0 || v < 0) return;
  if (F->nret >= F->cret) {
    F->cret = F->cret ? F->cret * 2 : 64;
    F->ret_m = realloc(F->ret_m, sizeof(int) * (size_t)F->cret);
    F->ret_v = realloc(F->ret_v, sizeof(int) * (size_t)F->cret);
    F->ret_done = realloc(F->ret_done, (size_t)F->cret);
  }
  F->ret_m[F->nret] = mi;
  F->ret_v[F->nret] = v;
  F->ret_done[F->nret] = 0;
  F->nret++;
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
/* (past cap - 1 values, the rest join the last slot: a value dropped there
   would join no class) */
static void sh_args_put(ShareFacts *F, int *out, int *n, int cap, int v) {
  if (*n < cap) out[(*n)++] = v;
  else out[cap - 1] = sh_join(F, out[cap - 1], v);
}
static int sh_args_vals(ShareFacts *F, Compiler *c, int call, int *out, int cap) {
  const NodeTable *nt = c->nt;
  int args = nt_ref(nt, call, "arguments");
  int argc = 0; const int *argv = args >= 0 ? nt_arr(nt, args, "arguments", &argc) : NULL;
  int n = 0;
  for (int i = 0; i < argc; i++) {
    NodeKind k = nt_kind(nt, argv[i]);
    if (k == NK_KeywordHashNode) {
      int en = 0; const int *el = nt_arr(nt, argv[i], "elements", &en);
      for (int e = 0; e < en; e++) {
        if (nt_kind(nt, el[e]) == NK_AssocNode) sh_args_put(F, out, &n, cap, sh_val(F, c, nt_ref(nt, el[e], "value")));
        else sh_args_put(F, out, &n, cap, sh_arg_val(F, c, el[e]));
      }
      continue;
    }
    if (k == NK_BlockArgumentNode) continue;
    sh_args_put(F, out, &n, cap, sh_arg_val(F, c, argv[i]));
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

/* Bind the arguments of `call` to method mi's parameters. A parameter the
   method may lend (only read and mutated) is bound by sh_lend, the rest by
   a union. An argument the layout places nowhere joins every parameter. */
static void sh_bind(ShareFacts *F, Compiler *c, int call, int mi) {
  const NodeTable *nt = c->nt;
  Scope *m = &c->scopes[mi];
  int args = nt_ref(nt, call, "arguments");
  int argc = 0; const int *argv = args >= 0 ? nt_arr(nt, args, "arguments", &argc) : NULL;
  int claimed[64];
  int nclaimed = 0;
  for (int j = 0; j < m->nparams; j++) {
    int p = m->pnames[j] ? sh_local_of(F, c, m, m->pnames[j], m->def_node) : -1;
    int spread = -1;
    int a = arg_layout_param_node(c, m, call, j, &spread);
    if (a >= 0 && nclaimed < 64) claimed[nclaimed++] = a;
    if (p < 0) continue;
    if (a >= 0) {
      int v = sh_val(F, c, a);
      if (j == m->rest_idx || j == m->kwrest_idx) sh_union(F, sh_elem(F, p), v);
      else sh_lend(F, v, p, sh_holder_read(nt, a));
    }
    else if (spread >= 0) sh_union(F, p, sh_elem(F, sh_val(F, c, spread)));
  }
  /* any value the layout placed nowhere: every parameter, and the elements
     of a rest */
  for (int i = 0; i < argc; i++) {
    NodeKind k = nt_kind(nt, argv[i]);
    if (k == NK_BlockArgumentNode) continue;
    int vals[32], nodes[32];
    int nv = 0;
    if (k == NK_KeywordHashNode) {
      int en = 0; const int *el = nt_arr(nt, argv[i], "elements", &en);
      for (int e = 0; e < en && nv < 32; e++) {
        nodes[nv] = nt_kind(nt, el[e]) == NK_AssocNode ? nt_ref(nt, el[e], "value") : el[e];
        vals[nv] = nt_kind(nt, el[e]) == NK_AssocNode ? sh_val(F, c, nodes[nv]) : sh_arg_val(F, c, el[e]);
        nv++;
      }
    }
    else { nodes[0] = argv[i]; vals[0] = sh_arg_val(F, c, argv[i]); nv = 1; }
    for (int q = 0; q < nv; q++) {
      int placed = 0;
      for (int w = 0; w < nclaimed && !placed; w++) placed = claimed[w] == nodes[q];
      if (placed || vals[q] < 0) continue;
      for (int j = 0; j < m->nparams; j++) {
        int p = m->pnames[j] ? sh_local_of(F, c, m, m->pnames[j], m->def_node) : -1;
        if (p < 0) continue;
        sh_union(F, j == m->rest_idx || j == m->kwrest_idx ? sh_elem(F, p) : p, vals[q]);
      }
    }
  }
}

/* A block literal handed to user method mi: its parameters take what mi
   yields, its value is what mi's yields answer; a block mi keeps as &blk
   may be called from anywhere. */
static void sh_block_to_method(ShareFacts *F, Compiler *c, int blk, int mi) {
  Scope *m = &c->scopes[mi];
  if (m->yields) {
    sh_block_params(F, c, blk, sh_scope_holder(F, SHK_YIELD, mi), 1);
    sh_union(F, sh_block_val(F, c, blk), sh_scope_holder(F, SHK_BLKRET, mi));
  }
  if (m->blk_param || m->is_lowered_yield || m->is_proc_form) {
    sh_block_params(F, c, blk, F->unknown, 1);
    sh_union(F, sh_block_val(F, c, blk), F->unknown);
  }
}

static void sh_named_build(ShareFacts *F, Compiler *c);
static int sh_named_first(const struct ShNamed *a, int n, const char *name);
/* the user methods a call reaches: its plan's method and, for a switch,
   every member; -1 when they are more than cap (the caller then treats
   the call as one the walk does not follow, never as fewer methods).
   With F, the members are found through its index of methods by name. */
static int sh_targets_in(ShareFacts *F, Compiler *c, int call, int *out, int cap) {
  const CallPlan *p = cplan_user_fresh(c, call);
  if (p->mi < 0 || p->dispatch == CP_REFUSE) return 0;
  CallPlan plan = *p;
  int n = 0;
  out[n++] = plan.mi;
  if (plan.dispatch >= CP_SWITCH) {
    const char *name = c->scopes[plan.mi].name;
    if (!name) return n;
    if (F) {
      sh_named_build(F, c);
      for (int i = sh_named_first(F->scope_nm, F->nscope_nm, name);
           i < F->nscope_nm && sp_streq(F->scope_nm[i].name, name); i++) {
        int k = F->scope_nm[i].k;
        if (k == plan.mi || !cplan_virtual_member(c, call, &plan, k)) continue;
        if (n == cap) return -1;
        out[n++] = k;
      }
      return n;
    }
    for (int k = 0; k < c->nscopes; k++)
      if (k != plan.mi && c->scopes[k].name && sp_streq(c->scopes[k].name, name) &&
          cplan_virtual_member(c, call, &plan, k)) {
        if (n == cap) return -1;
        out[n++] = k;
      }
  }
  return n;
}
static int sh_targets(Compiler *c, int call, int *out, int cap) { return sh_targets_in(NULL, c, call, out, cap); }
/* does a call reach a user method (sh_targets != 0), without listing them */
static int sh_has_targets(Compiler *c, int call) {
  const CallPlan *p = cplan_user_fresh(c, call);
  return p->mi >= 0 && p->dispatch != CP_REFUSE;
}

/* the receiver family a builtin's share row is keyed by */
static TyKind sh_family(TyKind rt) {
  if (rt == TY_STRING || rt == TY_STRBUF) return TY_STRING;
  if (ty_is_array(rt) || ty_is_ptr_array(rt) || rt == TY_STR_RANGE || rt == TY_ENUMERATOR) return BOP_ANY_ARRAY;
  if (ty_is_hash(rt)) return BOP_ANY_HASH;
  if (rt == TY_ARGF) return TY_IO;
  if (rt == TY_PROC || rt == TY_METHOD || rt == TY_CURRY) return BOP_CALLABLE;
  return rt;
}

static int sh_named_cmp(const void *a, const void *b) {
  int d = strcmp(((const struct ShNamed *)a)->name, ((const struct ShNamed *)b)->name);
  return d ? d : ((const struct ShNamed *)a)->k - ((const struct ShNamed *)b)->k;
}
/* the indexes by name the walk asks per call, so a call costs a search
   rather than a pass over every class or method */
static void sh_named_build(ShareFacts *F, Compiler *c) {
  if (F->named_built) return;
  F->named_built = 1;
  int nr = 0, nw = 0;
  for (int k = 0; k < c->nclasses; k++) { nr += c->classes[k].nreaders; nw += c->classes[k].nwriters; }
  F->attr_r = malloc(sizeof *F->attr_r * (size_t)(nr + 1));
  F->attr_w = malloc(sizeof *F->attr_w * (size_t)(nw + 1));
  F->scope_nm = malloc(sizeof *F->scope_nm * (size_t)(c->nscopes + 1));
  for (int k = 0; k < c->nclasses; k++) {
    ClassInfo *ci = &c->classes[k];
    for (int i = 0; i < ci->nreaders; i++)
      if (ci->readers[i]) F->attr_r[F->nattr_r++] = (struct ShNamed){ ci->readers[i], k };
    for (int i = 0; i < ci->nwriters; i++)
      if (ci->writers[i]) F->attr_w[F->nattr_w++] = (struct ShNamed){ ci->writers[i], k };
  }
  for (int k = 0; k < c->nscopes; k++)
    if (c->scopes[k].name) F->scope_nm[F->nscope_nm++] = (struct ShNamed){ c->scopes[k].name, k };
  qsort(F->attr_r, (size_t)F->nattr_r, sizeof *F->attr_r, sh_named_cmp);
  qsort(F->attr_w, (size_t)F->nattr_w, sizeof *F->attr_w, sh_named_cmp);
  qsort(F->scope_nm, (size_t)F->nscope_nm, sizeof *F->scope_nm, sh_named_cmp);
}
/* the first entry of a sorted index whose name is `name` (n when none) */
static int sh_named_first(const struct ShNamed *a, int n, const char *name) {
  int lo = 0, hi = n;
  while (lo < hi) {
    int mid = (lo + hi) / 2;
    if (strcmp(a[mid].name, name) < 0) lo = mid + 1; else hi = mid;
  }
  return lo;
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
  sh_named_build(F, c);
  const struct ShNamed *a = *writer ? F->attr_w : F->attr_r;
  int na = *writer ? F->nattr_w : F->nattr_r;
  for (int i = sh_named_first(a, na, base + 1); i < na && sp_streq(a[i].name, base + 1); i++)
    r = sh_join(F, r, sh_ivar(F, c, a[i].k, base, node));
  return r;
}

static int sh_unknown_call(ShareFacts *F, Compiler *c, int n, int blk);

/* The share-row semantics of builtin call n. Answers its value. */
/* An iterator's block over a container's elements. Over a Hash (`hash`), a
   block of two or more plain parameters takes the key first: a key is the
   frozen copy CRuby makes as it is stored, no name for a value. */
static void sh_iter_params(ShareFacts *F, Compiler *c, int blk, int ev, int hash) {
  const NodeTable *nt = c->nt;
  int bp = hash ? nt_ref(nt, blk, "parameters") : -1;
  int pn = bp >= 0 && nt_kind(nt, bp) == NK_BlockParametersNode ? nt_ref(nt, bp, "parameters") : -1;
  int nreq = 0; const int *reqs = pn >= 0 ? nt_arr(nt, pn, "requireds", &nreq) : NULL;
  int nopt = 0; if (pn >= 0) nt_arr(nt, pn, "optionals", &nopt);
  if (nreq < 2 || nopt || nt_ref(nt, pn, "rest") >= 0 || nt_kind(nt, reqs[0]) != NK_RequiredParameterNode) {
    sh_block_params(F, c, blk, ev, 1);
    return;
  }
  for (int i = 1; i < nreq; i++) {
    sh_target(F, c, reqs[i], ev);
    sh_target(F, c, reqs[i], sh_elem(F, ev));
  }
}

/* container: 1 an Array's (or a poly receiver's) row, 2 a Hash's */
static int sh_builtin(ShareFacts *F, Compiler *c, int n, int share, int rv, int blk, int container) {
  const NodeTable *nt = c->nt;
  int args = nt_ref(nt, n, "arguments");
  int argc = 0; const int *argv = args >= 0 ? nt_arr(nt, args, "arguments", &argc) : NULL;
  int vals[64];
  int nv = sh_args_vals(F, c, n, vals, 64);
  int lit_blk = blk >= 0 && nt_kind(nt, blk) == NK_BlockNode;
  int bv = lit_blk ? sh_block_val(F, c, blk) : -1;
  switch (share) {
  case BSH_PURE:
    /* a container's block is handed its elements, whatever it answers */
    if (lit_blk && container) sh_block_params(F, c, blk, sh_elem(F, rv), 1);
    return -1;
  case BSH_ITER_FRESH: case BSH_FROZEN:
    return -1;
  case BSH_RECV: case BSH_ITER_FRESH_RECV:
    return rv;
  case BSH_ELEM:
    /* `a[i, n]`, `a[r]`: a run of elements */
    if (argc >= 2 || (argc == 1 && nt_kind(nt, argv[0]) == NK_RangeNode))
      return sh_join(F, rv, sh_elem(F, rv));
    return sh_elem(F, rv);
  case BSH_ELEM_N:
    return argc >= 1 ? sh_join(F, rv, sh_elem(F, rv)) : sh_elem(F, rv);
  case BSH_SUB:
    return rv;
  case BSH_FETCH: {
    /* a default block is handed the key it was asked for */
    if (lit_blk && nv >= 1) sh_block_params(F, c, blk, vals[0], 0);
    int r = sh_elem(F, rv);
    if (nv >= 2) r = sh_join(F, r, vals[nv - 1]);
    return sh_join(F, r, bv);
  }
  case BSH_STORE_LAST:
    if (nv > 0) sh_union(F, sh_elem(F, rv), vals[nv - 1]);
    return nv > 0 ? vals[nv - 1] : rv;
  case BSH_STORE_ALL:
    for (int i = 0; i < nv; i++) sh_union(F, sh_elem(F, rv), vals[i]);
    return rv;
  case BSH_STORE_TAIL:
    for (int i = 1; i < nv; i++) sh_union(F, sh_elem(F, rv), vals[i]);
    return rv;
  case BSH_MERGE:
    for (int i = 0; i < nv; i++) {
      sh_union(F, sh_elem(F, rv), sh_elem(F, vals[i]));
      /* zip and product pair elements up: a tuple holds the elements */
      sh_union(F, sh_elem(F, rv), vals[i]);
    }
    if (lit_blk) sh_block_params(F, c, blk, sh_elem(F, rv), 1);
    return rv;
  case BSH_ARGS: {
    /* one argument is the answer; several, an Array of them, which joins
       them only where something takes it (`p a, b` as a statement keeps
       neither) */
    if (nv == 1) return vals[0];
    if (F->unused[n]) return -1;
    int r = sh_new(F, SHK_VALUE);
    for (int i = 0; i < nv; i++) sh_union(F, sh_elem(F, r), vals[i]);
    return r;
  }
  case BSH_ARRAY_OF: {
    /* an Array is the answer itself; anything else, wrapped in one */
    if (nv != 1) return -1;
    TyKind at = c->ntype[argv[0]];
    if (ty_is_array(at) || at == TY_POLY || at == TY_UNKNOWN) return sh_join(F, vals[0], -1);
    int r = sh_new(F, SHK_VALUE);
    sh_union(F, sh_elem(F, r), vals[0]);
    return r;
  }
  case BSH_FILL1:
    if (argc >= 2) {
      int b = sh_val(F, c, argv[1]);
      sh_mark_at(F, b, SHF_MUT | (sh_holder_read(nt, argv[1]) ? 0 : SHF_INDIRECT), n);
      return b;
    }
    return -1;
  case BSH_ITER: case BSH_ITER_SEL: case BSH_ITER_FIND:
    if (lit_blk) sh_iter_params(F, c, blk, sh_elem(F, rv), container == 2);
    return share == BSH_ITER_FIND ? (argc >= 1 ? rv : sh_elem(F, rv)) : rv;
  case BSH_ITER_MAP_BANG:
    if (lit_blk) {
      sh_iter_params(F, c, blk, sh_elem(F, rv), container == 2);
      sh_union(F, sh_elem(F, rv), bv);
    }
    return rv;
  case BSH_ITER_MAP: {
    if (lit_blk) sh_iter_params(F, c, blk, sh_elem(F, rv), container == 2);
    if (!lit_blk) return rv;   /* an Enumerator over the receiver */
    /* a new container of the block's values; a flat_map's or to_h's value
       is itself a container of them */
    int r = sh_new(F, SHK_VALUE);
    sh_union(F, sh_elem(F, r), bv);
    sh_union(F, sh_elem(F, r), sh_elem(F, bv));
    return r;
  }
  case BSH_ITER_SUB:
    /* the block takes runs of elements: a run's elements are the
       receiver's, so the two levels are one */
    sh_union(F, rv, sh_elem(F, rv));
    if (lit_blk) sh_block_params(F, c, blk, rv, 1);
    return rv;
  case BSH_ITER_MEMO0: {
    const char *sym = argc >= 1 ? sh_lit_name(nt, argv[argc - 1]) : NULL;
    int memo = nv >= 1 && !sym ? vals[0] : sh_elem(F, rv);
    if (lit_blk) {
      int bp = nt_ref(nt, blk, "parameters");
      int pn = bp >= 0 ? nt_ref(nt, bp, "parameters") : -1;
      int nreq = 0; const int *reqs = pn >= 0 ? nt_arr(nt, pn, "requireds", &nreq) : NULL;
      for (int i = 0; i < nreq; i++) sh_target(F, c, reqs[i], i == 0 ? memo : sh_elem(F, rv));
      memo = sh_join(F, memo, bv);
    }
    return sym ? -1 : memo;
  }
  case BSH_ITER_MEMO1: {
    int memo = nv >= 1 ? vals[0] : -1;
    if (lit_blk) {
      int bp = nt_ref(nt, blk, "parameters");
      int pn = bp >= 0 ? nt_ref(nt, bp, "parameters") : -1;
      int nreq = 0; const int *reqs = pn >= 0 ? nt_arr(nt, pn, "requireds", &nreq) : NULL;
      for (int i = 0; i < nreq; i++) {
        int src = i == 1 ? memo : sh_elem(F, rv);
        sh_target(F, c, reqs[i], src);
        if (i == 0 && nt_kind(nt, reqs[i]) == NK_MultiTargetNode) sh_target(F, c, reqs[i], sh_elem(F, src));
      }
    }
    return memo;
  }
  case BSH_ITER_SELF:
    /* a fresh receiver (`(+"a").tap { |x| x << y }`) is one String the
       block's parameter and the answer both name, the answer a second name
       when it is used */
    if (rv < 0 && lit_blk && !F->unused[n]) {
      rv = sh_new(F, SHK_VALUE);
      F->nhold[rv] = 1;
    }
    if (lit_blk) sh_block_params(F, c, blk, rv, 0);
    return rv;
  case BSH_ITER_THEN:
    if (lit_blk) sh_block_params(F, c, blk, rv, 0);
    return bv;
  case BSH_CALL:
    return sh_unknown_call(F, c, n, blk);
  case BSH_METHOD_REF:
    /* the method it names is called from wherever the Method goes; a
       define_method body is called with what the walk does not see */
    sh_dyn_name(F, argc >= 1 ? sh_lit_name(nt, argv[0]) : NULL);
    if (lit_blk) {
      sh_block_params(F, c, blk, F->unknown, 1);
      sh_union(F, bv, F->unknown);
    }
    return -1;
  case BSH_IVAR_GET: case BSH_IVAR_SET: {
    const char *lit = argc >= 1 ? sh_lit_name(nt, argv[0]) : NULL;
    TyKind rt = nt_ref(nt, n, "receiver") >= 0 ? c->ntype[nt_ref(nt, n, "receiver")] : TY_VOID;
    int cid = ty_is_object(rt) ? ty_object_class(rt) : rt == TY_VOID ? sh_ivar_owner(c, n) : -1;
    int iv = lit && cid >= 0 ? sh_ivar(F, c, cid, lit, n) : -1;
    if (!lit || cid < 0) { F->dyn_ivars = 1; iv = F->unknown; }
    if (share == BSH_IVAR_SET && nv >= 2) sh_ivar_store(F, c, iv, argc >= 2 ? argv[1] : -1, vals[1]);
    return iv;
  }
  case BSH_EXEC:
    if (!lit_blk) return sh_unknown_call(F, c, n, blk);
    sh_block_params(F, c, blk, F->unknown, 1);
    for (int i = 0; i < nv; i++) sh_union(F, vals[i], F->unknown);
    return bv;
  default:
    return -1;
  }
}

/* A builtin call no row describes on a container: it may store any
   argument and answer anything the receiver holds. */
static int sh_container_default(ShareFacts *F, Compiler *c, int n, int rv, int blk) {
  int vals[64];
  int nv = sh_args_vals(F, c, n, vals, 64);
  for (int i = 0; i < nv; i++) {
    sh_union(F, sh_elem(F, rv), vals[i]);
    sh_union(F, sh_elem(F, rv), sh_elem(F, vals[i]));
  }
  if (blk >= 0 && nt_kind(c->nt, blk) == NK_BlockNode) {
    sh_union(F, rv, sh_elem(F, rv));
    sh_block_params(F, c, blk, rv, 1);
    sh_union(F, rv, sh_block_val(F, c, blk));
  }
  return sh_join(F, rv, sh_elem(F, rv));
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

/* `Klass.new(...)`: the class's initialize, a Struct's members */
static int sh_new_call(ShareFacts *F, Compiler *c, int n, int recv, int blk) {
  const NodeTable *nt = c->nt;
  NodeKind rk = nt_kind(nt, recv);
  int cid = (rk == NK_ConstantReadNode || rk == NK_ConstantPathNode)
            ? comp_class_index(c, nt_str(nt, recv, "name")) : -1;
  if (cid < 0) return -2;
  ClassInfo *ci = &c->classes[cid];
  /* an exception keeps its message, which #message hands back */
  if (class_is_exc_subclass(c, cid)) {
    int vals[64];
    int nv = sh_args_vals(F, c, n, vals, 64);
    for (int k = 0; k < nv; k++) sh_union(F, vals[k], F->unknown);
  }
  if (ci->is_struct) {
    int vals[64];
    int nv = sh_args_vals(F, c, n, vals, 64);
    int args = nt_ref(nt, n, "arguments"), argc = 0;
    const int *argv = args >= 0 ? nt_arr(nt, args, "arguments", &argc) : NULL;
    for (int i = 0; i < ci->nivars; i++) {
      int iv = sh_ivar(F, c, cid, ci->ivars[i], n);
      for (int k = 0; k < nv; k++) sh_ivar_store(F, c, iv, argc == nv ? argv[k] : -1, vals[k]);
    }
    return -1;
  }
  int mi = comp_method_in_chain(c, cid, "initialize", NULL);
  if (mi < 0) return ci->def_node >= 0 ? -1 : -2;
  sh_bind(F, c, n, mi);
  if (blk >= 0 && nt_kind(nt, blk) == NK_BlockNode) sh_block_to_method(F, c, blk, mi);
  return -1;
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

  /* `Thread.new(a) { |t| }` hands the block its arguments, and a resume
     the program names, its Fiber's block; any other resume hands a Fiber's
     block what the walk does not see. A Thread's value and a Fiber's
     answers go where the walk does not follow. */
  int fb = an_fiber_new_block(c, n);
  if (fb >= 0) {
    sh_block_params(F, c, fb, F->unknown, 1);
    sh_union(F, sh_block_val(F, c, fb), F->unknown);
    return -1;
  }
  int tb = an_thread_arg_block(c, n);
  if (tb >= 0) {
    int vals[64];
    int nv = sh_args_vals(F, c, n, vals, 64), a = -1;
    for (int i = 0; i < nv; i++) a = sh_join(F, a, vals[i]);
    sh_block_params(F, c, tb, a, 1);
    /* Thread.new (a constant receiver; Fiber#resume's is the fiber) */
    if (nt_kind(nt, nt_ref(nt, n, "receiver")) == NK_ConstantReadNode) {
      sh_union(F, sh_block_val(F, c, tb), F->unknown);
      return -1;
    }
  }

  /* a user method */
  int tg[64];
  int ntg = sh_targets_in(F, c, n, tg, 64);
  if (ntg < 0) return sh_unknown_call(F, c, n, blk);
  if (ntg == 0 && recv >= 0 && bop_share_named(BOP_ANY_RECV, name) == BSH_NEW) {
    int r = sh_new_call(F, c, n, recv, blk);
    if (r != -2) return r;
    if (rt == TY_CLASS || rt == TY_POLY || rt == TY_UNKNOWN) {
      /* a class held in a variable: any initialize. Its arguments join
         any_new_pos and any_new_kw, and its block the list every
         initialize takes once after the walk (sh_settle_any_new): binding
         each such call to every initialize was a pass over every method
         per call. */
      F->any_new_used = 1;
      for (int i = 0, pos = 0; i < argc; i++) {
        NodeKind ak = nt_kind(nt, argv[i]);
        if (ak == NK_BlockArgumentNode) continue;
        if (ak == NK_KeywordHashNode) {
          int en = 0; const int *el = nt_arr(nt, argv[i], "elements", &en);
          for (int e = 0; e < en; e++) {
            int ev = nt_kind(nt, el[e]) == NK_AssocNode ? sh_val(F, c, nt_ref(nt, el[e], "value")) : sh_arg_val(F, c, el[e]);
            if (F->any_new_kw < 0) F->any_new_kw = sh_new(F, SHK_VALUE);
            sh_union(F, F->any_new_kw, ev);
          }
          continue;
        }
        /* a splat may land in any position */
        int v = sh_arg_val(F, c, argv[i]);
        for (int j = ak == NK_SplatNode ? 0 : (pos < 16 ? pos : 15); j < 16; j++) {
          if (F->any_new_pos[j] < 0) F->any_new_pos[j] = sh_new(F, SHK_VALUE);
          sh_union(F, F->any_new_pos[j], ak == NK_SplatNode ? sh_elem(F, v) : v);
          if (ak != NK_SplatNode) break;
        }
        pos++;
      }
      if (blk >= 0 && nt_kind(nt, blk) == NK_BlockNode) {
        if (F->nany_blk >= F->cany_blk) {
          F->cany_blk = F->cany_blk ? F->cany_blk * 2 : 8;
          F->any_new_blk = realloc(F->any_new_blk, sizeof(int) * (size_t)F->cany_blk);
        }
        F->any_new_blk[F->nany_blk++] = blk;
      }
      return sh_join(F, -1, rt == TY_CLASS ? -1 : sh_unknown_call(F, c, n, blk));
    }
  }
  if (ntg > 0) {
    int r = -1;
    for (int i = 0; i < ntg; i++) {
      sh_bind(F, c, n, tg[i]);
      r = sh_join(F, r, sh_scope_holder(F, SHK_RET, tg[i]));
      if (blk >= 0 && nt_kind(nt, blk) == NK_BlockNode) sh_block_to_method(F, c, blk, tg[i]);
      /* a block passed as a value (`&proc`, `&method(:m)`): what the method
         yields goes where the walk does not follow */
      else if (blk >= 0 && c->scopes[tg[i]].yields) {
        sh_union(F, sh_scope_holder(F, SHK_YIELD, tg[i]), F->unknown);
        sh_union(F, sh_scope_holder(F, SHK_BLKRET, tg[i]), F->unknown);
      }
      /* a method of a String reopen: self is the receiver */
      if (rv >= 0 && c->scopes[tg[i]].class_id >= 0 &&
          c->scopes[tg[i]].class_id == comp_class_index(c, "String"))
        sh_union(F, rv, F->unknown);
    }
    /* a poly receiver may be a builtin as well */
    if (rt != TY_POLY && rt != TY_UNKNOWN) return r;
    return sh_join(F, r, sh_container_default(F, c, n, rv, blk));
  }

  /* an attr reader or writer */
  if (argc <= 1 && (recv < 0 || ty_is_object(rt) || rt == TY_POLY || rt == TY_UNKNOWN)) {
    int writer = 0;
    int iv = sh_attr_ivars(F, c, name, n, &writer);
    if (iv >= 0 && writer == (argc == 1)) {
      int r = iv;
      if (writer) {
        int vals[1];
        int nv = sh_args_vals(F, c, n, vals, 1);
        if (nv == 1) sh_ivar_store(F, c, iv, argc == 1 ? argv[0] : -1, vals[0]);
        r = nv == 1 ? vals[0] : -1;
      }
      if (rt != TY_POLY && rt != TY_UNKNOWN) return r;
      return sh_join(F, r, sh_container_default(F, c, n, rv, blk));
    }
  }

  /* a builtin */
  if (recv < 0) {
    int s = bop_share_named(BOP_KERNEL, name);
    if (!s) s = bop_share_named(BOP_ANY_RECV, name);
    return s ? sh_builtin(F, c, n, s, rv, blk, 0) : sh_unknown_call(F, c, n, blk);
  }
  if (rt == TY_POLY || rt == TY_UNKNOWN) {
    /* a proc or a Method in the box: called with what it is handed */
    if (bop_share_named(BOP_CALLABLE, name) == BSH_CALL) {
      sh_unknown_call(F, c, n, blk);
      return sh_join(F, F->unknown, sh_container_default(F, c, n, rv, blk));
    }
    /* any receiver it may be: an Array's or a Hash's row (a String's keeps
       its arguments least), or the container default */
    int s = bop_share_named(BOP_ANY_ARRAY, name);
    if (!s) s = bop_share_named(BOP_ANY_HASH, name);
    if (!s) s = bop_share_named(BOP_ANY_RECV, name);
    if (s) return sh_builtin(F, c, n, s, rv, blk, 1);
    return sh_container_default(F, c, n, rv, blk);
  }
  TyKind fam = sh_family(rt);
  int s = bop_share_named(fam, name);
  /* the Strings' answers-self names the face table lists */
  if (!s && fam == TY_STRING && str_self_call(nt, n)) s = BSH_RECV;
  if (!s) s = bop_share_named(BOP_ANY_RECV, name);
  /* a family's "*" row is its default; a container's "*" is Array#*, and
     its default is sh_container_default (a block binds what it holds) */
  if (!s && fam != BOP_ANY_ARRAY && fam != BOP_ANY_HASH) s = bop_share(fam, name);
  if (s) return sh_builtin(F, c, n, s, rv, blk, fam == BOP_ANY_HASH ? 2 : fam == BOP_ANY_ARRAY);
  if (fam == BOP_ANY_ARRAY || fam == BOP_ANY_HASH) return sh_container_default(F, c, n, rv, blk);
  return sh_unknown_call(F, c, n, blk);
}

static int sh_super(ShareFacts *F, Compiler *c, int n) {
  const NodeTable *nt = c->nt;
  int blk = nt_ref(nt, n, "block");
  int tg[64];
  int ntg = sh_targets_in(F, c, n, tg, 64);
  if (ntg < 0) return sh_unknown_call(F, c, n, blk);
  int cur = sh_method_index(c, n);
  int r = -1;
  for (int i = 0; i < ntg; i++) {
    Scope *m = &c->scopes[tg[i]];
    if (nt_kind(nt, n) == NK_ForwardingSuperNode && cur >= 0) {
      /* zsuper hands on this method's own parameters, and its block */
      Scope *s = &c->scopes[cur];
      for (int j = 0; j < s->nparams; j++) {
        int a = s->pnames[j] ? sh_local_of(F, c, s, s->pnames[j], n) : -1;
        for (int k = 0; k < m->nparams; k++)
          if (m->nparams != s->nparams || k == j)
            sh_union(F, a, m->pnames[k] ? sh_local_of(F, c, m, m->pnames[k], n) : -1);
      }
      sh_union(F, sh_scope_holder(F, SHK_YIELD, cur), sh_scope_holder(F, SHK_YIELD, tg[i]));
      sh_union(F, sh_scope_holder(F, SHK_BLKRET, cur), sh_scope_holder(F, SHK_BLKRET, tg[i]));
    }
    else {
      int vals[64];
      int nv = sh_args_vals(F, c, n, vals, 64);
      for (int q = 0; q < nv; q++)
        for (int k = 0; k < m->nparams; k++) {
          int p = m->pnames[k] ? sh_local_of(F, c, m, m->pnames[k], n) : -1;
          sh_union(F, k == m->rest_idx || k == m->kwrest_idx ? sh_elem(F, p) : p, vals[q]);
        }
    }
    if (blk >= 0 && nt_kind(nt, blk) == NK_BlockNode) sh_block_to_method(F, c, blk, tg[i]);
    r = sh_join(F, r, sh_scope_holder(F, SHK_RET, tg[i]));
  }
  if (ntg == 0) return sh_unknown_call(F, c, n, blk);
  return r;
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
    if (nt_kind(nt, n) != NK_InstanceVariableOperatorWriteNode) sh_ivar_store(F, c, l, nt_ref(nt, n, "value"), v);
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
    sh_ivar_store(F, c, iv, nt_ref(nt, n, "value"), v);
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
      if (nv == 1) sh_ret(F, mi, vals[i]);
      else sh_union(F, mi >= 0 ? sh_scope_holder(F, SHK_RET, mi) : -1, vals[i]);
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
    return sh_super(F, c, n);
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
  if (v >= 0 && nt_kind(c->nt, n) == NK_CallNode && !F->unused[n]) F->flags[sh_find(F, v)] |= SHF_OUT;
  F->nval[n] = v;
  return v;
}

/* ---- lending ---- */

/* A parameter its method only reads and mutates: no write, nothing else in
   its class, not captured by a proc that can outlive the call. */
static int sh_lendable(ShareFacts *F, Compiler *c, int p) {
  int hi = F->hidx[p];
  if (hi < 0 || F->h[hi].kind != SHK_LOCAL) return 0;
  Scope *s = &c->scopes[F->h[hi].scope];
  LocalVar *lv = &s->locals[F->h[hi].local];
  if (!lv->is_param || lv->is_block_param || lv->cell_outlives) return 0;
  if (lv->type != TY_STRING && lv->type != TY_STRBUF) return 0;
  if (F->own[p] & SHE_WRITTEN) return 0;
  int r = sh_find(F, p);
  return F->nmem[r] == 1 && !(F->flags[r] & SHF_UNKNOWN);
}

/* A method's String built in its own locals and returned is handed over:
   the locals die with the call, so the caller's name for it is the only
   one, and the two need not share (`out = +""; out << x; out`, the
   accumulator a builder returns). The return joins the method's value only
   once its class reaches anything else: a parameter, a captured local,
   another method's local or value, an ivar, a container (whose elements
   could be named elsewhere), or what the walk does not follow. */
static int sh_settle_rets(ShareFacts *F) {
  int any = 0;
  for (int changed = 1; changed; ) {
    changed = 0;
    for (int i = 0; i < F->nret; i++) {
      if (F->ret_done[i]) continue;
      int r = sh_find(F, F->ret_v[i]);
      if (F->lsc[r] == F->ret_m[i] && F->elem[r] < 0 && !(F->flags[r] & SHF_UNKNOWN)) continue;
      sh_union(F, sh_scope_holder(F, SHK_RET, F->ret_m[i]), F->ret_v[i]);
      F->ret_done[i] = 1;
      changed = any = 1;
    }
  }
  return any;
}

static void sh_settle_lends(ShareFacts *F, Compiler *c) {
  for (int changed = 1; changed; ) {
    changed = 0;
    for (int i = 0; i < F->nlend; i++) {
      if (F->lend_done[i] || sh_lendable(F, c, F->lend_par[i])) continue;
      sh_union(F, F->lend_arg[i], F->lend_par[i]);
      F->lend_done[i] = 1;
      changed = 1;
    }
    if (sh_settle_rets(F)) changed = 1;
  }
  /* a lent parameter's mutation is its argument's */
  for (int changed = 1; changed; ) {
    changed = 0;
    for (int i = 0; i < F->nlend; i++) {
      if (F->lend_done[i]) continue;
      int rp = sh_find(F, F->lend_par[i]);
      if (!(F->flags[rp] & SHF_MUT)) continue;
      int ra = sh_find(F, F->lend_arg[i]);
      unsigned want = SHF_MUT | (F->lend_direct[i] ? 0 : SHF_INDIRECT);
      if ((F->flags[ra] & want) == want) continue;
      F->flags[ra] |= (unsigned char)want;
      changed = 1;
    }
  }
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
      anchored[e] = F->nhold[e] - F->nelem[e] > 0 || (F->flags[e] & (SHF_UNKNOWN | SHF_OUT));
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
  F->anchored = anchored;
}

/* A value that is a frozen String (a literal, a freeze, a -@): nothing can
   change it in place, so a name holding only such values needs no handle. */
static int sh_frozen_value(Compiler *c, int v) {
  const NodeTable *nt = c->nt;
  if (v < 0) return 1;
  NodeKind k = nt_kind(nt, v);
  if (k == NK_StringNode) return 1;
  if (k == NK_CallNode && bop_share_named(TY_STRING, nt_str(nt, v, "name")) == BSH_FROZEN) return 1;
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

/* Every class's initialize (the last def of the name in it) takes what a
   `k.new(...)` on a class held in a variable hands it: the arguments joined
   in any_new reach each of its parameters, and each block it is given. */
static void sh_settle_any_new(ShareFacts *F, Compiler *c) {
  if (!F->any_new_used && F->nany_blk == 0) return;
  const NodeTable *nt = c->nt;
  int *last = malloc(sizeof(int) * (size_t)(c->nclasses > 0 ? c->nclasses : 1));
  for (int k = 0; k < c->nclasses; k++) last[k] = -1;
  for (int k = 0; k < c->nclasses; k++) {
    int s = comp_method_in_class(c, k, "initialize");
    if (s >= 0 && c->scopes[s].def_node >= 0 && !c->scopes[s].is_cmethod) last[k] = s;
  }
  for (int k = 0; k < c->nclasses; k++) {
    int mi = last[k];
    if (mi < 0) continue;
    Scope *m = &c->scopes[mi];
    int pn = nt_ref(nt, m->def_node, "parameters");
    if (F->any_new_used && pn >= 0) {
      int nr = 0, no = 0, npo = 0, nk = 0;
      const int *rq = nt_arr(nt, pn, "requireds", &nr), *op = nt_arr(nt, pn, "optionals", &no);
      const int *po = nt_arr(nt, pn, "posts", &npo), *kw = nt_arr(nt, pn, "keywords", &nk);
      int rest = nt_ref(nt, pn, "rest"), kwr = nt_ref(nt, pn, "keyword_rest");
      /* a required after an optional or a rest takes a position only the
         call's own count decides: each positional parameter then takes
         every position */
      int irregular = npo > 0;
      for (int j = 0; j < nr + no + npo; j++) {
        int pnode = j < nr ? rq[j] : j < nr + no ? op[j - nr] : po[j - nr - no];
        const char *pnm = nt_str(nt, pnode, "name");
        int p = pnm ? sh_local_of(F, c, m, pnm, m->def_node) : -1;
        if (p < 0) continue;
        if (irregular) { for (int b = 0; b < 16; b++) if (F->any_new_pos[b] >= 0) sh_union(F, p, F->any_new_pos[b]); }
        else if (j < 15) { if (F->any_new_pos[j] >= 0) sh_union(F, p, F->any_new_pos[j]); }
        else if (F->any_new_pos[15] >= 0) sh_union(F, p, F->any_new_pos[15]);
      }
      if (rest >= 0 && nt_str(nt, rest, "name")) {
        int p = sh_local_of(F, c, m, nt_str(nt, rest, "name"), m->def_node);
        for (int b = nr + no < 16 ? nr + no : 15; b < 16; b++)
          if (F->any_new_pos[b] >= 0) sh_union(F, sh_elem(F, p), F->any_new_pos[b]);
      }
      for (int j = 0; j < nk; j++) {
        const char *pnm = nt_str(nt, kw[j], "name");
        int p = pnm ? sh_local_of(F, c, m, pnm, m->def_node) : -1;
        if (F->any_new_kw >= 0) sh_union(F, p, F->any_new_kw);
      }
      if (kwr >= 0 && nt_str(nt, kwr, "name") && F->any_new_kw >= 0)
        sh_union(F, sh_elem(F, sh_local_of(F, c, m, nt_str(nt, kwr, "name"), m->def_node)), F->any_new_kw);
    }
    for (int b = 0; b < F->nany_blk; b++) sh_block_to_method(F, c, F->any_new_blk[b], mi);
  }
  free(last);
}

static void sh_free(ShareFacts *F) {
  if (!F) return;
  for (int i = 0; i < F->nh; i++) free((char *)F->h[i].name);
  free(F->parent); free(F->elem); free(F->nhold); free(F->nmem); free(F->nelem); free(F->hidx);
  free(F->owner); free(F->hcount); free(F->anchored); free(F->mconst);
  free(F->mut_n); free(F->mut_v);
  free(F->lsc); free(F->ret_m); free(F->ret_v); free(F->ret_done); free(F->unused);
  free(F->kind); free(F->flags); free(F->own);
  free(F->h); free(F->helem); free(F->bucket); free(F->hnext); free(F->nval);
  free(F->lend_arg); free(F->lend_par); free(F->lend_direct); free(F->lend_done);
  free(F->dyn); free(F->union_stack);
  free(F->any_new_blk); free(F->attr_r); free(F->attr_w); free(F->scope_nm);
  free(F);
}

/* Node n's value is dropped, and so is that of each node whose value n
   forwards as its own (sh_val's arms): a body's last statement, a
   conditional's or a case's branches, a begin's, its rescues' and its
   else's, parentheses, and the operands of `&&`, `||` and a rescue
   modifier. `if c then p a, b end` as a statement keeps neither a nor b. */
static void sh_mark_unused(ShareFacts *F, const NodeTable *nt, int n) {
  if (n < 0 || n >= F->nnodes) return;
  F->unused[n] = 1;
  switch (nt_kind(nt, n)) {
  case NK_StatementsNode: {
    int bn = 0; const int *bv = nt_arr(nt, n, "body", &bn);
    if (bn > 0) sh_mark_unused(F, nt, bv[bn - 1]);
    return;
  }
  case NK_ParenthesesNode:
    sh_mark_unused(F, nt, nt_ref(nt, n, "body"));
    return;
  case NK_BeginNode: {
    sh_mark_unused(F, nt, nt_ref(nt, n, "statements"));
    for (int rc = nt_ref(nt, n, "rescue_clause"); rc >= 0; rc = nt_ref(nt, rc, "subsequent"))
      sh_mark_unused(F, nt, nt_ref(nt, rc, "statements"));
    int el = nt_ref(nt, n, "else_clause");
    if (el >= 0) sh_mark_unused(F, nt, el);
    return;
  }
  case NK_IfNode:
    sh_mark_unused(F, nt, nt_ref(nt, n, "statements"));
    sh_mark_unused(F, nt, nt_ref(nt, n, "subsequent"));
    return;
  case NK_UnlessNode:
    sh_mark_unused(F, nt, nt_ref(nt, n, "statements"));
    sh_mark_unused(F, nt, nt_ref(nt, n, "else_clause"));
    return;
  case NK_ElseNode:
    sh_mark_unused(F, nt, nt_ref(nt, n, "statements"));
    return;
  case NK_CaseNode: case NK_CaseMatchNode: {
    int nw = 0; const int *ws = nt_arr(nt, n, "conditions", &nw);
    for (int i = 0; i < nw; i++) sh_mark_unused(F, nt, nt_ref(nt, ws[i], "statements"));
    sh_mark_unused(F, nt, nt_ref(nt, n, "else_clause"));
    return;
  }
  case NK_AndNode: case NK_OrNode:
    sh_mark_unused(F, nt, nt_ref(nt, n, "left"));
    sh_mark_unused(F, nt, nt_ref(nt, n, "right"));
    return;
  case NK_RescueModifierNode:
    sh_mark_unused(F, nt, nt_ref(nt, n, "expression"));
    sh_mark_unused(F, nt, nt_ref(nt, n, "rescue_expression"));
    return;
  default:
    return;
  }
}

/* the last statement of statements node st drops its value */
static void sh_mark_last_unused(ShareFacts *F, const NodeTable *nt, int st) {
  int bn = 0; const int *bv = st >= 0 && nt_kind(nt, st) == NK_StatementsNode ? nt_arr(nt, st, "body", &bn) : NULL;
  if (bn > 0) sh_mark_unused(F, nt, bv[bn - 1]);
}

static ShareFacts *sh_build(Compiler *c, int closed) {
  const NodeTable *nt = c->nt;
  ShareFacts *F = calloc(1, sizeof *F);
  F->closed = closed;
  F->unknown = sh_new(F, SHK_UNKNOWN);
  F->flags[F->unknown] = SHF_UNKNOWN;
  F->elem[F->unknown] = F->unknown;
  for (int j = 0; j < 16; j++) F->any_new_pos[j] = -1;
  F->any_new_kw = -1;
  F->nnodes = nt->count;
  F->nval = malloc(sizeof(int) * (size_t)(F->nnodes > 0 ? F->nnodes : 1));
  for (int i = 0; i < F->nnodes; i++) F->nval[i] = -2;
  sh_mutable_consts(F, c);
  F->unused = calloc((size_t)(F->nnodes > 0 ? F->nnodes : 1), 1);
  NT_FOREACH_KIND(nt, NK_StatementsNode, st) {
    int bn = 0; const int *bv = nt_arr(nt, st, "body", &bn);
    for (int i = 0; i + 1 < bn; i++) sh_mark_unused(F, nt, bv[i]);
  }
  /* the program's last statement, and a class body's, answer nothing */
  for (int k = 0; k < 3; k++) {
    if (k == 0) {
      int root = nt->root_id;
      int st = root >= 0 ? nt_ref(nt, root, "statements") : -1;
      sh_mark_last_unused(F, nt, st);
      continue;
    }
    NT_FOREACH_KIND(nt, k == 1 ? NK_ClassNode : NK_ModuleNode, pn) sh_mark_last_unused(F, nt, nt_ref(nt, pn, "body"));
  }
  for (int n = 0; n < F->nnodes; n++) sh_val(F, c, n);
  sh_settle_any_new(F, c);
  /* each method's value is its body's last, and its defaults bind its
     parameters */
  for (int mi = 0; mi < c->nscopes; mi++) {
    Scope *m = &c->scopes[mi];
    if (m->def_node < 0) continue;
    if (m->body >= 0) sh_ret(F, mi, sh_stmts_val(F, c, m->body));
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
  sh_settle_lends(F, c);
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


static int sh_node_root(const ShareFacts *F, int n, int elems);
int share_node_anchored(const Compiler *c, int n) {
  const ShareFacts *F = c->share;
  int r = sh_node_root(F, n, 0);
  return r >= 0 && F->anchored && F->anchored[r];
}
int share_node_elems_share(const Compiler *c, int n) {
  const ShareFacts *F = c->share;
  int r = sh_node_root(F, n, 1);
  return r >= 0 && repr_str_class_shares(F->flags[r], sh_class_holders(F, r));
}

/* ---- master's route refusals under the flag (share.h) ---- */

ShareRoute share_route(int site, int value, int elems) {
  ShareRoute r;
  memset(&r, 0, sizeof r);
  r.site = site;
  r.value = value;
  r.elems = elems;
  r.to = -1;
  r.carry = -1;
  return r;
}

static int sh_ivar_owner(Compiler *c, int node);
/* A String method answering its receiver or nil (bop_share_self_answer:
   a bang method, an iterator given a block) called on a slot that holds
   the shared handle -- a local, a global, a constant, a class variable or
   an ivar: its value is that slot's String, or nil. */
static int sh_bang_self_slot(const Compiler *c, int v) {
  const NodeTable *nt = c->nt;
  if (v < 0 || nt_kind(nt, v) != NK_CallNode ||
      !bop_share_self_answer(nt_str(nt, v, "name"), nt_ref(nt, v, "block") >= 0)) return 0;
  int r = nt_ref(nt, v, "receiver");
  if (r < 0) return 0;
  if (nt_kind(nt, r) == NK_LocalVariableReadNode) return repr_of(c, r).kind == RK_STRBUF;
  if (repr_static_share(c, r)) return 1;
  if (nt_kind(nt, r) == NK_InstanceVariableReadNode) {
    const char *nm = nt_str(nt, r, "name");
    int cid = nm ? sh_ivar_owner((Compiler *)c, r) : -1;
    int iv = cid >= 0 ? comp_ivar_index(&c->classes[cid], nm) : -1;
    return iv >= 0 && repr_of_ivar(c, cid, iv).share;
  }
  return 0;
}
/* Does node n hand over the shared handle (or a box holding it), not a
   copy of its bytes? */
static int sh_carries_handle(const Compiler *c, int n) {
  Repr r = repr_of(c, n);
  /* a bang method on a handle local: a write hands over the local's handle
     (emit_strbuf_value) */
  return r.kind == RK_STRBUF || r.strbuf_src != RS_NONE || sh_bang_self_slot(c, n);
}

/* The class of node n's value (with elems, of its elements), or -1. */
static int sh_node_root(const ShareFacts *F, int n, int elems) {
  if (!F || n < 0 || n >= F->nnodes || F->nval[n] < 0) return -1;
  int r = sh_root(F, F->nval[n]);
  if (elems) r = F->elem[r] >= 0 ? sh_root(F, F->elem[r]) : -1;
  return r;
}

/* The class the route reaches: local to_name in the scope of node `to`,
   or node `to`'s value (with to_elems, its elements). */
static int sh_route_to_root(const Compiler *c, const ShareRoute *q) {
  const ShareFacts *F = c->share;
  if (!q->to_name) return sh_node_root(F, q->to, q->to_elems);
  Scope *s = q->to >= 0 ? comp_scope_of((Compiler *)c, q->to) : NULL;
  LocalVar *lv = s ? scope_local(s, q->to_name) : NULL;
  int h = lv ? share_local_holder(c, (int)(s - c->scopes), (int)(lv - s->locals)) : -1;
  return h >= 0 ? sh_root(F, F->helem[h]) : -1;
}

/* The route's answer from the final facts: 1 when it compiles as the rule
   says, 0 when it has to stay refused. The facts must see the route (the
   String and the holder it reaches in one class): a route the walk does
   not follow says nothing about who else can see the copy. Then a class
   the rule does not share has one name, and the copy is unobservable; one
   it shares holds the handle in every holder (seal's holder check), and
   the carrying node hands it along. */
static int sh_route_ok(const Compiler *c, const ShareRoute *q) {
  const ShareFacts *F = c->share;
  int v = sh_node_root(F, q->value, q->elems);
  if (v < 0) return 0;
  if (q->to >= 0 && sh_route_to_root(c, q) != v) return 0;
  if (!repr_str_class_shares(F->flags[v], sh_class_holders(F, v))) return 1;
  return q->carry < 0 || sh_carries_handle(c, q->carry);
}

int share_route_defer(Compiler *c, const ShareRoute *q, const char *msg) {
  if (!c->share_strings) return 0;
  if (repr_sealed()) return sh_route_ok(c, q);
  for (int i = 0; i < c->nshare_route; i++) {
    const ShareRoute *r = &c->share_route[i];
    if (r->site == q->site && r->value == q->value && r->elems == q->elems && r->to == q->to &&
        r->to_elems == q->to_elems && r->carry == q->carry &&
        (r->to_name == q->to_name || (r->to_name && q->to_name && sp_streq(r->to_name, q->to_name))))
      return 1;
  }
  if (c->nshare_route >= c->cshare_route) {
    c->cshare_route = c->cshare_route ? c->cshare_route * 2 : 16;
    c->share_route = realloc(c->share_route, sizeof(ShareRoute) * (size_t)c->cshare_route);
  }
  ShareRoute *r = &c->share_route[c->nshare_route++];
  *r = *q;
  r->msg = strdup(msg);
  return 1;
}

void share_routes_check(Compiler *c) {
  for (int i = 0; i < c->nshare_route; i++) {
    const ShareRoute *r = &c->share_route[i];
    const char *stats = getenv("SPINEL_SHARE_STATS");
    if (stats && stats[0] == '2')
      fprintf(stderr, "share-route: site %d value %d%s to %d%s%s%s carry %d ok=%d\n", r->site, r->value,
              r->elems ? " (elements)" : "", r->to, r->to_elems ? " (elements)" : "",
              r->to_name ? " local " : "", r->to_name ? r->to_name : "", r->carry, sh_route_ok(c, r));
    if (!sh_route_ok(c, r)) unsupported_feature(c, r->site, r->msg);
  }
}

void share_routes_free(Compiler *c) {
  for (int i = 0; i < c->nshare_route; i++) free(c->share_route[i].msg);
  free(c->share_route);
  c->share_route = NULL;
  c->nshare_route = c->cshare_route = 0;
}

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

/* ---- a Hash key borrows a handle's bytes ----

   A String the rule shares is an sp_String * handle, and a String-keyed
   Hash call handed one as its key read it out through the handle's read
   face, a full copy, before the store copied it again (sp_hash_key_str, the
   copy CRuby makes when it dups and freezes a new key) or the lookup only
   compared it. The key can take the handle's live buffer instead, as
   strbuf_read_raw already lets a builtin accessor do (#5745), when nothing
   runs between the borrow and the call: the receiver and every other
   operand are plain reads. (A read-only parameter and a bound C function
   borrow through master's own passes, mark_param_read_only_operands and
   mark_native_str_operands, which run under the flag too.) */

/* An operand evaluated beside the borrowed argument: a variable read, a
   literal, or scalar arithmetic over those. Nothing in it can change the
   String between the borrow and the call. */
static int sh_plain_operand(Compiler *c, int n) {
  const NodeTable *nt = c->nt;
  if (n < 0) return 1;
  switch (nt_kind(nt, n)) {
  case NK_LocalVariableReadNode: case NK_InstanceVariableReadNode: case NK_GlobalVariableReadNode:
  case NK_ConstantReadNode: case NK_SelfNode: case NK_IntegerNode: case NK_FloatNode:
  case NK_StringNode: case NK_SymbolNode: case NK_NilNode: case NK_TrueNode: case NK_FalseNode:
    return 1;
  case NK_CallNode: {
    int recv = nt_ref(nt, n, "receiver");
    TyKind rt = recv >= 0 ? c->ntype[recv] : TY_VOID;
    if ((rt != TY_INT && rt != TY_FLOAT) || nt_ref(nt, n, "block") >= 0) return 0;
    if (sh_has_targets(c, n) || !sh_plain_operand(c, recv)) return 0;
    int args = nt_ref(nt, n, "arguments");
    int argc = 0; const int *argv = args >= 0 ? nt_arr(nt, args, "arguments", &argc) : NULL;
    for (int i = 0; i < argc; i++)
      if (!sh_plain_operand(c, argv[i])) return 0;
    return 1;
  }
  default:
    return 0;
  }
}

/* Is argument node a a read of a String slot held as the shared handle,
   which reads out through the copying face? */
static int sh_handle_read(Compiler *c, int a) {
  const NodeTable *nt = c->nt;
  if (c->strbuf_box[a] || c->strbuf_handle_demand[a] || c->strbuf_read_raw[a]) return 0;
  if (nt_kind(nt, a) == NK_LocalVariableReadNode) {
    const char *ln = nt_str(nt, a, "name");
    LocalVar *lv = ln ? scope_local(comp_scope_of(c, a), ln) : NULL;
    return lv && lv->type == TY_STRBUF && repr_of_slot(c, lv).kind == RK_STRBUF;
  }
  if (nt_kind(nt, a) == NK_InstanceVariableReadNode) {
    const char *nm = nt_str(nt, a, "name");
    int cid = nm ? sh_ivar_owner(c, a) : -1;
    int iv = cid >= 0 ? comp_ivar_index(&c->classes[cid], nm) : -1;
    return iv >= 0 && c->classes[cid].ivar_types[iv] == TY_STRBUF;
  }
  return 0;
}


/* Is call n a builtin String-keyed Hash call whose first argument is a key
   it only compares, or copies to store? */
static int sh_hash_key_call(Compiler *c, int n) {
  const NodeTable *nt = c->nt;
  int recv = nt_ref(nt, n, "receiver");
  const char *name = nt_str(nt, n, "name");
  if (recv < 0 || !name) return 0;
  TyKind rt = c->ntype[recv];
  if (rt != TY_STR_INT_HASH && rt != TY_STR_STR_HASH && rt != TY_STR_POLY_HASH) return 0;
  if (sh_has_targets(c, n)) return 0;
  if (is_store_alias(name)) return rt != TY_STR_POLY_HASH;
  return is_hash_key_lookup(name);
}


int share_mark_borrows(Compiler *c) {
  if (!c->share_strings) return 0;
  const NodeTable *nt = c->nt;
  int marked = 0;
  NT_FOREACH_KIND(nt, NK_CallNode, n) {
    int args = nt_ref(nt, n, "arguments");
    int argc = 0; const int *argv = args >= 0 ? nt_arr(nt, args, "arguments", &argc) : NULL;
    if (argc == 0 || nt_ref(nt, n, "block") >= 0) continue;
    /* a String-keyed Hash's key: a lookup only compares it, and a store
       copies it (sp_hash_key_str), as CRuby dups and freezes it */
    if (sh_hash_key_call(c, n) && sh_handle_read(c, argv[0]) &&
        sh_plain_operand(c, nt_ref(nt, n, "receiver"))) {
      int plain = 1;
      for (int i = 1; i < argc && plain; i++) plain = sh_plain_operand(c, argv[i]);
      if (plain) { c->strbuf_read_raw[argv[0]] = 1; marked++; }
    }
  }
  c->share_borrows = marked;
  return marked;
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
