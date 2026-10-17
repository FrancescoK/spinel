/* value_pos.h -- the nodes an expression's value can come from.

   for_each_value_position(nt, root, flags, fn, ud) calls fn on each value
   position of `root`: the places a conditional, a sequence, a begin or a
   jump takes its value from. It is pure over the node table: no Compiler, no
   types, no inference (the line CallPlan draws), so a walker asks it a syntax
   question and decides for itself what a leaf means.

   The walk is a loop over an explicit stack, so a chain of any length (an
   `elsif` ladder, a run of rescue clauses) costs stack entries, not C frames,
   and there is no depth to cut. A budget of one visit per node ends a walk
   that a shared subtree would otherwise run for ever: the callback then gets
   one VPK_GAVE_UP leaf and chooses the safe answer for its question ("any"
   answers "maybe", "every" answers "no").

   The walk never descends into a block, a lambda or a method body: whether a
   block's value is its call's (`map`) or not (`each`) is a fact about the
   call. A caller names the body as a new root.

   The value edges of each Prism node are data (tools/value_edges.yml); the
   arms they describe are generated into src/value_pos_arms.inc, and the rules
   that are evaluation semantics, not edges, are written by hand in
   value_pos.c. */
#ifndef SPINEL_VALUE_POS_H
#define SPINEL_VALUE_POS_H

#include "node_table.h"

typedef enum {
  VPK_EXPR,    /* an ordinary node: this is where the value comes from */
  VPK_NIL,     /* nil by absence: a missing else, an empty body, () or a bare
                  jump; node = -1 */
  VPK_JUMP,    /* a return/next/break that is not followed: its flag is off,
                  or it hands out several values or a splat; node = the jump */
  VPK_GAVE_UP  /* the visit budget ran out; node = the node it stopped at */
} VpKind;

typedef struct {
  int node;        /* the leaf */
  VpKind kind;
  int parent;      /* the structural node it hangs from (an if, a case, a
                      begin, a rescue clause, a logical operator, a write or a
                      jump that was followed): wrappers (parentheses,
                      statements, else, in) are not parents. -1 at the
                      root */
  int arm;         /* its place among the parent's value positions: for an
                      if chain 0 is the first `then`, 1 the first `elsif` (or
                      the else), and so on; a case's when/in clauses count 0..
                      and its else follows them; a begin's body is 0, its rescue
                      clauses 1.. and its else follows them; `a || b` and
                      `x rescue y` are 0 and 1 */
  int cond_depth;  /* branches crossed from the root: each if, elsif, unless,
                      case, begin, rescue clause, `&&`, `||` and rescue
                      modifier counts one, a wrapper, a write or a followed
                      jump none */
} VpLeaf;

/* A nonzero answer stops the walk. */
typedef int (*VpFn)(const VpLeaf *leaf, void *ud);

enum {
  /* a tail return/next/break yields the positions of its value (one
     non-splat argument); a bare one yields VPK_NIL. Off, or with several
     values or a splat, it is a VPK_JUMP leaf. */
  VP_FOLLOW_RETURN = 1u << 0,
  VP_FOLLOW_NEXT = 1u << 1,
  VP_FOLLOW_BREAK = 1u << 2,
  /* `a && b`: the left side is also a position (the value when falsy). Off:
     the right side only. */
  VP_AND_LEFT = 1u << 3,
  /* a begin with an `else` also yields its body. Off, the else's value
     replaces it. */
  VP_BEGIN_BOTH = 1u << 4,
  /* `x = e`, `x ||= e`, `x &&= e` and the other plain and logical writes
     yield the positions of `e`. Off, the write is a leaf. An operator write
     (`x += e`) answers the operator's result and is always a leaf. */
  VP_WRITES = 1u << 5,
  /* a case/in without an else yields VPK_NIL (CRuby raises instead). Off, it
     yields nothing for the missing else. */
  VP_CASE_IN_RAISE_NIL = 1u << 6,

  /* The shapes the walk sees through; a shape that is off is a leaf. No bit
     at all means every shape. A walker passes the subset it handled before it
     moved here, so that moving it changes no generated code. */
  VPS_IF = 1u << 8,           /* if, elsif, else, and the ternary */
  VPS_UNLESS = 1u << 9,
  VPS_CASE = 1u << 10,        /* case/when */
  VPS_CASE_IN = 1u << 11,     /* case/in */
  VPS_BEGIN_PLAIN = 1u << 12, /* a begin with no rescue, else or ensure */
  VPS_BEGIN_CLAUSES = 1u << 13, /* a begin with any of them */
  VPS_RESCUE_MOD = 1u << 14,  /* x rescue y */
  VPS_LOGIC = 1u << 15,       /* `a || b`, `a && b` */
  VPS_BEGIN = VPS_BEGIN_PLAIN | VPS_BEGIN_CLAUSES,
  VPS_ALL = VPS_IF | VPS_UNLESS | VPS_CASE | VPS_CASE_IN | VPS_BEGIN | VPS_RESCUE_MOD | VPS_LOGIC
};

/* Everything on: what --dump-value-positions walks with. */
#define VP_ALL_FLAGS (VP_FOLLOW_RETURN | VP_FOLLOW_NEXT | VP_FOLLOW_BREAK | VP_AND_LEFT | \
                      VP_BEGIN_BOTH | VP_WRITES | VP_CASE_IN_RAISE_NIL | VPS_ALL)

/* Calls fn on each value position of root in source order, depth first (the
   `ensure` clause is never one). Answers the first nonzero fn answered, else 0. */
int for_each_value_position(const NodeTable *nt, int root, unsigned flags, VpFn fn, void *ud);

#endif
