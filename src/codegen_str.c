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
#include "call_plan.h"
#include "codegen_call_arms.h"
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
  if ((arg_ran_first(v, 0) && str_var_read(c, v)) || !strbuf_slot_text(c, v, &sf->expr)) return 0;
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

/* Does route v name the handle it hands on, never a new one: `String(x)`,
   `+x`, a conversion or freeze over a variable's slot
   (strbuf_self_route_slot), an attribute assignment the rule shares or a
   bang or freeze over one (strbuf_assign_route), a String clamp
   (strbuf_route_clamp), a spliced yield whose block's tail is held
   (strbuf_yield_tail_held)? Any other route makes a handle around a
   String that has none where it runs, which would be another object. */
static int str_route_names_handle(Compiler *c, int v) {
  Buf ref; memset(&ref, 0, sizeof ref);
  int up = 0, ops[3];
  int named = strbuf_self_route_slot(c, v, &up, &ref);
  free(ref.p);
  return named || strbuf_assign_route(c, v) ||
         strbuf_route_clamp(c, v, ops) ||
         (nt_kind(c->nt, unwrap_parens(c, v)) == NK_YieldNode && strbuf_yield_tail_held(c));
}

/* Node v's identity in the plan's form, as what its producer holds it in:
   a handle (sf->cty TY_STRBUF), bytes (TY_STRING) or a box (TY_POLY).
   Where the plan gives the handle, the producer's:
     - a box: the one an exception keeps its message in (also a text read
       off a box that may hold one: exc_message_box_operand), one the value
       already is (a narrowed box, a bang on a boxed receiver), a String
       Range endpoint's (the handle the Range keeps, else the String it
       holds), the box a proc's answer or a spliced call's tails are handed
       on in (emit_strbuf_route_box), a call's published handle else the
       String it answered (emit_strbuf_pickup), or a route over a box
       answering the String the box holds, read live and boxed by
       sp_box_str as the handle that owns it (no copy);
     - a handle: a variable's or a reader's slot, an element a String
       Array of handles reads or removes, a call answering its receiver
       (emit_bang_self_handle), a route that names its handle
       (str_route_names_handle);
   and else the value as it is emitted: its bytes, or the handle it is
   held as. Nothing here makes a handle around bytes: a new handle is
   another object, and the bytes are the identity of a String no handle
   holds. */
static int str_render_ident(Compiler *c, int v, int form, StrForm *sf) {
  Buf *b = &sf->expr;
  /* parentheses that run statements ahead of their value: the statements,
     then the value's identity, which a statement can change (`(s << x;
     e.message)`) */
  const NodeTable *nt = c->nt;
  int body = v >= 0 && nt_kind(nt, v) == NK_ParenthesesNode ? nt_ref(nt, v, "body") : -1, n = 0;
  const int *bv = body >= 0 && nt_kind(nt, body) == NK_StatementsNode ? nt_arr(nt, body, "body", &n) : NULL;
  if (n >= 2 && !arg_ran_first(v, 0) && !stmts_diverge(c, body)) {
    Buf pre;
    memset(&pre, 0, sizeof pre);
    Buf *sv = g_pre;
    g_pre = &pre;
    for (int i = 0; i < n - 1; i++) emit_stmt(c, bv[i], g_pre, 0);
    StrForm last;
    memset(&last, 0, sizeof last);
    int lf = str_render_ident(c, bv[n - 1], c->share_plan ? share_plan_of(c, bv[n - 1], SPR_IDENTITY, NULL).form
                                                         : SPF_HANDLE, &last);
    g_pre = sv;
    buf_printf(b, "({ %s%s; })", pre.p ? pre.p : "", last.expr.p ? last.expr.p : "");
    sf->cty = last.cty;
    sf->needs |= last.needs;
    free(pre.p);
    str_form_free(&last);
    return lf;
  }
  Repr r = repr_of(c, v);
  int bx, u = strbuf_srange_tail(c, v);
  sf->cty = TY_POLY;
  if (form != SPF_HANDLE) { }
  else if (exc_message_identity_operand(c, v) || exc_message_box_operand(c, v)) {
    emit_exc_message_idbox(c, v, b);
    return SPF_HANDLE;
  }
  else if (r.kind == RK_BOXED || r.strbuf_src == RS_SLOT_POLY || face_str_bang_call(c, v) || u >= 0) {
    /* (a min or max can be a String of its own, which
       sp_srange_extreme_h makes) */
    if (u >= 0 && !strbuf_route_srange_end(c, u)) sf->needs |= SF_ALLOCATES;
    emit_boxed(c, v, b);
    return SPF_HANDLE;
  }
  else if (emit_strbuf_route_box(c, v, b)) return SPF_HANDLE;
  /* (an element a String Array of handles reads or removes is that
     handle, as a slot's is) */
  else if (strh_handle_call(c, v)) {
    sf->cty = TY_STRBUF;
    if (g_share_check) share_check_mark(c, v, 'H', b);
    strh_elem_handle_text(c, v, b);
    return SPF_HANDLE;
  }
  else if (repr_call_returns_handle(c, v)) {
    emit_strbuf_pickup(c, v, 1, b);
    return SPF_HANDLE;
  }
  else if ((bx = share_plan_producer(c, v, NULL) == SPK_OPERAND ? strbuf_route_box_operand(c, v) : -1) >= 0) {
    size_t at = b->len;
    buf_puts(b, "sp_box_str(");
    emit_expr(c, v, b);
    buf_puts(b, ")");
    if (g_share_check) {
      share_check_declare_reads(b, at, v);
      share_check_declare_reads(b, at, bx);
    }
    return SPF_HANDLE;
  }
  else {
    sf->cty = TY_STRBUF;
    /* (--share-check sees the handle these name: emit_expr's own mark is
       not on their path) */
    if (strbuf_slot_has(c, v)) {
      if (g_share_check) share_check_mark(c, v, 'H', b);
      strbuf_slot_text(c, v, b);
      return SPF_HANDLE;
    }
    /* (the text of a handle these name is that handle: the marks of the
       node's own expressions in it, read as bytes by the check, are no
       read) */
    size_t at = b->len;
    if (bang_self_handle_has(c, v) && emit_bang_self_handle(c, v, b)) {
      if (g_share_check) share_check_declare_reads(b, at, v);
      return SPF_HANDLE;
    }
    if (str_route_names_handle(c, v)) {
      Buf hb;
      memset(&hb, 0, sizeof hb);
      int named = emit_strbuf_route(c, v, &hb);
      if (named) buf_puts(b, hb.p ? hb.p : "NULL");
      free(hb.p);
      if (named) {
        if (g_share_check) share_check_declare_reads(b, at, v);
        return SPF_HANDLE;
      }
    }
  }
  sf->cty = r.as_ty == TY_STRBUF ? TY_STRBUF : r.as_ty == TY_POLY ? TY_POLY : TY_STRING;
  emit_expr(c, v, b);
  return sf->cty == TY_STRBUF ? SPF_HANDLE : SPF_BYTES;
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
  case SPX_IDENT:
    return str_render_ident(c, v, form, sf);
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

/* Is v an operand whose identity is a String's: typed a String, or an
   exception's message asked its identity? */
static int str_identity_operand(Compiler *c, int v) {
  TyKind t = comp_recv_type(c, v);
  return t == TY_STRING || t == TY_STRBUF || exc_message_identity_operand(c, v);
}

/* Operand v of an identity comparison: a String through the plan, any
   other value as the box it is held in. */
static void str_identity_operand_form(Compiler *c, int v, StrForm *sf) {
  if (str_identity_operand(c, v)) {
    emit_str_form(c, v, SPR_IDENTITY, SPX_IDENT, 0, sf);
    return;
  }
  Buf bx;
  memset(&bx, 0, sizeof bx);
  emit_boxed(c, v, &bx);
  str_form_of_text(sf, bx.p ? bx.p : "sp_box_nil()", TY_POLY, 0);
  free(bx.p);
}

/* Form sf (written as `e`) as a box: a handle's box, sp_box_str of bytes
   (the handle that owns them, if one does), a box as it is. */
static void str_identity_box_text(const StrForm *sf, const char *e, Buf *b) {
  if (sf->cty == TY_POLY) buf_puts(b, e);
  else buf_printf(b, sf->cty == TY_STRBUF ? "sp_box_nullable_obj(%s, SP_BUILTIN_STRBUF)" : "sp_box_str(%s)", e);
}

/* --share-strings: `x.equal?(y)` where a side is a String: both operands
   in the plan's form for an identity (SPX_IDENT). Two handles, or two
   bytes, are one object exactly when they are one pointer; otherwise both
   are boxed and sp_poly_equal compares them, which takes a frozen
   handle's identity as its bytes' and bytes a handle owns as that handle.
   It answers for a String receiver whose equal? is the builtin, and for
   any other receiver where no class of the program defines equal? (the
   plan's identity role). The receiver runs first, bound once, and stays
   rooted while the argument runs where that may allocate: the argument's
   own evaluation (operand_may_allocate) or its form (SF_ALLOCATES). A `&.`
   call is asked again past its nil guard. 0, with nothing emitted, for
   any other call. */
int emit_str_equal(Compiler *c, int id, Buf *b) {
  const NodeTable *nt = c->nt;
  const char *nm = nt_str(nt, id, "name");
  int recv = nt_ref(nt, id, "receiver"), argc = 0, tg[CPT_MAX];
  if (!c->share_plan || !nm || !is_equal_name(nm) || recv < 0 || nt_ref(nt, id, "block") >= 0 ||
      sn_guard_pending(c, id))
    return 0;
  const int *argv = call_args(nt, id, &argc);
  if (argc != 1 || call_has_splat_arg(nt, argv, argc)) return 0;
  TyKind rt = comp_recv_type(c, recv);
  int builtin = (rt == TY_STRING || rt == TY_STRBUF) && cplan_targets(c, id, tg, CPT_MAX) == 0;
  if (!builtin && !(share_plan_role(c, recv) == SPR_IDENTITY &&
                    (str_identity_operand(c, recv) || str_identity_operand(c, argv[0]))))
    return 0;
  StrForm x, y;
  str_identity_operand_form(c, recv, &x);
  str_identity_operand_form(c, argv[0], &y);
  /* (a handle against bytes is boxed too: sp_poly_equal takes a frozen
     handle's identity as its bytes', and bytes a handle owns as that
     handle) */
  int box = x.cty == TY_POLY || y.cty == TY_POLY || x.cty != y.cty;
  x.needs |= SF_EVAL_ONCE;
  if (operand_may_allocate(c, argv[0]) || (y.needs & SF_ALLOCATES)) x.needs |= SF_ROOT_UNTIL_USE;
  str_form_settle(c, &x, b);
  char xt[32];
  snprintf(xt, sizeof xt, "_t%d", x.tmp);
  Buf yb;
  memset(&yb, 0, sizeof yb);
  str_form_settle(c, &y, &yb);
  if (box) {
    buf_puts(b, "sp_poly_equal(");
    str_identity_box_text(&x, xt, b);
    buf_puts(b, ", ");
    str_identity_box_text(&y, yb.p ? yb.p : "NULL", b);
    buf_puts(b, ")");
  }
  /* (two handles, or two bytes, are one object exactly when they are one
     pointer) */
  else if (x.cty == TY_STRBUF) buf_printf(b, "(sp_bool)(%s == %s)", xt, yb.p ? yb.p : "NULL");
  else buf_printf(b, "(sp_bool)((const void *)(%s) == (const void *)(%s))", xt, yb.p ? yb.p : "NULL");
  free(yb.p);
  str_form_close(&x, b);
  str_form_free(&x);
  str_form_free(&y);
  /* (the operands run in order ahead of one comparison, which cannot
     raise: a boxed receiver's call needs no head, nil_target_runs_in_call) */
  c->args_in_call = recv;
  return 1;
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
   A form that needs both is rooted where its temp is bound, as the
   consumers that held an operand ahead of the next one wrote it: a box has
   no NULL to be declared with ahead of the statement, and an expression
   need not have a statement ahead of it (g_pre). One that needs neither
   is its expression. SF_ALLOCATES asks nothing of the form itself: it is
   for the values live across it. */
void str_form_settle(Compiler *c, StrForm *sf, Buf *b) {
  const char *e = sf->expr.p ? sf->expr.p : "";
  Buf rb;
  memset(&rb, 0, sizeof rb);
  int bound_root = (sf->needs & SF_ROOT_UNTIL_USE) && (sf->needs & SF_EVAL_ONCE);
  if ((sf->needs & SF_ROOT_UNTIL_USE) && !bound_root) {
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
    if (bound_root) buf_printf(b, sf->cty == TY_POLY ? "SP_GC_ROOT_RBVAL(_t%d); " : "SP_GC_ROOT(_t%d); ", sf->tmp);
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
