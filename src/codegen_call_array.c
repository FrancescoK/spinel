/* codegen_call_array.c -- the builtin-op emitters of the Array family
   (BOP_ANY_ARRAY) that are more than one C text with its placeholders: an
   arm whose typed-array and poly-array forms differ in more than the
   variant's name ($A), or that builds its C in steps. The rest are
   templates in builtin_ops.c. emit_array_call looks the rows up after the
   arms every variant shares, so only an Int, Float, Str or poly array
   reaches these. Each answers 1 when it emitted the call, 0 (having
   emitted nothing) to leave it to the chain after the lookup. */

#include "codegen_internal.h"
#include "builtin_ops.h"

/* the element-kind name of the receiver: "Poly" or array_kind's */
static const char *arr_kind(TyKind rt) {
  return rt == TY_POLY_ARRAY ? "Poly" : array_kind(rt);
}

/* shift(n) / pop(n): the removed subarray, via the slice! splice (pop takes
   the tail, shift the head; n clamps to the length) */
int emit_op_array_shift_n(Compiler *c, const BopCtx *x, Buf *b) {
  const char *name = x->name;
  int recv = x->recv, argc;
  const int *argv = call_args(c->nt, x->id, &argc);
  if (x->rt == TY_POLY_ARRAY) {
    int t = ++g_tmp, tn2 = ++g_tmp;
    buf_printf(b, "({ sp_PolyArray *_t%d = ", t); emit_expr(c, recv, b);
    buf_printf(b, "; SP_GC_ROOT(_t%d); sp_int _t%d = ", t, tn2); emit_int_expr(c, argv[0], b);
    buf_printf(b, "; if (_t%d < 0) sp_raise_cls(\"ArgumentError\", \"negative array size\");", tn2);
    buf_printf(b, " if (_t%d > _t%d->len) _t%d = _t%d->len;", tn2, t, tn2, t);
    if (sp_streq(name, "pop"))
      buf_printf(b, " sp_PolyArray_slice_bang(_t%d, _t%d->len - _t%d, _t%d); })", t, t, tn2, tn2);
    else
      buf_printf(b, " sp_PolyArray_slice_bang(_t%d, 0, _t%d); })", t, tn2);
    return 1;
  }
  const char *k = array_kind(x->rt);
  int t = ++g_tmp, tn2 = ++g_tmp;
  /* rooted across the count, as the poly arm roots its receiver */
  buf_printf(b, "({ sp_%sArray *_t%d = ", k, t); emit_recv_rooted(c, recv, t, "SP_GC_ROOT", b);
  buf_printf(b, "sp_int _t%d = ", tn2); emit_int_expr(c, argv[0], b);
  buf_printf(b, "; if (_t%d < 0) sp_raise_cls(\"ArgumentError\", \"negative array size\");", tn2);
  buf_printf(b, " if (_t%d > _t%d->len) _t%d = _t%d->len;", tn2, t, tn2, t);
  if (sp_streq(name, "pop"))
    buf_printf(b, " sp_%sArray_slice_bang(_t%d, _t%d->len - _t%d, _t%d); })", k, t, t, tn2, tn2);
  else
    buf_printf(b, " sp_%sArray_slice_bang(_t%d, 0, _t%d); })", k, t, tn2);
  return 1;
}

/* blockless cycle(n): the receiver repeated n times, materialized. A poly
   one typed as an Enumerator is one (emit_array_call, before the lookup). */
int emit_op_array_cycle_n(Compiler *c, const BopCtx *x, Buf *b) {
  int recv = x->recv, argc;
  TyKind rt = x->rt;
  const int *argv = call_args(c->nt, x->id, &argc);
  if (rt == TY_POLY_ARRAY) {
    int t = ++g_tmp, tn2 = ++g_tmp, tr2 = ++g_tmp, tj = ++g_tmp, ti2 = ++g_tmp;
    buf_printf(b, "({ sp_PolyArray *_t%d = ", t); emit_expr(c, recv, b);
    buf_printf(b, "; SP_GC_ROOT(_t%d); sp_int _t%d = ", t, tn2); emit_int_expr(c, argv[0], b);
    buf_printf(b, "; sp_PolyArray *_t%d = sp_PolyArray_new(); SP_GC_ROOT(_t%d);", tr2, tr2);
    buf_printf(b, " for (sp_int _t%d = 0; _t%d < _t%d; _t%d++)", tj, tj, tn2, tj);
    buf_printf(b, " for (sp_int _t%d = 0; _t%d < _t%d->len; _t%d++)", ti2, ti2, t, ti2);
    buf_printf(b, " sp_PolyArray_push(_t%d, _t%d->data[_t%d]);", tr2, t, ti2);
    buf_printf(b, " _t%d; })", tr2);
    return 1;
  }
  const char *k = array_kind(rt);
  int t = ++g_tmp, tn2 = ++g_tmp, tr2 = ++g_tmp, tj = ++g_tmp, ti2 = ++g_tmp;
  buf_printf(b, "({ sp_%sArray *_t%d = ", k, t); emit_expr(c, recv, b);
  buf_printf(b, "; sp_int _t%d = ", tn2); emit_int_expr(c, argv[0], b);
  buf_printf(b, "; sp_%sArray *_t%d = sp_%sArray_new(); SP_GC_ROOT(_t%d);", k, tr2, k, tr2);
  buf_printf(b, " for (sp_int _t%d = 0; _t%d < _t%d; _t%d++)", tj, tj, tn2, tj);
  buf_printf(b, " for (sp_int _t%d = 0; _t%d < _t%d->len; _t%d++)", ti2, ti2, t, ti2);
  buf_printf(b, " sp_%sArray_push(_t%d, sp_%sArray_get(_t%d, _t%d));", k, tr2, k, t, ti2);
  if (rt == TY_INT_ARRAY || rt == TY_FLOAT_ARRAY)   /* the receiver's nils, repeated */
    buf_printf(b, " sp_%sArray_nil_from(_t%d, _t%d);", k, tr2, t);
  buf_printf(b, " _t%d; })", tr2);
  return 1;
}

/* last: a self-contained statement expression, the receiver bound to a
   temp (needed twice, for the length and the index) inside `({ ... })`
   rather than spilled to g_pre. A g_pre decl leaks into an expression
   context when `.last` is itself hoisted -- e.g. as the receiver of a
   following `.call` (`pipe.last.call(x)`), where it landed mid-`_t = ...`
   (#2942). */
int emit_op_array_last(Compiler *c, const BopCtx *x, Buf *b) {
  int t = ++g_tmp;
  Buf rb = expr_buf(c, x->recv);
  if (x->rt == TY_POLY_ARRAY)
    buf_printf(b, "({ sp_PolyArray *_t%d = %s; sp_PolyArray_get(_t%d, sp_PolyArray_length(_t%d) - 1); })",
               t, rb.p ? rb.p : "", t, t);
  else {
    const char *k = array_kind(x->rt);
    buf_printf(b, "({ %s _t%d = %s; sp_%sArray_get(_t%d, sp_%sArray_length(_t%d) - 1); })",
               c_type_name(x->rt), t, rb.p ? rb.p : "", k, t, k, t);
  }
  free(rb.p);
  return 1;
}

/* join / join(sep): with a separator the receiver is held across it, since
   it may allocate; without one nothing runs between the two */
int emit_op_array_join(Compiler *c, const BopCtx *x, Buf *b) {
  int recv = x->recv, argc;
  const int *argv = call_args(c->nt, x->id, &argc);
  const char *k = arr_kind(x->rt);
  Buf rjn; memset(&rjn, 0, sizeof rjn); char tyj[32];
  snprintf(tyj, sizeof tyj, "sp_%sArray *", k);
  int cjn = argc == 1 && hold_recv_open(c, recv, 0, tyj, "SP_GC_ROOT", b, &rjn);
  buf_printf(b, "sp_%sArray_join(", k);
  if (argc == 1) buf_puts(b, rjn.p); else emit_expr(c, recv, b);
  buf_puts(b, ", ");
  /* the separator must be a const char*; a poly separator (e.g. a reader
     whose ivar widened to poly) is converted with sp_poly_to_s */
  if (argc == 1 && comp_ntype(c, argv[0]) == TY_POLY) {
    buf_puts(b, "sp_poly_to_s("); emit_expr(c, argv[0], b); buf_puts(b, ")");
  }
  /* nil is a legal separator (it means ""); false is not. The raw
     emit_expr passed both straight into the const char* slot, and the
     join then read a NULL as a string -- a segfault for either. */
  else if (argc == 1) emit_str_expr_nilable(c, argv[0], b);
  else buf_puts(b, "sp_str_empty");
  buf_puts(b, ")");
  free(rjn.p);
  if (cjn) buf_puts(b, "; })");
  return 1;
}

/* sort!: in place, answering self; a typed receiver that may hold the nil
   sentinel checks it first, as the comparison would raise */
int emit_op_array_sort_bang(Compiler *c, const BopCtx *x, Buf *b) {
  int t = ++g_tmp;
  if (x->rt == TY_POLY_ARRAY) {
    buf_printf(b, "({ sp_PolyArray *_t%d = ", t); emit_expr(c, x->recv, b);
    buf_printf(b, "; sp_PolyArray_sort_bang(_t%d); _t%d; })", t, t);
    return 1;
  }
  const char *k = array_kind(x->rt);
  buf_printf(b, "({ sp_%sArray *_t%d = ", k, t);
  emit_nil_ck_recv(c, x->recv, x->rt, "cmp", 0, b);
  buf_printf(b, "; sp_%sArray_sort_bang(_t%d); _t%d; })", k, t, t);
  return 1;
}

/* slice!(range): normalize begin/length against the live length; the
   receiver is rooted across the range, whose bounds may allocate. A
   beginless bound starts at 0 and an endless one runs to the end, the same
   sentinels Array#[] resolves (#3835). */
int emit_op_array_slice_bang_range(Compiler *c, const BopCtx *x, Buf *b) {
  int recv = x->recv, argc;
  const int *argv = call_args(c->nt, x->id, &argc);
  int ta = ++g_tmp, tr = ++g_tmp, tf = ++g_tmp, tn = ++g_tmp;
  if (x->rt == TY_POLY_ARRAY) {
    buf_printf(b, "({ sp_PolyArray *_t%d = ", ta); emit_recv_rooted(c, recv, ta, "SP_GC_ROOT", b);
    buf_printf(b, "sp_Range _t%d = ", tr); emit_expr(c, argv[0], b);
    buf_printf(b, "; sp_int _t%d = _t%d.first == INTPTR_MIN ? 0"
                  " : (_t%d.first < 0 ? _t%d.first + (_t%d ? _t%d->len : 0) : _t%d.first);",
               tf, tr, tr, tr, ta, ta, tr);
    buf_printf(b, " sp_int _t%d = _t%d.last == INTPTR_MAX ? ((_t%d ? _t%d->len : 0) - _t%d)"
                  " : ((_t%d.last < 0 ? _t%d.last + (_t%d ? _t%d->len : 0) : _t%d.last) - _t%d + (_t%d.excl ? 0 : 1));",
               tn, tr, ta, ta, tf, tr, tr, ta, ta, tr, tf, tr);
    /* a start still negative lies before the first element: passed as
       given, the runtime answers nil for it (after its frozen check) */
    buf_printf(b, " sp_PolyArray_slice_bang(_t%d, _t%d < 0 ? _t%d - (_t%d ? _t%d->len : 0) : _t%d,"
                  " _t%d < 0 ? 0 : _t%d); })", ta, tf, tf, ta, ta, tf, tn, tn);
    return 1;
  }
  const char *k = array_kind(x->rt);
  buf_printf(b, "({ sp_%sArray *_t%d = ", k, ta); emit_recv_rooted(c, recv, ta, "SP_GC_ROOT", b);
  buf_printf(b, "sp_Range _t%d = ", tr); emit_expr(c, argv[0], b);
  buf_printf(b, "; sp_int _t%d = _t%d.first == INTPTR_MIN ? 0"
                " : (_t%d.first < 0 ? _t%d.first + (_t%d ? _t%d->len : 0) : _t%d.first);",
             tf, tr, tr, tr, ta, ta, tr);
  buf_printf(b, " sp_int _t%d = _t%d.last == INTPTR_MAX ? ((_t%d ? _t%d->len : 0) - _t%d)"
                " : ((_t%d.last < 0 ? _t%d.last + (_t%d ? _t%d->len : 0) : _t%d.last) - _t%d + (_t%d.excl ? 0 : 1));",
             tn, tr, ta, ta, tf, tr, tr, ta, ta, tr, tf, tr);
  buf_printf(b, " sp_%sArray_slice_bang(_t%d, _t%d, _t%d < 0 ? 0 : _t%d); })", k, ta, tf, tn, tn);
  return 1;
}
