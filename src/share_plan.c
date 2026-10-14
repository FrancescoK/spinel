/* share_plan.c -- the plan for each String value under --share-strings (#8328).

   Whether a String reaches its consumer as the object or as a copy is
   decided today at each emission site, and predicted by the analysis
   through a mirror it keeps of the emitters (strbuf_flow_carries). The
   plan is the one place that decision is meant to come from. For each
   value:

     need    what its consumer needs (share_value_needs_handle): its bytes
             (SPN_BYTES); a handle that may be a new one, because no other
             name can see the String, but a box keeps it (SPN_NEW); or the
             object itself (SPN_OBJECT);
     supply  whether its producer can hand over the handle, or a box that
             holds it (SPS_HANDLE, share_plan_supplies), or only its bytes
             (SPS_BYTES);
     form    what the two give (share_plan_form): the bytes (SPF_BYTES);
             the producer's handle (SPF_HANDLE); the bytes wrapped into a
             new handle, which no other name can tell from the object
             (SPF_WRAP); or no conversion at all, because the consumer
             needs the object and the producer has only bytes (SPF_REFUSE).

   A need is a consumer's. A value has one consumer, the node it sits in,
   whose role says what it does with it (share_plan_role): it takes the
   value -- keeps it, changes it, compares it, hands it on (SPR_TAKE); it
   reads its bytes and keeps nothing, as an interpolation does, or a
   freeze of a variable's String, which reaches the String through the
   variable (SPR_READ); it only asks whether it is nil or false, as a predicate does (SPR_TEST);
   or, for an element of the Array literal a multiple write splits (also
   through a splat, `a, b = *[s, t]`), the target the element is stored
   into takes it (SPR_STORE), where the literal is no container; or it
   asks the value's identity, as equal?, object_id and __id__ do where no
   class of the program defines them (SPR_IDENTITY). A taker needs what
   the value's facts say (share_value_needs_handle); a reader and a test
   need its bytes; a store needs what its target does
   (share_store_needs_handle). An identity asks for the object, and is the
   handle where the producer has one (for an exception's message, the box
   the exception keeps it in) and the bytes' pointer where it has only
   bytes, which are then all the String there is: never a new handle,
   which no other name holds, and never a refusal.
   Some values have a second consumer:
     - a call that answers its receiver or nil (rule 4 below) answers its
       receiver's String, so its own answer is only tested for nil
       (share_plan_second_role: SPR_TEST);
     - a write, an attribute or index assignment, an `||=` or `&&=` and a
       call answering its receiver answer a value they also store or
       change: that second consumer is the answering node's own, asked of
       that node;
     - a multiple write whose own value is read answers the values it
       stores in a new Array: a taker beside the store, which needs no more
       than the store (the literal's elements need what its facts say).

   Nothing is refused by the plan. One consumer reads it: object_id and
   __id__ on a String, through emit_str_form (codegen_str.c), the one
   place a consumer is to ask for a String in the plan's form. Every other
   emitter still decides on its own; --share-check (share_check.c) reads
   the plan at each site it marks and reports how often it agrees with the
   conversion the emitted C has there.

   repr_of is not memoised, and neither is anything that reads it. The
   need reads the share facts, final at seal, the node's type, names and
   scope's reachability; it is memoised at the end of repr_seal, in one
   byte per node beside the node's consumer role. Each guard of the memo
   covers one way codegen makes a node read as something else:
     - a view, a scope move or a splice: cplan_plain_ctx, the call plan's
       own rule; a poly dispatch arm: the arm context at rest;
     - a rename for one emission (the value-form bang transform's), a reset,
       a swap of two nodes, an added node: the node table's version, which
       exactly those bump (nt_node_set_str, nt_set_str, nt_node_reset,
       nt_swap_nodes, nt_new_node);
     - a node retyped outside the view stack: its type as at seal;
     - a method codegen makes reachable after seal (the exception message
       and to_s overrides the dispatcher calls): a node of a scope
       unreachable at seal is not memoised (SPN_ASK).
   A swap of a node's receiver, arguments or block (nt_node_set_ref) and
   an emitter's retype of a local bump nothing; the need does not read a
   local's type, and reads a call's receiver only through freshness.
   The supply reads repr_of, which an emitter's retyped local changes
   outside all of those, so it is always computed where it is asked.
   The role is the kind of the node a value sits in, as the program has
   it at seal, and needs no guard: codegen renames calls and retypes
   values, but no interpolation, predicate, multiple write or identity
   query changes where its parts sit, and no rename makes or unmakes an
   identity query; a receiver or arguments swapped in for one
   emission (nt_node_set_ref) and nodes added after seal sit in a call,
   whose role is a taker's. The second role of a call that answers its
   receiver reads its name, its receiver's type and its targets, as rule 4
   does, so it is asked where it is asked.
   --share-check asks the need live too: the memo is measured, never
   trusted, until an emitter reads it. (The one that does asks for an
   identity, whose need is the object whatever the memo says.) */

#include <stdlib.h>
#include "codegen_internal.h"
#include "builtin_ops.h"
#include "builtin_names.h"
#include "call_plan.h"
#include "repr.h"
#include "share.h"

int share_plan_form(int need, int supply) {
  if (need == SPN_BYTES) return SPF_BYTES;
  if (supply == SPS_HANDLE) return SPF_HANDLE;
  return need == SPN_NEW ? SPF_WRAP : SPF_REFUSE;
}

const char *share_plan_form_name(int form) {
  static const char *const names[] = { "bytes", "handle", "wrap", "refuse" };
  return form >= SPF_BYTES && form <= SPF_REFUSE ? names[form] : "?";
}

/* The String receiver call v answers (a String method that answers self,
   or self or nil, and no program method of the name), or -1. */
static int share_plan_self_recv(Compiler *c, int v) {
  const NodeTable *nt = c->nt;
  if (v < 0 || nt_kind(nt, v) != NK_CallNode) return -1;
  const char *nm = nt_str(nt, v, "name");
  int r = unwrap_parens(c, nt_ref(nt, v, "receiver")), tg[CPT_MAX];
  if (!nm || r < 0 || (c->ntype[r] != TY_STRING && c->ntype[r] != TY_STRBUF)) return -1;
  if (!(bop_answers_self(TY_STRING, nm, call_plain_argc(c, v), nt_ref(nt, v, "block") >= 0) &
        (BOPF_SELF | BOPF_SELF_OR_NIL)))
    return -1;
  return cplan_targets(c, v, tg, CPT_MAX) == 0 ? r : -1;
}

/* Is node v a frozen String: a literal (share_frozen_literal), or a read
   of a builtin String constant no constant of the program's own shadows?
   Its handle is its own, the one every read of it names. */
static int share_plan_frozen(Compiler *c, int v) {
  const NodeTable *nt = c->nt;
  int u = an_unparen(nt, v);
  if (u >= 0 && nt_kind(nt, u) == NK_ConstantReadNode) {
    const char *nm = nt_str(nt, u, "name");
    return is_engine_string_const(nm) && !comp_const(c, nm);
  }
  return share_frozen_literal(c, v);
}

/* Is node v super in an exception class's message or to_s that publishes
   the String it answers (scope_ret_handle) and inherits the builtin's
   (no ancestor of the program's own defines it): the message the
   exception keeps, as its handle? */
static int share_plan_exc_super(Compiler *c, int v) {
  NodeKind k = v >= 0 ? nt_kind(c->nt, v) : NK_NONE;
  if (k != NK_SuperNode && k != NK_ForwardingSuperNode) return 0;
  Scope *sc = comp_scope_of(c, v);
  int mi = sc ? (int)(sc - c->scopes) : -1, cls = sc ? sc->class_id : -1;
  if (mi < 0 || cls < 0 || cls >= c->nclasses || sc->def_node < 0 || !sc->name ||
      (!is_exception_message(sc->name)) || (!class_is_exc_subclass(c, cls) && !class_is_exc_reopen(c, cls)))
    return 0;
  int sup = c->classes[cls].parent;
  return scope_ret_handle(c, mi) && (sup < 0 || comp_method_in_chain(c, sup, sc->name, NULL) < 0);
}

/* The producer of node v's handle (SPK_*, share.h), the first of these
   that names it:
     1. a box (SPK_BOX);
     2. a value repr_of represents as the handle by where the handle comes
        from: a slot, a demanded call, a boxed element, a narrowed box. Not
        RS_FRESH, repr_of's answer for a handle whose source none of its
        checks names, not a proof that the String is new: such a value is
        asked the rules below;
     3. a frozen String, whose handle is its own (SPK_FROZEN);
     4. a call that answers its String receiver (SPK_SELF; *op is that
        receiver), a bang on a boxed receiver (SPK_BANG_BOX; *op the
        receiver), a boxed receiver's call whose arms each answer a String,
        read as a box whose handle is bound (SPK_POLY_ARMS);
     5. a new String (share_value_fresh), which has no handle to hand over,
        whatever a route says about whether its copy can be seen: none;
     6. super in an exception's text override (SPK_EXC_SUPER);
     7. the route the analysis checks a carry against
        (share_node_carry_kind, which names each route by its kind: a
        callee that publishes the handle, a reader, a write, a value route
        over an operand, a block's value, a conditional ...), and a `||` or
        `&&` with a bang on a boxed receiver on an arm (SPK_COND);
     8. parentheses or statements: their last statement (SPK_SEQUENCE).
   Anything else has its bytes only (SPK_NONE). */
static int share_plan_producer_at(Compiler *c, int v, int *op) {
  const NodeTable *nt = c->nt;
  Repr r = repr_of(c, v);
  *op = -1;
  if (r.kind == RK_BOXED) return SPK_BOX;
  if (r.kind == RK_STRBUF && r.strbuf_src != RS_FRESH) {
    switch (r.strbuf_src) {
    case RS_DEMANDED: return SPK_DEMANDED;
    case RS_ELEM: return SPK_ELEM;
    case RS_SLOT_POLY: return SPK_SLOT_POLY;
    default: return SPK_SLOT;
    }
  }
  if (share_plan_frozen(c, v)) return SPK_FROZEN;
  int rv = share_plan_self_recv(c, v);
  if (rv >= 0) { *op = rv; return SPK_SELF; }
  if (face_str_bang_call(c, v)) { *op = nt_ref(nt, v, "receiver"); return SPK_BANG_BOX; }
  /* a boxed receiver's call whose every arm answers a String, the handle it
     publishes or a new one (or a conversion of it a String answers with
     itself): the dispatch is read as a box, and its handle is bound
     (strbuf_poly_user_base) */
  if (repr_share_rule(c) && strbuf_poly_user_base(c, v) >= 0) return SPK_POLY_ARMS;
  if (share_value_fresh(c, v, 0)) return SPK_NONE;
  if (share_plan_exc_super(c, v)) return SPK_EXC_SUPER;
  int k = share_node_carry_kind(c, v, op);
  if (k != SPK_NONE) return k;
  /* (a `||` or `&&` with a bang on a boxed receiver on an arm, which the
     faces take arm by arm: strbuf_face_bang_cond) */
  if (strbuf_face_bang_cond(c, v)) return SPK_COND;
  NodeKind nk = v >= 0 ? nt_kind(nt, v) : NK_NONE;
  if (nk == NK_ParenthesesNode || nk == NK_StatementsNode) {
    int b = nk == NK_ParenthesesNode ? nt_ref(nt, v, "body") : v, bn = 0;
    const int *bv = b >= 0 && nt_kind(nt, b) == NK_StatementsNode ? nt_arr(nt, b, "body", &bn) : NULL;
    if (b >= 0 && !bv) bn = 1, bv = &b;
    if (bn > 0) { *op = bv[bn - 1]; return SPK_SEQUENCE; }
  }
  return SPK_NONE;
}

const char *share_plan_kind_name(int kind) {
  static const char *const names[] = { "none", "box", "slot", "demanded", "elem", "slot_poly", "frozen", "self",
                                       "bang_box", "proc_call", "poly_arms", "exc_message", "exc_super", "published",
                                       "reader", "write", "assign", "operand", "block_value", "yield", "cond",
                                       "sequence", "lift" };
  _Static_assert(sizeof names / sizeof names[0] == SPK__COUNT, "a name for each producer kind");
  return kind >= 0 && kind < SPK__COUNT ? names[kind] : "?";
}

int share_plan_producer(Compiler *c, int v, int *operand) {
  int rv, k = share_plan_producer_at(c, v, &rv);
  if (operand) *operand = rv;
  return k;
}

static int share_plan_supplies_d(Compiler *c, int v, int depth);

/* Does leaf a of a value taken arm by arm (a conditional's arm, a block's
   value) give its consumer what it needs: nil, a raise (no value), a
   String no other name holds (a new handle cannot be told from it), or a
   producer that supplies the handle? A variable's read supplies what its
   slot holds: the handle, or bytes no handle holds, whose identity is
   theirs. With foreign set, a is read under another object's self (an
   instance_exec or instance_eval splice): an instance variable's read
   there is that object's, which the plan cannot read from here, so it
   hands on its slot, which the seal checks as a holder. */
static int share_plan_leaf_ok(Compiler *c, int a, int foreign, int depth) {
  const NodeTable *nt = c->nt;
  if (a < 0) return 1;
  NodeKind k = nt_kind(nt, a);
  if (k == NK_NilNode || (foreign && k == NK_InstanceVariableReadNode)) return 1;
  if (k == NK_LocalVariableReadNode || k == NK_InstanceVariableReadNode || repr_static_read_kind(k))
    return depth < 16 && share_plan_supplies_d(c, a, depth + 1);
  const char *nm = k == NK_CallNode ? nt_str(nt, a, "name") : NULL;
  if (nm && is_raise_alias(nm) && nt_ref(nt, a, "receiver") < 0 && comp_method_index(c, nm) < 0) return 1;
  if (share_plan_need(c, a) != SPN_OBJECT) return 1;
  return depth < 16 && share_plan_supplies_d(c, a, depth + 1);
}

/* ...and each jump of kind k (NK_NextNode, NK_BreakNode) under n that
   leaves what n is the body of, its value the leaf */
static int share_plan_jumps_ok(Compiler *c, int n, NodeKind k, int foreign, int depth) {
  const NodeTable *nt = c->nt;
  if (n < 0) return 1;
  NodeKind nk = nt_kind(nt, n);
  if (nk == NK_BlockNode || nk == NK_LambdaNode || nk == NK_DefNode || nk == NK_WhileNode || nk == NK_UntilNode ||
      nk == NK_ForNode)
    return 1;
  if (nk == k) {
    int argc = 0;
    const int *argv = call_args(nt, n, &argc);
    if (argc > 1 || (argc == 1 && !share_plan_leaf_ok(c, argv[0], foreign, depth))) return 0;
  }
  for (int i = 0; i < nt_num_refs(nt, n); i++)
    if (!share_plan_jumps_ok(c, nt_ref_at(nt, n, i), k, foreign, depth)) return 0;
  for (int i = 0; i < nt_num_arrs(nt, n); i++) {
    int m = 0;
    const int *ids = nt_arr_at(nt, n, i, &m);
    for (int j = 0; j < m; j++) if (!share_plan_jumps_ok(c, ids[j], k, foreign, depth)) return 0;
  }
  return 1;
}

/* ...a body's value: its last statement, and each jump of kind k */
static int share_plan_body_ok(Compiler *c, int body, NodeKind k, int foreign, int depth) {
  const NodeTable *nt = c->nt;
  int n = 0;
  const int *bb = body >= 0 && nt_kind(nt, body) == NK_StatementsNode ? nt_arr(nt, body, "body", &n) : NULL;
  return (n == 0 || share_plan_leaf_ok(c, bb[n - 1], foreign, depth)) &&
         (k == NK_NONE || share_plan_jumps_ok(c, body, k, foreign, depth));
}

/* Does conditional (or begin, or rescue modifier) v hand on what each of
   its arms supplies: is every arm a leaf that gives the consumer what it
   needs? `l && r` answers r where l is a String (l is truthy), and l only
   where l is nil or false, so l is no String leaf. */
static int share_plan_arms_ok(Compiler *c, int v, int depth) {
  const NodeTable *nt = c->nt;
  if (v < 0) return 1;
  if (depth > 16) return 0;
  switch (nt_kind(nt, v)) {
  case NK_ParenthesesNode:
    return share_plan_arms_ok(c, nt_ref(nt, v, "body"), depth + 1);
  case NK_StatementsNode: {
    int n = 0;
    const int *bb = nt_arr(nt, v, "body", &n);
    return n == 0 || share_plan_arms_ok(c, bb[n - 1], depth + 1);
  }
  case NK_ElseNode:
    return share_plan_arms_ok(c, nt_ref(nt, v, "statements"), depth + 1);
  case NK_IfNode: case NK_UnlessNode:
    return share_plan_arms_ok(c, nt_ref(nt, v, "statements"), depth + 1) &&
           share_plan_arms_ok(c, nt_ref(nt, v, nt_kind(nt, v) == NK_IfNode ? "subsequent" : "else_clause"), depth + 1);
  case NK_OrNode:
    return share_plan_arms_ok(c, nt_ref(nt, v, "left"), depth + 1) && share_plan_arms_ok(c, nt_ref(nt, v, "right"), depth + 1);
  case NK_AndNode:
    return share_plan_arms_ok(c, nt_ref(nt, v, "right"), depth + 1);
  case NK_CaseNode: {
    int nw = 0;
    const int *whens = nt_arr(nt, v, "conditions", &nw);
    for (int w = 0; w < nw; w++)
      if (!share_plan_arms_ok(c, nt_ref(nt, whens[w], "statements"), depth + 1)) return 0;
    return share_plan_arms_ok(c, nt_ref(nt, v, "else_clause"), depth + 1);
  }
  case NK_RescueModifierNode:
    return share_plan_arms_ok(c, nt_ref(nt, v, "expression"), depth + 1) &&
           share_plan_arms_ok(c, nt_ref(nt, v, "rescue_expression"), depth + 1);
  case NK_BeginNode: {
    int el = nt_ref(nt, v, "else_clause");
    /* (the body's value is the begin's only when no else follows it) */
    if (el < 0 && !share_plan_body_ok(c, nt_ref(nt, v, "statements"), NK_NONE, 0, depth)) return 0;
    for (int rc = nt_ref(nt, v, "rescue_clause"); rc >= 0; rc = nt_ref(nt, rc, "subsequent"))
      if (!share_plan_body_ok(c, nt_ref(nt, rc, "statements"), NK_NONE, 0, depth)) return 0;
    return el < 0 || share_plan_body_ok(c, nt_ref(nt, el, "statements"), NK_NONE, 0, depth);
  }
  default:
    return share_plan_leaf_ok(c, v, 0, depth);
  }
}

/* Does call v, which answers its literal block's value (SPK_BLOCK_VALUE),
   hand on what each value it answers supplies: the block's tail and each
   `next` (then, inject, instance_exec's splice, a spliced yielding call
   that answers its yield), each `break` (loop)? A spliced call that
   answers a variable of its method hands on that slot, and a call whose
   value no block gives (sum, an ENV store) is the route's own. */
static int share_plan_block_ok(Compiler *c, int v, int depth) {
  const NodeTable *nt = c->nt;
  int u = an_unparen(nt, v), blk = u >= 0 && nt_kind(nt, u) == NK_CallNode ? nt_ref(nt, u, "block") : -1;
  if (blk < 0 || nt_kind(nt, blk) != NK_BlockNode) return 1;
  int body = nt_ref(nt, blk, "body");
  if (strbuf_route_loop(c, u)) return share_plan_jumps_ok(c, body, NK_BreakNode, 0, depth);
  if (strbuf_route_ie(c, u)) return share_plan_body_ok(c, body, NK_NONE, 1, depth);
  if (strbuf_route_inline_call(c, u)) {
    int mi = strbuf_inline_mi(c, u), last = mi > 0 ? scope_body_last(c, mi) : -1;
    int bl = block_given_tail_then_last(c, last);
    if (bl >= 0) last = bl;
    if (last >= 0 && nt_kind(nt, last) != NK_YieldNode) return 1;
  }
  return share_plan_body_ok(c, body, NK_NextNode, 0, depth);
}

/* The supply node v decides by itself (1 or 0), or -1 when it hands on its
   operand's (a call answering its receiver, a value route over an operand,
   a sequence's last statement): *op is then that node. */
static int share_plan_supply_at(Compiler *c, int v, int *op, int depth) {
  int k = share_plan_producer_at(c, v, op);
  switch (k) {
  case SPK_NONE: return 0;
  case SPK_SELF: case SPK_SEQUENCE: return -1;
  case SPK_OPERAND: {
    if (*op >= 0) return -1;
    /* a String clamp: each operand it can answer */
    int ops[3];
    if (!strbuf_route_clamp(c, v, ops)) return 1;
    for (int i = 0; i < 3; i++)
      if (ops[i] >= 0 && !share_plan_leaf_ok(c, ops[i], 0, depth)) return 0;
    return 1;
  }
  case SPK_COND: return share_plan_arms_ok(c, an_unparen(c->nt, v), depth);
  case SPK_BLOCK_VALUE: return share_plan_block_ok(c, v, depth);
  case SPK_BOX: case SPK_SLOT: case SPK_DEMANDED: case SPK_ELEM: case SPK_SLOT_POLY: case SPK_FROZEN:
  case SPK_BANG_BOX: case SPK_PROC_CALL: case SPK_POLY_ARMS: case SPK_EXC_MESSAGE: case SPK_EXC_SUPER:
  case SPK_PUBLISHED: case SPK_READER: case SPK_WRITE: case SPK_ASSIGN: case SPK_YIELD: case SPK_LIFT:
    return 1;
  }
  return 0;
}

/* One answer of a chain of self-answering calls: the stamp it holds for
   (the view epoch and the node table's version), the node that decided it
   and what that node's representation was. */
struct SharePlanSup { unsigned epoch, ver; int d; unsigned char kind, src, val, set; };

/* Is cache entry e of a chain still the answer: the same stamp, and the
   node that decided it deciding it the same way? The stamp does not move
   with a dispatch arm, a yield site's types, a splice, a scope move or a
   receiver swap, and the links between the asked node and the deciding
   one are not checked again: the entry rests on the deciding node's answer
   alone, which a query of every supply both ways (cached and walked) over
   the corpus found to agree. */
static int share_plan_sup_valid(Compiler *c, const struct SharePlanSup *e) {
  if (!e->set || e->epoch != view_epoch() || e->ver != c->nt->version) return 0;
  Repr r = repr_of(c, e->d);
  int rv;
  return r.kind == e->kind && r.strbuf_src == e->src && share_plan_supply_at(c, e->d, &rv, 0) == e->val;
}

/* Can node v's producer hand over the String's handle? By its kind
   (share_plan_producer_at): a value that hands on its operand's supply
   (a call answering its receiver, a value route over an operand, a
   sequence's last statement) supplies what that operand does; a value
   taken arm by arm (a conditional, a begin, a call answering its block's
   value) supplies the handle where each of its arms gives its consumer
   what it needs (share_plan_leaf_ok); every other kind but SPK_NONE has
   the handle, or a box that holds it.
   A chain of operands is asked at each of its links, outermost first: the
   walk down it keeps each link's answer with the node that decided it
   (Compiler.share_sup), and a link asked again reads it while the view
   epoch and the table's version are the same and the deciding node still
   decides it the same way, so a chain costs its length once, not once per
   link. Nothing outside the chain's own emission can change a link in
   between: an emitter retypes a block parameter's local, which no
   receiver chain outside the block reaches. */
static int share_plan_supplies_d(Compiler *c, int v, int depth) {
  int rv, s = share_plan_supply_at(c, v, &rv, depth);
  if (s >= 0) return s;
  int n = c->nt->count;
  if (!c->share_sup || c->share_sup_n < n) {
    free(c->share_sup);
    c->share_sup = calloc((size_t)n + 1, sizeof *c->share_sup);
    if (!c->share_sup) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
    c->share_sup_n = n;
  }
  struct SharePlanSup *e = &c->share_sup[v];
  if (share_plan_sup_valid(c, e)) return e->val;
  /* walk down to the deciding node, then stamp every link on the way */
  int d = rv;
  while (d >= 0 && (s = share_plan_supply_at(c, d, &rv, depth)) < 0) {
    if (d < n && share_plan_sup_valid(c, &c->share_sup[d])) { s = c->share_sup[d].val; d = c->share_sup[d].d; break; }
    d = rv;
  }
  if (d < 0) return 0;
  Repr r = repr_of(c, d);
  struct SharePlanSup fill = { view_epoch(), c->nt->version, d, r.kind, r.strbuf_src, (unsigned char)s, 1 };
  for (int l = v, o; l >= 0 && l < n && l != d; l = o) {
    c->share_sup[l] = fill;
    if (share_plan_producer_at(c, l, &o) == SPK_NONE) break;
  }
  return s;
}
static int share_plan_supplies(Compiler *c, int v) { return share_plan_supplies_d(c, v, 0); }

/* The memo's byte per node: the need of the value (SPN_*), or SPN_ASK for
   a node whose scope was unreachable at seal (codegen can still make its
   method reachable, so its need is asked live), and above it, in the
   byte's other six bits, the role of the node's consumer (SPR_*). */
enum { SPN_ASK = 3, SPM_NEED = 3, SPM_ROLE_SHIFT = 2 };

static int share_plan_need_of(int need) {
  return need == SHN_NO ? SPN_BYTES : need == SHN_FRESH ? SPN_NEW : SPN_OBJECT;
}
int share_plan_need(Compiler *c, int v) { return share_plan_need_of(share_value_needs_handle(c, v)); }

static int share_plan_box_plain(Compiler *c, int v);
static int share_plan_box_kept(Compiler *c, int v);

/* What a consumer in `role` needs of value v, whose own need (what its
   facts say a taker needs) is `need`. */
static int share_plan_role_need(Compiler *c, int v, int role, int need) {
  if (role == SPR_READ || role == SPR_TEST) return SPN_BYTES;
  if (role == SPR_IDENTITY) return SPN_OBJECT;
  /* A box is copied by value, so a box of a String's bytes is a String of
     its own once a copy is changed in place: a box of a String no other
     name holds is a new handle, which every copy names, unless a copy is
     proven unseen (share_plan_box_plain), or the box goes into nothing
     that keeps it (share_plan_box_kept): a builtin that only reads it is
     handed the bytes. A frozen literal is its own object already. Any
     other value needs what a taker does. */
  if (role == SPR_BOX) {
    if (share_frozen_literal(c, v)) return SPN_BYTES;
    if (share_value_fresh(c, v, 0))
      return share_plan_box_plain(c, v) || !share_plan_box_kept(c, v) ? SPN_BYTES : SPN_NEW;
  }
  /* the store asks past the literal it splits (never less than the value) */
  if (role == SPR_STORE && need == SPN_BYTES) return share_plan_need_of(share_store_needs_handle(c, v));
  return need;
}

/* The plan of value v for a consumer in `role`, v's own need known. */
SharePlan share_plan_with_need(Compiler *c, int v, int role, int need) {
  need = share_plan_role_need(c, v, role, need);
  SharePlan p = { (unsigned char)need, SPS_BYTES, SPF_BYTES };
  if (need == SPN_BYTES) return p;
  p.supply = share_plan_supplies(c, v) ? SPS_HANDLE : SPS_BYTES;
  /* an exception's message asked its identity is the box the exception
     keeps it in (exc_message_identity_operand), which the identity reads
     where the value is read as bytes: no handle is attached to the read,
     so no other consumer has it */
  if (role == SPR_IDENTITY && p.supply == SPS_BYTES && exc_message_identity_operand(c, v)) p.supply = SPS_HANDLE;
  /* (an identity is the handle or the bytes' pointer; a frozen String's
     is its bytes' pointer, which every handle of it names too) */
  int bytes_id = role == SPR_IDENTITY && (p.supply == SPS_BYTES || share_plan_frozen(c, v));
  p.form = (unsigned char)(bytes_id ? SPF_BYTES : share_plan_form(p.need, p.supply));
  return p;
}

/* Asked live, as the return walk runs before the memo exists. */
int share_plan_return_box(Compiler *c, int v) {
  if (!repr_share_rule(c) || !c->share || v < 0) return 0;
  switch (nt_kind(c->nt, v)) {
  case NK_IfNode: case NK_UnlessNode: case NK_CaseNode: case NK_CaseMatchNode: case NK_BeginNode:
  case NK_ParenthesesNode: case NK_StatementsNode: case NK_OrNode: case NK_AndNode:
  case NK_RescueModifierNode: case NK_WhileNode: case NK_UntilNode:
    return 0;
  default: break;
  }
  if (repr_of(c, v).kind != RK_BOXED) return 0;
  return share_plan_with_need(c, v, SPR_TAKE, share_plan_need(c, v)).form == SPF_HANDLE;
}

const char *share_plan_role_name(int role) {
  static const char *const names[] = { "take", "read", "test", "store", "identity", "box" };
  return role >= SPR_TAKE && role <= SPR_BOX ? names[role] : "?";
}

int share_plan_role(Compiler *c, int v) {
  return c->share_plan && v >= 0 && v < c->share_plan_n ? c->share_plan[v] >> SPM_ROLE_SHIFT : SPR_TAKE;
}

int share_plan_second_role(Compiler *c, int v) { return share_plan_self_recv(c, v) >= 0 ? SPR_TEST : -1; }

/* Give node n's consumer `role`, and through parentheses and a statement
   list's last statement, the node whose value n is. */
static void share_plan_role_mark(Compiler *c, int n, int role) {
  const NodeTable *nt = c->nt;
  while (n >= 0 && n < c->share_plan_n) {
    c->share_plan[n] = (unsigned char)((c->share_plan[n] & SPM_NEED) | (role << SPM_ROLE_SHIFT));
    NodeKind k = nt_kind(nt, n);
    if (k == NK_ParenthesesNode) n = nt_ref(nt, n, "body");
    else if (k == NK_StatementsNode) {
      int bn = 0;
      const int *bv = nt_arr(nt, n, "body", &bn);
      n = bn > 0 ? bv[bn - 1] : -1;
    }
    else break;
  }
}

/* The elements a multiple write's value v -- an Array literal, and the
   literals splatted in it (`a, b = *[s, t]`) -- stores into its targets. */
static void share_plan_masgn_stores(Compiler *c, int v) {
  const NodeTable *nt = c->nt;
  v = an_unparen(nt, v);
  if (v >= 0 && nt_kind(nt, v) == NK_SplatNode) v = an_unparen(nt, nt_ref(nt, v, "expression"));
  if (v < 0 || nt_kind(nt, v) != NK_ArrayNode) return;
  int en = 0;
  const int *el = nt_arr(nt, v, "elements", &en);
  for (int i = 0; i < en; i++) {
    if (nt_kind(nt, el[i]) == NK_SplatNode) share_plan_masgn_stores(c, el[i]);
    else share_plan_role_mark(c, el[i], SPR_STORE);
  }
}

/* The operands of identity query n (equal?'s receiver and argument,
   object_id's and __id__'s receiver), where no class of the program
   defines its name: a method of the program's own takes them. An arm of
   a dynamic send shares the send's receiver, which the send takes. */
static void share_plan_identity_roles(Compiler *c, int n) {
  const NodeTable *nt = c->nt;
  const char *nm = nt_str(nt, n, "name");
  int recv = nt_ref(nt, n, "receiver"), args = nt_ref(nt, n, "arguments"), np = 0, an = 0;
  if (!nm || recv < 0 || nt_ref(nt, n, "block") >= 0 || !is_identity_query(nm) || is_freeze_family(nm) ||
      nt_int(nt, n, "dyn_arm", 0))
    return;
  int pair = is_equality_name(nm);
  const int *av = args >= 0 ? nt_arr(nt, args, "arguments", &an) : NULL;
  if (an != pair || call_plain_argc(c, n) != pair) return;
  const PolyCand *pc = comp_poly_candidates(c, nm, &np);
  for (int i = 0; i < np; i++)
    if (pc[i].mi >= 0 || pc[i].rdcls >= 0) return;
  share_plan_role_mark(c, recv, SPR_IDENTITY);
  if (pair) share_plan_role_mark(c, av[0], SPR_IDENTITY);
}

/* Is call n a freeze of a String variable's read (a local, an instance
   variable, a global or a constant), with no method of the program's own?
   The String it freezes is the one the variable holds: the C freezes the
   handle the variable's slot keeps (sp_String_freeze), whose flag every
   name of the String reads, and the read of the variable gives the bytes
   the call answers frozen. The variable's value is only read. */
static int share_plan_freeze_read(Compiler *c, int n) {
  const NodeTable *nt = c->nt;
  const char *nm = nt_str(nt, n, "name");
  int recv = an_unparen(nt, nt_ref(nt, n, "receiver")), tg[CPT_MAX];
  if (!nm || recv < 0 || !is_freeze_name(nm) || nt_ref(nt, n, "arguments") >= 0 || nt_ref(nt, n, "block") >= 0)
    return 0;
  NodeKind k = nt_kind(nt, recv);
  if (k != NK_LocalVariableReadNode && k != NK_InstanceVariableReadNode && !repr_static_read_kind(k)) return 0;
  return (c->ntype[recv] == TY_STRING || c->ntype[recv] == TY_STRBUF) && cplan_targets(c, n, tg, CPT_MAX) == 0;
}

/* The roles of the receivers that a builtin call only reads: a freeze of
   a variable's String (share_plan_freeze_read). */
static void share_plan_reader_roles(Compiler *c, int n) {
  if (share_plan_freeze_read(c, n)) share_plan_role_mark(c, nt_ref(c->nt, n, "receiver"), SPR_READ);
}

/* The roles other than a taker's, from the consumers that have them: an
   interpolation reads, a predicate tests, a multiple write stores each
   element of its value's literal (and of a literal splatted in it) into
   its target, an identity query asks its operands' identity, and a
   builtin that only reads its receiver reads it. One pass over each kind. */
static void share_plan_roles_build(Compiler *c) {
  const NodeTable *nt = c->nt;
  NT_FOREACH_KIND(nt, NK_EmbeddedStatementsNode, e) share_plan_role_mark(c, nt_ref(nt, e, "statements"), SPR_READ);
  static const NodeKind preds[] = { NK_IfNode, NK_UnlessNode, NK_WhileNode, NK_UntilNode };
  for (int k = 0; k < 4; k++)
    NT_FOREACH_KIND(nt, preds[k], n) share_plan_role_mark(c, nt_ref(nt, n, "predicate"), SPR_TEST);
  NT_FOREACH_KIND(nt, NK_MultiWriteNode, mw) share_plan_masgn_stores(c, nt_ref(nt, mw, "value"));
  NT_FOREACH_KIND(nt, NK_CallNode, n) {
    share_plan_identity_roles(c, n);
    share_plan_reader_roles(c, n);
  }
}

/* Does builtin call `call` keep or hand on the argument it is given: a
   store into its receiver's elements, a constructor, an ivar store, a proc
   call (its parameter keeps it), Array(); or answer it (2: its consumer
   decides)? A builtin that only reads it (0) is handed its bytes. */
static int share_plan_builtin_keeps(Compiler *c, int call) {
  const NodeTable *nt = c->nt;
  const char *nm = nt_str(nt, call, "name");
  int recv = nt_ref(nt, call, "receiver");
  if (!nm) return 0;
  TyKind rt = recv >= 0 ? c->ntype[recv] : TY_UNKNOWN;
  TyKind fams[6];
  int nf = 0;
  if (rt == TY_STRING || rt == TY_STRBUF) fams[nf++] = TY_STRING;
  else if (ty_is_array(rt) || ty_is_ptr_array(rt)) fams[nf++] = BOP_ANY_ARRAY;
  else if (ty_is_hash(rt)) fams[nf++] = BOP_ANY_HASH;
  else if (rt == TY_PROC || rt == TY_METHOD || rt == TY_CURRY) fams[nf++] = BOP_CALLABLE;
  else if (recv >= 0 && rt != TY_POLY && rt != TY_UNKNOWN) fams[nf++] = rt;
  else { fams[nf++] = BOP_ANY_ARRAY; fams[nf++] = BOP_ANY_HASH; fams[nf++] = TY_CLASS; fams[nf++] = BOP_CALLABLE; }
  fams[nf++] = BOP_ANY_RECV;
  int keep = 0;
  for (int i = 0; i < nf; i++) {
    switch (bop_share_named(fams[i], nm)) {
    case BSH_STORE_LAST: case BSH_STORE_ALL: case BSH_STORE_TAIL: case BSH_MERGE: case BSH_ARRAY_OF:
    case BSH_CALL: case BSH_IVAR_SET: case BSH_EXEC: case BSH_NEW: case BSH_NEW_FILL: case BSH_NEW_DEFAULT:
    case BSH_NEW_FIELDS: case BSH_FILL: case BSH_SUM:
      return 1;
    case BSH_LAST: case BSH_FETCH:
      keep = 2;
      break;
    default: break;
    }
  }
  return keep;
}

static int share_plan_box_kept(Compiler *c, int v) {
  const NodeTable *nt = c->nt;
  int n = c->share_parent_n;
  /* the parents form a tree, so a walk of n steps reaches the root; the
     bound only guards a malformed map, and running out of it answers
     "kept": a handle is never wrong, bytes would be a copy */
  for (int depth = 0; depth < n; depth++) {
    int p = c->share_parent && v >= 0 && v < n ? c->share_parent[v] : -1;
    if (p < 0 || p >= n) return 0;
    const char *pty = nt_type(nt, p);
    /* (no node kinds of their own) an argument list's call, a `when` arm */
    if (is_arguments_node_type(pty)) {
      int call = c->share_parent[p];
      if (call < 0 || call >= n) return 0;
      if (nt_kind(nt, call) != NK_CallNode)
        return nt_kind(nt, call) == NK_SuperNode || nt_kind(nt, call) == NK_YieldNode;
      const CallPlan *cp = cplan_user(c, call);
      if (cp->mi >= 0 || cp->dispatch != CP_NONE) return 1;
      int k = share_plan_builtin_keeps(c, call);
      if (k != 2) return k;
      v = call;
      continue;
    }
    if (is_when_node_type(pty)) { v = p; continue; }
    switch (nt_kind(nt, p)) {
    /* a holder: a container literal, a variable, a constant, a value a
       method, block or jump hands on */
    case NK_ArrayNode: case NK_HashNode: case NK_KeywordHashNode:
    case NK_LocalVariableWriteNode: case NK_InstanceVariableWriteNode: case NK_GlobalVariableWriteNode:
    case NK_ClassVariableWriteNode: case NK_ConstantWriteNode: case NK_ConstantPathWriteNode:
    case NK_LocalVariableOrWriteNode: case NK_InstanceVariableOrWriteNode: case NK_GlobalVariableOrWriteNode:
    case NK_ClassVariableOrWriteNode: case NK_LocalVariableAndWriteNode: case NK_InstanceVariableAndWriteNode:
    case NK_GlobalVariableAndWriteNode: case NK_ClassVariableAndWriteNode: case NK_MultiWriteNode:
    case NK_ReturnNode: case NK_NextNode: case NK_BreakNode: case NK_YieldNode: case NK_SplatNode:
    case NK_DefNode: case NK_BlockNode: case NK_LambdaNode: case NK_OptionalParameterNode:
    case NK_OptionalKeywordParameterNode:
      return 1;
    case NK_AssocNode:
      /* a Hash keeps a value; a String key is copied and frozen */
      if (nt_ref(nt, p, "value") != v) return 0;
      v = p;
      continue;
    /* the value of a conditional, a sequence's last statement, a group:
       its own consumer decides */
    case NK_ParenthesesNode: case NK_IfNode: case NK_UnlessNode: case NK_ElseNode:
    case NK_CaseNode: case NK_InNode: case NK_CaseMatchNode: case NK_AndNode: case NK_OrNode: case NK_BeginNode:
    case NK_RescueModifierNode:
      v = p;
      continue;
    case NK_StatementsNode: {
      int bn = 0;
      const int *bv = nt_arr(nt, p, "body", &bn);
      if (bn <= 0 || bv[bn - 1] != v) return 0;
      v = p;
      continue;
    }
    default:
      return 0;
    }
  }
  return 1;
}

/* Is node v, a new String, an element of a container literal a holder
   keeps whose elements share_node_elems_local proves its own? No other
   name can tell a copy of its box from the String there, and a handle
   would cost an allocation and a copy per box. */
static int share_plan_box_plain(Compiler *c, int v) {
  const NodeTable *nt = c->nt;
  int n = c->share_parent_n, p = c->share_parent && v >= 0 && v < n ? c->share_parent[v] : -1;
  while (p >= 0 && p < n && nt_kind(nt, p) == NK_ParenthesesNode) p = c->share_parent[p];
  if (p >= 0 && p < n && nt_kind(nt, p) == NK_AssocNode) p = c->share_parent[p];
  if (p < 0 || p >= n || (nt_kind(nt, p) != NK_ArrayNode && nt_kind(nt, p) != NK_HashNode)) return 0;
  /* (a temporary literal is not: the walk joins an element read off it,
     `[s, 1].first`, to no class of the literal's) */
  return share_node_anchored(c, p) && share_node_elems_local(c, p);
}

void share_plan_free(Compiler *c) {
  free(c->share_parent);
  c->share_parent = NULL;
  c->share_parent_n = 0;
  free(c->share_plan);
  free(c->share_plan_ty);
  free(c->share_sup);
  c->share_plan = NULL;
  c->share_plan_ty = NULL;
  c->share_sup = NULL;
  c->share_plan_n = c->share_sup_n = 0;
}

/* Once per compile, over the node table: each node's need, with the type
   and the table version it was asked under, and its consumer's role. */
void share_plan_build(Compiler *c) {
  share_plan_free(c);
  if (!repr_share_rule(c) || !c->share) return;
  int n = c->nt->count;
  c->share_plan = malloc((size_t)n + 1);
  c->share_plan_ty = malloc(sizeof *c->share_plan_ty * ((size_t)n + 1));
  if (!c->share_plan || !c->share_plan_ty) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  for (int v = 0; v < n; v++) {
    Scope *sc = comp_scope_of(c, v);
    c->share_plan[v] = sc && !sc->reachable ? SPN_ASK : (unsigned char)share_plan_need(c, v);
    c->share_plan_ty[v] = c->ntype[v];
  }
  c->share_plan_n = n;
  c->share_plan_ver = c->nt->version;
  share_plan_roles_build(c);
  c->share_parent = an_parent_map(c->nt);
  if (!c->share_parent) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  c->share_parent_n = n;
}

/* Is codegen where the memo may answer: the node read as itself (no view,
   no scope move, no splice) and no poly dispatch arm open? */
static int share_plan_plain_ctx(void) {
  return cplan_plain_ctx() && g_arm.pd_skip < 0 && g_arm.prbd_skip < 0 && !g_arm.builtin_arm &&
         g_arm.send_split < 0;
}

int share_plan_memo_need(Compiler *c, int v) {
  int m = c->share_plan && v >= 0 && v < c->share_plan_n && (c->share_plan[v] & SPM_NEED) != SPN_ASK &&
          c->nt->version == c->share_plan_ver && c->ntype[v] == c->share_plan_ty[v] && share_plan_plain_ctx();
  return m ? c->share_plan[v] & SPM_NEED : -1;
}

SharePlan share_plan_of(Compiler *c, int v, int role, int *memo) {
  int m = share_plan_memo_need(c, v);
  if (memo) *memo = m >= 0;
  SharePlan p = share_plan_with_need(c, v, role, m >= 0 ? m : share_plan_need(c, v));
  /* (the producer, where the supply was asked) */
  if (p.need != SPN_BYTES) p.kind = (unsigned char)share_plan_producer(c, v, NULL);
  return p;
}
