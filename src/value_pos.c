/* value_pos.c -- the nodes an expression's value can come from (see
   value_pos.h).

   The walk is a depth-first loop over a stack of items still to visit. An item
   is a node and the place it hangs from; a visit peels the wrappers
   (parentheses, statements, else and an `in` clause) in a loop, then either
   pushes the node's value positions (last first, so the first pops first) or
   hands the node to the callback as a leaf. A chain (`elsif`, a run of rescue
   clauses) is a node pushing its successor, so it costs stack entries, not
   frames.

   vp_step holds the switch. Its uniform arms are generated from
   tools/value_edges.yml (value_pos_arms.inc, `make value-edges-regen`); the
   arms below it are the rules that are evaluation semantics, not edges, each
   named in the annotation as role `hand`. */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "value_pos.h"

typedef struct {
  int node;     /* the node to visit, or -1: nil by absence */
  int parent;   /* where it hangs from, as VpLeaf says */
  int arm;
  int depth;
  int link;     /* pushed as the next link of a chain: its arm numbering
                   carries on from `arm` */
} VpItem;

enum { VP_SMALL = 32 };

typedef struct {
  const NodeTable *nt;
  unsigned flags;     /* the VP_* switches */
  unsigned shapes;    /* the VPS_* shapes that are on */
  VpFn fn;
  void *ud;
  long budget;        /* visits left: a tree cannot take more than one per node */
  VpItem *items;      /* the stack: `small` first, the heap past it */
  int n, cap;
  VpItem small[VP_SMALL];
} VpWalk;

/* what a step did with the item */
typedef enum {
  VPSTEP_LEAF,      /* the node is a leaf */
  VPSTEP_JUMP,      /* a jump that is not followed */
  VPSTEP_PEEL,      /* a wrapper: the item now holds its child */
  VPSTEP_EXPANDED,  /* the value positions are pushed */
  VPSTEP_LEAF_THEN_EXPANDED  /* the node is a leaf, and its positions follow it */
} VpStep;

static void vp_push(VpWalk *w, int node, int parent, int arm, int depth, int link) {
  if (w->n == w->cap) {
    int cap = w->cap * 2;
    VpItem *p;
    if (w->items == w->small) {
      p = malloc((size_t)cap * sizeof *p);
      if (p) memcpy(p, w->small, (size_t)w->n * sizeof *p);
    }
    else p = realloc(w->items, (size_t)cap * sizeof *p);
    if (!p) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
    w->items = p;
    w->cap = cap;
  }
  VpItem *it = &w->items[w->n++];
  it->node = node; it->parent = parent; it->arm = arm; it->depth = depth; it->link = link;
}

static int vp_emit(VpWalk *w, const VpItem *it, VpKind kind) {
  VpLeaf lf;
  lf.node = it->node; lf.kind = kind; lf.parent = it->parent; lf.arm = it->arm;
  lf.cond_depth = it->depth;
  return w->fn(&lf, w->ud);
}

/* ---- the rules that are not a list of edges ---- */

/* A begin: its body unless an `else` follows (the else's value replaces it:
   VP_BEGIN_BOTH keeps both), each rescue clause, then the else; never the
   ensure clause. A begin with none of the three is only its body, a wrapper
   like parentheses. */
static VpStep vp_begin(VpWalk *w, VpItem *cur) {
  const NodeTable *nt = w->nt;
  int n = cur->node;
  int body = nt_ref(nt, n, "statements"), rescue = nt_ref(nt, n, "rescue_clause");
  int els = nt_ref(nt, n, "else_clause"), ensure = nt_ref(nt, n, "ensure_clause");
  if (rescue < 0 && els < 0 && ensure < 0) {
    if (!(w->shapes & VPS_BEGIN_PLAIN)) return VPSTEP_LEAF;
    cur->node = body;
    cur->link = 0;
    return VPSTEP_PEEL;
  }
  if (!(w->shapes & VPS_BEGIN_CLAUSES)) return VPSTEP_LEAF;
  int nres = 0;
  for (int r = rescue; r >= 0 && nres < nt->count; r = nt_ref(nt, r, "subsequent")) nres++;
  int d = cur->depth + 1;
  if (els >= 0) vp_push(w, els, n, 1 + nres, d, 0);
  if (rescue >= 0) vp_push(w, rescue, n, 1, d, 1);
  if (els < 0 || (w->flags & VP_BEGIN_BOTH)) vp_push(w, body, n, 0, d, 0);
  return VPSTEP_EXPANDED;
}

/* `a && b`: the right side, and the left side (the value when it is falsy)
   only under VP_AND_LEFT. */
static VpStep vp_and(VpWalk *w, VpItem *cur) {
  if (!(w->shapes & VPS_LOGIC)) return VPSTEP_LEAF;
  int n = cur->node, d = cur->depth + 1;
  vp_push(w, nt_ref(w->nt, n, "right"), n, 1, d, 0);
  if (w->flags & VP_AND_LEFT) vp_push(w, nt_ref(w->nt, n, "left"), n, 0, d, 0);
  return VPSTEP_EXPANDED;
}

/* case/in: the in clauses and the else. Without an else CRuby raises
   NoMatchingPatternError, which VP_CASE_IN_RAISE_NIL reads as a nil position. */
static VpStep vp_case_in(VpWalk *w, VpItem *cur) {
  const NodeTable *nt = w->nt;
  if (!(w->shapes & VPS_CASE_IN)) return VPSTEP_LEAF;
  int n = cur->node, d = cur->depth + 1, an = 0;
  const int *av = nt_arr(nt, n, "conditions", &an);
  int els = nt_ref(nt, n, "else_clause");
  if (els >= 0 || (w->flags & VP_CASE_IN_RAISE_NIL)) vp_push(w, els, n, an, d, 0);
  for (int i = an - 1; i >= 0; i--) vp_push(w, av[i], n, i, d, 0);
  return VPSTEP_EXPANDED;
}

/* return, next and break: with the flag on, the single value they hand out
   (a bare one hands out nil). Several values or a splat is an array the walk
   cannot point at: the jump stays a leaf of kind VPK_JUMP. */
static VpStep vp_jump(VpWalk *w, VpItem *cur, unsigned follow) {
  const NodeTable *nt = w->nt;
  if (!(w->flags & follow)) return VPSTEP_JUMP;
  int n = cur->node, an = 0;
  int args = nt_ref(nt, n, "arguments");
  const int *av = args >= 0 ? nt_arr(nt, args, "arguments", &an) : NULL;
  if (an > 1 || (an == 1 && nt_kind(nt, av[0]) == NK_SplatNode)) return VPSTEP_JUMP;
  vp_push(w, an == 1 ? av[0] : -1, n, 0, cur->depth, 0);
  return VPSTEP_EXPANDED;
}

/* A plain write compiles its value kept and dups it, so `x = e` is `e`'s
   value: under VP_WRITES the positions are `e`'s. An operator write
   (`x += e`) is the operator's result and is not listed here. */
static VpStep vp_write(VpWalk *w, VpItem *cur) {
  if (!(w->flags & VP_WRITES)) return VPSTEP_LEAF;
  vp_push(w, nt_ref(w->nt, cur->node, "value"), cur->node, 0, cur->depth, 0);
  return VPSTEP_EXPANDED;
}

/* `x ||= e` answers the target's old value when it is truthy and `e` when it
   is not; `x &&= e` the old value when it is falsy. Under VP_WRITES the write
   node is a leaf, standing for that old value (a caller classifies it as it
   would a read of the target), and `e`'s positions follow it. */
static VpStep vp_logical_write(VpWalk *w, VpItem *cur) {
  if (!(w->flags & VP_WRITES)) return VPSTEP_LEAF;
  vp_push(w, nt_ref(w->nt, cur->node, "value"), cur->node, 0, cur->depth, 0);
  return VPSTEP_LEAF_THEN_EXPANDED;
}

static VpStep vp_step(VpWalk *w, VpItem *cur) {
  const NodeTable *nt = w->nt;
  switch (nt_kind(nt, cur->node)) {
#include "value_pos_arms.inc"
  /* ---- hand-written arms, one per `role: hand` entry of value_edges.yml ---- */
  case NK_BeginNode:
    return vp_begin(w, cur);
  case NK_AndNode:
    return vp_and(w, cur);
  case NK_CaseMatchNode:
    return vp_case_in(w, cur);
  case NK_ReturnNode:
    return vp_jump(w, cur, VP_FOLLOW_RETURN);
  case NK_NextNode:
    return vp_jump(w, cur, VP_FOLLOW_NEXT);
  case NK_BreakNode:
    return vp_jump(w, cur, VP_FOLLOW_BREAK);
  case NK_LocalVariableWriteNode:
  case NK_InstanceVariableWriteNode:
  case NK_GlobalVariableWriteNode:
  case NK_ClassVariableWriteNode:
  case NK_ConstantWriteNode:
  case NK_ConstantPathWriteNode:
  case NK_MultiWriteNode:
    return vp_write(w, cur);
  case NK_LocalVariableOrWriteNode:
  case NK_InstanceVariableOrWriteNode:
  case NK_GlobalVariableOrWriteNode:
  case NK_ClassVariableOrWriteNode:
  case NK_ConstantOrWriteNode:
  case NK_ConstantPathOrWriteNode:
  case NK_LocalVariableAndWriteNode:
  case NK_InstanceVariableAndWriteNode:
  case NK_GlobalVariableAndWriteNode:
  case NK_ClassVariableAndWriteNode:
  case NK_ConstantAndWriteNode:
  case NK_ConstantPathAndWriteNode:
  case NK_CallOrWriteNode:
  case NK_CallAndWriteNode:
  case NK_IndexOrWriteNode:
  case NK_IndexAndWriteNode:
    return vp_logical_write(w, cur);
  default:
    break;
  }
  return VPSTEP_LEAF;
}

/* One item: peel until it is a leaf or has pushed its positions. */
static int vp_visit(VpWalk *w, VpItem cur) {
  for (;;) {
    if (cur.node < 0) return vp_emit(w, &cur, VPK_NIL);
    if (--w->budget < 0) {
      w->n = 0;   /* one gave-up leaf, then the walk is over */
      return vp_emit(w, &cur, VPK_GAVE_UP);
    }
    switch (vp_step(w, &cur)) {
    case VPSTEP_PEEL:
      continue;
    case VPSTEP_EXPANDED:
      return 0;
    case VPSTEP_JUMP:
      return vp_emit(w, &cur, VPK_JUMP);
    case VPSTEP_LEAF_THEN_EXPANDED:
      return vp_emit(w, &cur, VPK_EXPR);
    case VPSTEP_LEAF:
      break;
    }
    return vp_emit(w, &cur, VPK_EXPR);
  }
}

int for_each_value_position(const NodeTable *nt, int root, unsigned flags, VpFn fn, void *ud) {
  VpWalk w;
  w.nt = nt; w.flags = flags; w.fn = fn; w.ud = ud;
  w.shapes = (flags & VPS_ALL) ? (flags & VPS_ALL) : VPS_ALL;
  w.budget = nt->count;
  w.items = w.small; w.n = 0; w.cap = VP_SMALL;
  vp_push(&w, root, -1, 0, 0, 0);
  int stop = 0;
  while (!stop && w.n > 0) {
    VpItem it = w.items[--w.n];
    stop = vp_visit(&w, it);
  }
  if (w.items != w.small) free(w.items);
  return stop;
}

/* ---- --dump-value-positions ---- */

typedef struct {
  const NodeTable *nt;
  FILE *out;
  int line;   /* the scope's line: where a nil with no parent is */
} VpDump;

static const char *vp_kind_name(VpKind k) {
  switch (k) {
  case VPK_EXPR: return "EXPR";
  case VPK_NIL: return "NIL";
  case VPK_JUMP: return "JUMP";
  case VPK_GAVE_UP: return "GAVE_UP";
  }
  return "?";
}

static int vp_dump_leaf(const VpLeaf *lf, void *ud) {
  VpDump *d = ud;
  const NodeTable *nt = d->nt;
  fprintf(d->out, "  %s", vp_kind_name(lf->kind));
  if (lf->node >= 0) fprintf(d->out, " #%d %s", lf->node, nt_type(nt, lf->node));
  int line = lf->node >= 0 ? (int)nt_int(nt, lf->node, "node_line", 0)
           : lf->parent >= 0 ? (int)nt_int(nt, lf->parent, "node_line", 0) : d->line;
  fprintf(d->out, " line %d arm %d", line, lf->arm);
  if (lf->parent >= 0) fprintf(d->out, " parent #%d %s", lf->parent, nt_type(nt, lf->parent));
  else fprintf(d->out, " parent -");
  fprintf(d->out, " depth %d\n", lf->cond_depth);
  return 0;
}

static void vp_dump_scope(const NodeTable *nt, FILE *out, const char *title, int line, int root) {
  VpDump d;
  d.nt = nt; d.out = out; d.line = line;
  fprintf(out, "%s line %d\n", title, line);
  for_each_value_position(nt, root, VP_ALL_FLAGS, vp_dump_leaf, &d);
}

/* The program, then every method, block and lambda body of the program's own
   file in node order (the builtins parsed ahead of it are another file). A
   block is a root of its own: the walk never goes into one. */
void value_pos_dump(const NodeTable *nt, FILE *out) {
  fprintf(out, "main\n");
  VpDump d;
  d.nt = nt; d.out = out; d.line = 1;
  for_each_value_position(nt, nt_ref(nt, nt->root_id, "statements"), VP_ALL_FLAGS, vp_dump_leaf, &d);
  for (int id = 0; id < nt->count; id++) {
    NodeKind k = nt_kind(nt, id);
    if ((k != NK_DefNode && k != NK_BlockNode && k != NK_LambdaNode) || nt_int(nt, id, "node_file", 0) != 0) continue;
    const char *name = nt_str(nt, id, "name");
    char title[256];
    if (k == NK_DefNode) snprintf(title, sizeof title, "def %s", name ? name : "?");
    else snprintf(title, sizeof title, "%s", k == NK_BlockNode ? "block" : "lambda");
    vp_dump_scope(nt, out, title, (int)nt_int(nt, id, "node_line", 0), nt_ref(nt, id, "body"));
  }
}

/* ---- --check-value-pos ---- */

/* What a walk over a table built by hand saw: leaves of each kind, whether
   the EXPR leaves came in the order and with the arms the check expects. */
typedef struct {
  int leaves[4];   /* by VpKind */
  int next_arm;    /* the arm the next EXPR leaf should carry */
  int out_of_order;
  int last_node;
} VpCheck;

static void vp_check_init(VpCheck *k) {
  memset(k, 0, sizeof *k);
  k->last_node = -1;
}

static int vp_check_leaf(const VpLeaf *lf, void *ud) {
  VpCheck *k = ud;
  k->leaves[lf->kind]++;
  if (lf->kind == VPK_EXPR) {
    if (lf->arm != k->next_arm || lf->node <= k->last_node) k->out_of_order = 1;
    k->next_arm = lf->arm + 1;
    k->last_node = lf->node;
  }
  return 0;
}

/* A cycle of parentheses and statements, which only a shared subtree could
   make in a real table: the walk ends with one gave-up leaf. */
static int vp_check_budget(void) {
  NodeTable *nt = nt_new_table();
  int p = nt_new_node(nt, "ParenthesesNode"), s = nt_new_node(nt, "StatementsNode");
  int body[1];
  body[0] = p;
  nt_node_set_ref(nt, p, "body", s);
  nt_node_set_arr(nt, s, "body", body, 1);
  VpCheck k;
  vp_check_init(&k);
  for_each_value_position(nt, p, VP_ALL_FLAGS, vp_check_leaf, &k);
  int ok = k.leaves[VPK_GAVE_UP] == 1 && k.leaves[VPK_EXPR] + k.leaves[VPK_NIL] + k.leaves[VPK_JUMP] == 0;
  nt_free(nt);
  return ok;
}

/* A case with 100 when clauses and no else (the stack outgrows its 32 entries
   on the C stack) and an if/elsif chain of 5000 arms (no recursion to cut):
   every arm is seen once, in source order, with its place in the chain. */
static int vp_check_long(void) {
  NodeTable *nt = nt_new_table();
  enum { WHENS = 100, ARMS = 5000 };
  int whens[WHENS];
  for (int i = 0; i < WHENS; i++) {
    whens[i] = nt_new_node(nt, "WhenNode");
    nt_node_set_ref(nt, whens[i], "statements", nt_new_node(nt, "IntegerNode"));
  }
  int cs = nt_new_node(nt, "CaseNode");
  nt_node_set_arr(nt, cs, "conditions", whens, WHENS);
  VpCheck kc;
  vp_check_init(&kc);
  for_each_value_position(nt, cs, VP_ALL_FLAGS, vp_check_leaf, &kc);
  int ok = kc.leaves[VPK_EXPR] == WHENS && kc.leaves[VPK_NIL] == 1 && !kc.out_of_order && kc.next_arm == WHENS;
  int root = nt_new_node(nt, "IfNode"), cur = root;
  for (int i = 0; i < ARMS; i++) {
    int next = nt_new_node(nt, "IfNode");
    nt_node_set_ref(nt, cur, "statements", nt_new_node(nt, "IntegerNode"));
    nt_node_set_ref(nt, cur, "subsequent", next);
    cur = next;
  }
  nt_node_set_ref(nt, cur, "statements", nt_new_node(nt, "IntegerNode"));
  int tail = nt_new_node(nt, "ElseNode");
  nt_node_set_ref(nt, tail, "statements", nt_new_node(nt, "IntegerNode"));
  nt_node_set_ref(nt, cur, "subsequent", tail);
  VpCheck ki;
  vp_check_init(&ki);
  for_each_value_position(nt, root, VP_ALL_FLAGS, vp_check_leaf, &ki);
  ok = ok && ki.leaves[VPK_EXPR] == ARMS + 2 && ki.leaves[VPK_GAVE_UP] == 0 && !ki.out_of_order;
  nt_free(nt);
  return ok;
}

int value_pos_check(void) {
  int ok = 1;
  if (!vp_check_budget()) { fprintf(stderr, "value-pos-check: a cycle did not end in one gave-up leaf\n"); ok = 0; }
  if (!vp_check_long()) { fprintf(stderr, "value-pos-check: a wide case or a long elsif chain was not walked in order\n"); ok = 0; }
  if (ok) printf("value-pos-check: ok\n");
  return ok ? 0 : 1;
}
