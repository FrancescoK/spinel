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

   No emitter reads the plan yet, and nothing is refused by it: --share-check
   (share_check.c) reads it at each site it marks and reports how often it
   agrees with the conversion the emitted C has there.

   repr_of is not memoised, and neither is anything that reads it. The
   need reads the share facts, final at seal, the node's type, names and
   scope's reachability; it is memoised at the end of repr_seal, one byte
   per node. Each guard of the memo covers one way codegen makes a node
   read as something else:
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
   --share-check asks the need live too: the memo is measured, never
   trusted, until an emitter reads it. */

#include <stdlib.h>
#include "codegen_internal.h"
#include "builtin_ops.h"
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

/* The supply node v decides by itself (rules 1, 2 and 4 below), or -1
   when it is a call answering its String receiver, whose supply is the
   receiver's: *recv is then that receiver. */
static int share_plan_supply_at(Compiler *c, int v, int *recv) {
  Repr r = repr_of(c, v);
  *recv = -1;
  if (r.kind == RK_BOXED) return 1;
  if (r.kind == RK_STRBUF) return r.strbuf_src != RS_FRESH;
  int rv = share_plan_self_recv(c, v);
  if (rv >= 0) { *recv = rv; return -1; }
  /* a new String (share_value_fresh) has no handle to hand over, whatever
     a route says about whether its copy can be seen */
  return share_node_carries_handle(c, v) && !share_value_fresh(c, v, 0);
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
  return r.kind == e->kind && r.strbuf_src == e->src && share_plan_supply_at(c, e->d, &rv) == e->val;
}

/* Can node v's producer hand over the String's handle?
     1. a box hands over itself, whatever it holds: a String boxed elsewhere
        was planned where it was boxed;
     2. a value represented as the handle has it, unless repr_of says the
        handle is a new one wrapped around its bytes where it is demanded
        (RS_FRESH);
     3. a call that answers its String receiver hands over what that
        receiver does;
     4. any other value, represented as its bytes, has one where the routes
        the analysis checks a carry against hand it along
        (share_node_carries_handle: a callee that publishes it, a bang over
        a slot that holds it, a variable whose slot holds it), unless it is
        a new String.
   A chain of rule 3 is asked at each of its links, outermost first: the
   walk down it keeps each link's answer with the node that decided it
   (Compiler.share_sup), and a link asked again reads it while the view
   epoch and the table's version are the same and the deciding node still
   decides it the same way, so a chain costs its length once, not once per
   link. Nothing outside the chain's own emission can change a link in
   between: an emitter retypes a block parameter's local, which no
   receiver chain outside the block reaches. */
static int share_plan_supplies(Compiler *c, int v) {
  int rv, s = share_plan_supply_at(c, v, &rv);
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
  while ((s = share_plan_supply_at(c, d, &rv)) < 0) {
    if (d < n && share_plan_sup_valid(c, &c->share_sup[d])) { s = c->share_sup[d].val; d = c->share_sup[d].d; break; }
    d = rv;
  }
  Repr r = repr_of(c, d);
  struct SharePlanSup fill = { view_epoch(), c->nt->version, d, r.kind, r.strbuf_src, (unsigned char)s, 1 };
  for (int l = v; l >= 0 && l < n && l != d; l = share_plan_self_recv(c, l)) c->share_sup[l] = fill;
  return s;
}

/* the memo's mark of a node whose scope was unreachable at seal: codegen
   can still make its method reachable, so its need is asked live */
enum { SPN_ASK = 3 };

static int share_plan_need(Compiler *c, int v) {
  int need = share_value_needs_handle(c, v);
  return need == SHN_NO ? SPN_BYTES : need == SHN_FRESH ? SPN_NEW : SPN_OBJECT;
}

/* The plan of value v, whose need is known. */
static SharePlan share_plan_with(Compiler *c, int v, int need) {
  SharePlan p = { (unsigned char)need, SPS_BYTES, SPF_BYTES };
  if (need == SPN_BYTES) return p;
  p.supply = share_plan_supplies(c, v) ? SPS_HANDLE : SPS_BYTES;
  p.form = (unsigned char)share_plan_form(p.need, p.supply);
  return p;
}

SharePlan share_plan_live(Compiler *c, int v) { return share_plan_with(c, v, share_plan_need(c, v)); }

void share_plan_free(Compiler *c) {
  free(c->share_plan);
  free(c->share_plan_ty);
  free(c->share_sup);
  c->share_plan = NULL;
  c->share_plan_ty = NULL;
  c->share_sup = NULL;
  c->share_plan_n = c->share_sup_n = 0;
}

/* Once per compile, over the node table: each node's need, with the type
   and the table version it was asked under. */
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
}

/* Is codegen where the memo may answer: the node read as itself (no view,
   no scope move, no splice) and no poly dispatch arm open? */
static int share_plan_plain_ctx(void) {
  return cplan_plain_ctx() && g_arm.pd_skip < 0 && g_arm.prbd_skip < 0 && !g_arm.builtin_arm &&
         g_arm.send_split < 0;
}

int share_plan_memo_need(Compiler *c, int v) {
  int m = c->share_plan && v >= 0 && v < c->share_plan_n && c->share_plan[v] != SPN_ASK &&
          c->nt->version == c->share_plan_ver && c->ntype[v] == c->share_plan_ty[v] && share_plan_plain_ctx();
  return m ? c->share_plan[v] : -1;
}

SharePlan share_plan_of(Compiler *c, int v, int *memo) {
  int m = share_plan_memo_need(c, v);
  if (memo) *memo = m >= 0;
  return share_plan_with(c, v, m >= 0 ? m : share_plan_need(c, v));
}
