/* codegen_str.c -- a String value rendered in the form its plan gives (#8328).

   The String plan (share_plan.c) says, for a value and the role of the
   consumer that takes it, whether that consumer gets the String's handle,
   its bytes, or its bytes wrapped into a new handle. emit_str_form is the
   one place a consumer that reads the plan asks for the value: it names its
   role (SPR_*) and the face it holds the value in (SPX_*, codegen_internal.h),
   and gets the C expression of the plan's form in that face. Consumers
   move to it one family at a time; the others still decide on their own.

   A form says what its expression needs from where it is used (StrForm's
   needs: to be evaluated once, to stay rooted until its use) rather than
   holding or rooting it itself, and str_form_settle meets those needs.
   Where the value is evaluated in the consumer's order, and what holds it
   while other operands run, stays with the consumer.

   Without --share-strings there is no plan, and the producer decides as it
   did: a String the default build keeps as a shared handle (#3227) is that
   handle where its renderer names one. */

#include "codegen_internal.h"
#include "repr.h"
#include "share.h"

/* Node v's object id, in the plan's form: the handle's where the plan
   gives the handle -- strbuf_object_ref names it for each producer that
   has one: a variable's slot, a box, a Range's kept endpoint, a route over
   a handle, the box an exception keeps its message in -- and else the
   bytes' address; a String that can be nil answers nil's id when it is
   nil. An identity is never wrapped or refused. Answers the form it
   rendered: the bytes' where strbuf_object_ref names no handle, as it did
   before the plan was read. */
static int str_render_id(Compiler *c, int v, int form, StrForm *sf) {
  Buf *b = &sf->expr;
  if (form == SPF_HANDLE && strbuf_object_ref(c, v, b)) {
    /* (a String Range's min or max can be a String of its own, which
       sp_srange_extreme_h makes: strbuf_object_ref's arm for it, after the
       exception message's and the endpoints') */
    if (!exc_message_identity_operand(c, v) && !strbuf_route_srange_end(c, v) && strbuf_route_srange_extreme(c, v))
      sf->needs |= SF_ALLOCATES;
    return SPF_HANDLE;
  }
  if (comp_recv_type(c, v) == TY_STRING && repr_of(c, v).may_nil) {
    int t = ++g_tmp;
    buf_printf(b, "({ sp_RbVal _t%d = ", t);
    emit_boxed(c, v, b);
    buf_printf(b, "; _t%d.tag == SP_TAG_NIL ? SP_NIL_OBJECT_ID : (sp_int)(uintptr_t)_t%d.v.p; })", t, t);
  }
  else {
    buf_puts(b, "((sp_int)(uintptr_t)(");
    emit_expr(c, v, b);
    buf_puts(b, "))");
  }
  return SPF_BYTES;
}

/* Is node v a read of a variable (a local, an ivar, a global, a class
   variable or a constant), which hands over the handle its slot holds? */
static int str_var_read(Compiler *c, int v) {
  NodeKind k = nt_kind(c->nt, v);
  return k == NK_LocalVariableReadNode || k == NK_InstanceVariableReadNode || repr_static_read_kind(k);
}

/* Is node v `+"lit"`, a String literal's mutable copy? */
static int str_uplus_literal(Compiler *c, int v) {
  const NodeTable *nt = c->nt;
  if (nt_kind(nt, v) != NK_CallNode) return 0;
  const char *nm = nt_str(nt, v, "name");
  int r = nt_ref(nt, v, "receiver");
  return nm && is_unary_plus(nm) && nt_ref(nt, v, "arguments") < 0 && r >= 0 && nt_kind(nt, r) == NK_StringNode;
}

/* The handle arms of str_render_handle, each answering 1 with the handle
   rendered, or 0 with nothing emitted: a value that ran ahead of the
   binding (the handle it took there); a route over a handle; a variable's
   slot. */
static int str_handle_ran_first(Compiler *c, int v, StrForm *sf) {
  int ran = arg_ran_first(v, 0), late = ran && str_var_read(c, v);
  if (ran_first_handle(v) < 0 || (!late && !(repr_share_rule(c) && ran))) return 0;
  buf_printf(&sf->expr, "_t%d", ran_first_handle(v));
  return 1;
}
static int str_handle_route(Compiler *c, int v, StrForm *sf) {
  if (arg_ran_first(v, 0) || str_var_read(c, v) || repr_of(c, v).as_ty != TY_STRING || !strbuf_arg_carries(c, v)) return 0;
  emit_strbuf_handle_of(c, v, &sf->expr);
  return 1;
}
static int str_handle_slot(Compiler *c, int v, StrForm *sf) {
  char sref[192];
  if ((arg_ran_first(v, 0) && str_var_read(c, v)) || !strbuf_slot_ref(c, v, sref, sizeof sref)) return 0;
  buf_puts(&sf->expr, sref);
  return 1;
}

/* ...and the new handle made of a value's bytes, which no other name sees
   (a box's: the handle it holds where the form is the handle) */
static int str_handle_new(Compiler *c, int v, int form, unsigned dest, StrForm *sf) {
  Buf *b = &sf->expr;
  NodeKind k = nt_kind(c->nt, v);
  int own = (dest & SFD_OWN) && k != NK_LocalVariableReadNode && k != NK_InstanceVariableReadNode;
  if (!arg_ran_first(v, 0) && (dest & SFD_OWN) && str_uplus_literal(c, v)) {
    buf_puts(b, "sp_String_new_unfrozen(");
    emit_expr(c, nt_ref(c->nt, v, "receiver"), b);
    buf_puts(b, ")");
    sf->needs |= SF_ALLOCATES;
    return SPF_WRAP;
  }
  if (comp_ntype(c, v) == TY_NIL) {
    buf_puts(b, "NULL");
    return SPF_BYTES;
  }
  if (repr_of(c, v).kind == RK_BOXED) {
    int t = ++g_tmp;
    buf_puts(b, "({ ");
    t = hold_operand(c, v, TY_POLY, 0, t, 1, " ", b);
    /* (a box that holds a String's handle is that handle; a String's own
       box, or anything else, is converted as the slot takes it) */
    if (form == SPF_HANDLE)
      buf_printf(b, "sp_poly_nil_p(_t%d) ? NULL : sp_poly_is_strbuf(_t%d) ? sp_poly_as_strbuf(_t%d) : ", t, t, t);
    else buf_printf(b, "sp_poly_nil_p(_t%d) ? NULL : ", t);
    buf_printf(b, "%s(sp_poly_arg_str_chk(_t%d)); })", own ? "sp_String_new_fresh" : "sp_String_new_shared", t);
    sf->needs |= SF_ALLOCATES;
    return form == SPF_HANDLE ? SPF_HANDLE : SPF_WRAP;
  }
  buf_printf(b, "%s(", own ? "sp_String_new_fresh" : strbuf_new_func(c, v));
  emit_str_expr(c, v, b);
  buf_puts(b, ")");
  sf->needs |= SF_ALLOCATES;
  return SPF_WRAP;
}

/* Node v as the handle a handle slot takes (a method's parameter that is
   the shared handle), in the plan's form. Where the plan gives the handle,
   or gives no form (without --share-strings, or where the value's own
   need is no more than its bytes or a new handle), the producer's handle
   is handed over where it has one, in this order:
     - a local buffer's write: that local's buffer;
     - a value that ran ahead of the binding (arg_ran_first): the handle it
       took there (ran_first_handle), a variable's at its read, so a later
       argument that writes the variable does not change what is bound;
     - a route over a handle (strbuf_arg_carries): emit_strbuf_handle_of;
     - a variable that holds the handle: its slot;
   and else a new handle is made of its bytes, which no other name sees
   (str_handle_new):
     - `+"lit"` into a slot that holds its own copy (SFD_OWN): straight
       from the literal;
     - nil: the NULL handle a nullable slot reads as nil
       (`def initialize(o: nil)`);
     - a box: the NULL handle where it holds nil (converted as a String
       first, it raised TypeError where CRuby binds nil), else a handle of
       its String; where the plan gives the handle, a box that holds a
       String's handle hands over that handle (a box of a String that can
       change holds its handle), which a copy of its bytes would fork;
     - any other value: a handle made of its bytes (SF_ALLOCATES), with the
       bytes inside the object for a slot that holds its own copy.
   Under --share-strings the producer's kind (share_plan_producer) picks
   the arms instead, one render per kind (str_handle_by_kind). A form the
   plan gives the handle that no arm hands over (a renderer gap the seal
   did not see, under a view or an arm) is the new handle, as before the
   plan was read; --share-check reports it. Answers the form rendered. */
static int str_handle_by_kind(Compiler *c, int v, int form, unsigned dest, StrForm *sf);
static int str_render_handle(Compiler *c, int v, int form, unsigned dest, StrForm *sf) {
  sf->cty = TY_STRBUF;
  if (c->share_plan) return str_handle_by_kind(c, v, form, dest, sf);
  if (emit_strbuf_local_write_handle(c, v, &sf->expr)) return SPF_HANDLE;
  if (str_handle_ran_first(c, v, sf) || str_handle_route(c, v, sf) || str_handle_slot(c, v, sf)) return SPF_HANDLE;
  return str_handle_new(c, v, form, dest, sf);
}

/* --share-strings: the handle face's render of each producer kind
   (share.h's SPK_*), asked where the value is bound:
     NONE, FROZEN   a new handle of the bytes, which for a frozen literal
                    is the literal's own (sp_String_new_shared), after a
                    value that ran first, which holds what it took;
     BOX            the box's handle or a handle of its String (a box
                    that ran first is the handle it took);
     any other      the handle the producer hands on: a local buffer's
                    write, a value that ran first, a route over a handle,
                    a variable's slot; a kind none of these renders (a
                    renderer gap) is the new handle. */
static int str_handle_by_kind(Compiler *c, int v, int form, unsigned dest, StrForm *sf) {
  int kind = share_plan_producer(c, v, NULL);
  _Static_assert(SPK__COUNT == 23, "a handle render for each producer kind");
  switch (kind) {
  case SPK_NONE: case SPK_FROZEN: case SPK_BOX:
    if (str_handle_ran_first(c, v, sf)) return SPF_HANDLE;
    return str_handle_new(c, v, form, dest, sf);
  case SPK_SLOT: case SPK_DEMANDED: case SPK_ELEM: case SPK_SLOT_POLY: case SPK_SELF: case SPK_BANG_BOX:
  case SPK_PROC_CALL: case SPK_POLY_ARMS: case SPK_EXC_MESSAGE: case SPK_EXC_SUPER: case SPK_PUBLISHED:
  case SPK_READER: case SPK_WRITE: case SPK_ASSIGN: case SPK_OPERAND: case SPK_BLOCK_VALUE: case SPK_YIELD:
  case SPK_COND: case SPK_SEQUENCE: case SPK_LIFT:
    if (emit_strbuf_local_write_handle(c, v, &sf->expr)) return SPF_HANDLE;
    if (str_handle_ran_first(c, v, sf) || str_handle_route(c, v, sf) || str_handle_slot(c, v, sf)) return SPF_HANDLE;
    return str_handle_new(c, v, form, dest, sf);
  }
  return str_handle_new(c, v, form, dest, sf);
}

int emit_str_form(Compiler *c, int v, int role, int face, unsigned dest, StrForm *sf) {
  memset(sf, 0, sizeof *sf);
  /* (the plan exists where share_plan_build made it: under the flag, once
     the share facts are built) */
  int form = c->share_plan ? share_plan_of(c, v, role, NULL).form : SPF_HANDLE;
  switch (face) {
  case SPX_ID:
    sf->cty = TY_INT;
    return str_render_id(c, v, form, sf);
  case SPX_HANDLE:
    /* (without a plan, the producer decides, as a form the plan does not
       give the handle does: no box is read as its handle) */
    return str_render_handle(c, v, c->share_plan ? form : SPF_BYTES, dest, sf);
  }
  return form;
}

/* Node v into a slot that holds the shared handle, rendered whole: the
   handle face with the taker's role, its needs met. */
void emit_str_form_handle(Compiler *c, int v, Buf *b) {
  StrForm sf;
  emit_str_form(c, v, SPR_TAKE, SPX_HANDLE, 0, &sf);
  str_form_settle(c, &sf, b);
  str_form_free(&sf);
}

/* The seam between the String forms and the schedule: the one place a
   form's needs are met. Evaluation order, holds and roots are the schedule
   layer's (#8328), which is to replace this function; until it does, the
   needs are met with the helpers the sites used before they stated them,
   so the C is the one those sites wrote:
     SF_ROOT_UNTIL_USE  emit_rooted_conversion: a temp declared NULL and
                        rooted ahead of the statement (g_pre), assigned
                        where the value stands, so its evaluation does not
                        move;
     SF_EVAL_ONCE       a temp of the value's type bound in a statement
                        expression, `({ T _tN = <expr>; `, whose uses the
                        consumer writes and str_form_close ends.
   A form that needs both binds the rooted assignment in its temp, and
   one that needs neither is its expression. SF_ALLOCATES asks nothing
   of the form itself: it is for the values live across it. */
void str_form_settle(Compiler *c, StrForm *sf, Buf *b) {
  const char *e = sf->expr.p ? sf->expr.p : "";
  Buf rb;
  memset(&rb, 0, sizeof rb);
  if (sf->needs & SF_ROOT_UNTIL_USE) {
    emit_rooted_conversion(c, sf->cty, e, &rb);
    e = rb.p ? rb.p : "";
  }
  if (sf->needs & SF_EVAL_ONCE) {
    Buf ct;
    memset(&ct, 0, sizeof ct);
    emit_ctype(c, sf->cty, &ct);
    const char *t = ct.p ? ct.p : "void";
    size_t n = strlen(t);
    sf->tmp = ++g_tmp;
    /* (a pointer type's star stays with the name: `sp_String *_tN`) */
    buf_printf(b, "({ %s%s_t%d = %s; ", t, n && t[n - 1] == '*' ? "" : " ", sf->tmp, e);
    free(ct.p);
  }
  else buf_puts(b, e);
  free(rb.p);
}

void str_form_of_text(StrForm *sf, const char *expr, TyKind cty, unsigned needs) {
  memset(sf, 0, sizeof *sf);
  buf_puts(&sf->expr, expr);
  sf->cty = cty;
  sf->needs = needs;
}

void str_form_close(const StrForm *sf, Buf *b) {
  if (sf->needs & SF_EVAL_ONCE) buf_puts(b, "; })");
}

void str_form_free(StrForm *sf) {
  free(sf->expr.p);
  memset(sf, 0, sizeof *sf);
}
