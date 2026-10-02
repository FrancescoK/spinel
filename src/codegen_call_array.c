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

/* Array#+: the same kind concatenates; another kind boxes both sides into a poly array */
int emit_op_array_plus(Compiler *c, const BopCtx *x, Buf *b) {
  const NodeTable *nt = c->nt;
  const char *name = x->name;
  int id = x->id, recv = x->recv, argc;
  const int *argv = call_args(nt, id, &argc);
  TyKind rt = x->rt;
  TyKind a0 = argc >= 1 ? comp_ntype(c, argv[0]) : TY_UNKNOWN;
  const char *k = array_kind(rt);
  int block = nt_ref(nt, id, "block");
  (void)name; (void)a0; (void)k; (void)block; (void)argv;
  if (rt == TY_POLY_ARRAY) {
    if (sp_streq(name, "+") && argc == 1 && a0 == TY_POLY_ARRAY) {
      /* Spill the receiver: evaluating the operand can allocate, and until
         the concat runs the receiver is in nothing but this temp. */
      int t = ++g_tmp;
      buf_printf(b, "({ sp_PolyArray *_t%d = ", t); emit_expr(c, recv, b);
      buf_printf(b, "; SP_GC_ROOT(_t%d); sp_PolyArray_concat(_t%d, ", t, t);
      emit_expr(c, argv[0], b); buf_puts(b, "); })");
      return 1;
    }
    /* poly_array + typed array: box the typed operand to poly, then concat. */
    if (sp_streq(name, "+") && argc == 1 && ty_is_array(a0) && a0 != TY_POLY_ARRAY) {
      const char *conv = a0 == TY_INT_ARRAY ? "sp_IntArray_to_poly" :
                         a0 == TY_FLOAT_ARRAY ? "sp_FloatArray_to_poly" :
                         a0 == TY_STR_ARRAY ? "sp_StrArray_to_poly_fmt" : NULL;
      if (conv) {
        int t = ++g_tmp;
        buf_printf(b, "({ sp_PolyArray *_t%d = ", t); emit_expr(c, recv, b);
        buf_printf(b, "; SP_GC_ROOT(_t%d); sp_PolyArray_concat(_t%d, %s(", t, t, conv);
        emit_expr(c, argv[0], b); buf_puts(b, ")); })");
        return 1;
      }
    }
    return 0;
  }
  if (sp_streq(name, "+") && argc == 1 && a0 == rt) {
    /* array + array of the same kind -> a fresh concatenation */
    buf_printf(b, "sp_%sArray_concat(", k);
    emit_expr(c, recv, b); buf_puts(b, ", ");
    emit_expr(c, argv[0], b);
    buf_puts(b, ")");
    return 1;
  }
  if (sp_streq(name, "+") && argc == 1 && ty_is_array(a0) && a0 != rt) {
    /* array + different-kind array -> poly_array */
    const char *k2 = (a0 == TY_POLY_ARRAY) ? "Poly" : array_kind(a0);
    if (k2) {
      int tL = ++g_tmp, tR = ++g_tmp, tO = ++g_tmp, ti = ++g_tmp;
      Buf lbuf = expr_buf(c, recv);
      Buf rbuf = expr_buf(c, argv[0]);
      const char *box_l = (rt == TY_INT_ARRAY || rt == TY_FLOAT_ARRAY) ? typed_elem_box_fn(rt) :
                          (rt == TY_STR_ARRAY) ? "sp_box_str" : NULL;
      const char *box_r = (a0 == TY_INT_ARRAY || a0 == TY_FLOAT_ARRAY) ? typed_elem_box_fn(a0) :
                          (a0 == TY_STR_ARRAY) ? "sp_box_str" : NULL;
      /* an Integer or Float side's box takes its may_nil, read once */
      char nf_l[24] = "", nf_r[24] = "";
      const char *get_l = (rt == TY_POLY_ARRAY) ? "sp_PolyArray_get" :
                          NULL;
      const char *get_r = (a0 == TY_POLY_ARRAY) ? "sp_PolyArray_get" :
                          NULL;
      emit_indent(g_pre, g_indent);
      buf_printf(g_pre, "sp_%sArray *_t%d = %s; SP_GC_ROOT(_t%d);\n", k, tL, lbuf.p ? lbuf.p : "", tL); free(lbuf.p);
      emit_indent(g_pre, g_indent);
      buf_printf(g_pre, "sp_%sArray *_t%d = %s; SP_GC_ROOT(_t%d);\n", k2, tR, rbuf.p ? rbuf.p : "", tR); free(rbuf.p);
      if (rt == TY_INT_ARRAY || rt == TY_FLOAT_ARRAY) {
        int tn = ++g_tmp; snprintf(nf_l, sizeof nf_l, "_t%d, ", tn);
        char an[24]; snprintf(an, sizeof an, "_t%d", tL);
        emit_indent(g_pre, g_indent); buf_printf(g_pre, "int _t%d = ", tn); emit_may_nil_text(c, recv, rt, an, g_pre); buf_puts(g_pre, ";\n");
      }
      if (a0 == TY_INT_ARRAY || a0 == TY_FLOAT_ARRAY) {
        int tn = ++g_tmp; snprintf(nf_r, sizeof nf_r, "_t%d, ", tn);
        char an[24]; snprintf(an, sizeof an, "_t%d", tR);
        emit_indent(g_pre, g_indent); buf_printf(g_pre, "int _t%d = ", tn); emit_may_nil_text(c, argv[0], a0, an, g_pre); buf_puts(g_pre, ";\n");
      }
      emit_indent(g_pre, g_indent);
      buf_printf(g_pre, "sp_PolyArray *_t%d = sp_PolyArray_new(); SP_GC_ROOT(_t%d);\n", tO, tO);
      emit_indent(g_pre, g_indent);
      buf_printf(g_pre, "for (sp_int _t%d = 0; _t%d < sp_%sArray_length(_t%d); _t%d++)\n", ti, ti, k, tL, ti);
      emit_indent(g_pre, g_indent + 1);
      if (rt == TY_POLY_ARRAY)
        buf_printf(g_pre, "sp_PolyArray_push(_t%d, sp_PolyArray_get(_t%d, _t%d));\n", tO, tL, ti);
      else if (box_l)
        buf_printf(g_pre, "sp_PolyArray_push(_t%d, %s(%ssp_%sArray_get(_t%d, _t%d)));\n", tO, box_l, nf_l, k, tL, ti);
      emit_indent(g_pre, g_indent);
      buf_printf(g_pre, "for (sp_int _t%d = 0; _t%d < sp_%sArray_length(_t%d); _t%d++)\n", ti, ti, k2, tR, ti);
      emit_indent(g_pre, g_indent + 1);
      if (a0 == TY_POLY_ARRAY)
        buf_printf(g_pre, "sp_PolyArray_push(_t%d, sp_PolyArray_get(_t%d, _t%d));\n", tO, tR, ti);
      else if (box_r)
        buf_printf(g_pre, "sp_PolyArray_push(_t%d, %s(%ssp_%sArray_get(_t%d, _t%d)));\n", tO, box_r, nf_r, k2, tR, ti);
      buf_printf(b, "_t%d", tO);
      (void)get_l; (void)get_r;
      return 1;
    }
  }
  return 0;
}

/* Array#& / #| / #- and intersection / union / difference with operands: the
   same kind runs the typed set op; another kind, or a boxed operand, the poly one */
int emit_op_array_setop(Compiler *c, const BopCtx *x, Buf *b) {
  const NodeTable *nt = c->nt;
  const char *name = x->name;
  int id = x->id, recv = x->recv, argc;
  const int *argv = call_args(nt, id, &argc);
  TyKind rt = x->rt;
  TyKind a0 = argc >= 1 ? comp_ntype(c, argv[0]) : TY_UNKNOWN;
  const char *k = array_kind(rt);
  int block = nt_ref(nt, id, "block");
  (void)name; (void)a0; (void)k; (void)block; (void)argv;
  if (rt == TY_POLY_ARRAY) {
    if ((sp_streq(name, "&") || sp_streq(name, "intersection") ||
         sp_streq(name, "|") || sp_streq(name, "union") ||
         sp_streq(name, "-") || sp_streq(name, "difference")) && argc == 1 && (a0 == TY_POLY_ARRAY || a0 == TY_UNKNOWN)) {
      const char *fn = (sp_streq(name, "&") || sp_streq(name, "intersection")) ? "intersect" : (sp_streq(name, "|") || sp_streq(name, "union") ? "union" : "difference");
      buf_printf(b, "sp_PolyArray_%s(", fn);
      emit_expr(c, recv, b); buf_puts(b, ", ");
      if (a0 == TY_UNKNOWN) buf_puts(b, "NULL"); else emit_expr(c, argv[0], b);
      buf_puts(b, ")"); return 1;
    }
    /* poly-array set-op with a typed-array argument (different element type):
       box the argument to a poly array, then run the poly op. */
    if ((sp_streq(name, "&") || sp_streq(name, "intersection") ||
         sp_streq(name, "|") || sp_streq(name, "union") ||
         sp_streq(name, "-") || sp_streq(name, "difference")) && argc == 1 &&
        (a0 == TY_INT_ARRAY || a0 == TY_STR_ARRAY || a0 == TY_FLOAT_ARRAY)) {
      const char *fn = (sp_streq(name, "&") || sp_streq(name, "intersection")) ? "intersect" : (sp_streq(name, "|") || sp_streq(name, "union") ? "union" : "difference");
      const char *conv = a0 == TY_INT_ARRAY ? "sp_IntArray_to_poly" :
                         a0 == TY_STR_ARRAY ? "sp_StrArray_to_poly_fmt" : "sp_FloatArray_to_poly";
      buf_printf(b, "sp_PolyArray_%s(", fn);
      emit_expr(c, recv, b); buf_printf(b, ", %s(", conv); emit_expr(c, argv[0], b);
      buf_puts(b, "))"); return 1;
    }
    /* poly-array receiver, POLY argument: same run-time coercion (#3475) */
    if ((sp_streq(name, "&") || sp_streq(name, "intersection") ||
         sp_streq(name, "|") || sp_streq(name, "union") ||
         sp_streq(name, "-") || sp_streq(name, "difference")) && argc == 1 &&
        a0 == TY_POLY) {
      const char *fn = (sp_streq(name, "&") || sp_streq(name, "intersection")) ? "intersect" : (sp_streq(name, "|") || sp_streq(name, "union") ? "union" : "difference");
      buf_printf(b, "sp_PolyArray_%s(", fn);
      emit_expr(c, recv, b); buf_puts(b, ", sp_poly_set_operand(");
      emit_expr(c, argv[0], b); buf_puts(b, "))"); return 1;
    }
    /* variadic named set ops on a poly array: fold over each argument */
    if ((sp_streq(name, "intersection") || sp_streq(name, "union") ||
         sp_streq(name, "difference")) && argc >= 2) {
      int ok = 1;
      for (int j = 0; j < argc; j++) {
        TyKind atj = comp_ntype(c, argv[j]);
        if (atj != TY_POLY_ARRAY && atj != TY_UNKNOWN) { ok = 0; break; }
      }
      if (ok) {
        const char *fn = sp_streq(name, "intersection") ? "intersect" :
                         sp_streq(name, "union") ? "union" : "difference";
        int t = ++g_tmp;
        buf_printf(b, "({ sp_PolyArray *_t%d = ", t); emit_expr(c, recv, b);
        buf_printf(b, "; SP_GC_ROOT(_t%d);", t);
        for (int j = 0; j < argc; j++) {
          buf_printf(b, " _t%d = sp_PolyArray_%s(_t%d, ", t, fn, t);
          if (comp_ntype(c, argv[j]) == TY_UNKNOWN) buf_puts(b, "NULL");
          else emit_expr(c, argv[j], b);
          buf_puts(b, ");");
        }
        buf_printf(b, " _t%d; })", t);
        return 1;
      }
    }
    return 0;
  }
  if ((sp_streq(name, "&") || sp_streq(name, "intersection") ||
       sp_streq(name, "|") || sp_streq(name, "union") ||
       sp_streq(name, "-") || sp_streq(name, "difference")) && argc == 1 && (a0 == rt || a0 == TY_UNKNOWN)) {
    const char *fn = (sp_streq(name, "&") || sp_streq(name, "intersection")) ? "intersect" : ((sp_streq(name, "|") || sp_streq(name, "union")) ? "union" : "difference");
    /* empty literal [] arg: use a null pointer (safe for all sp_*Array_* set ops) */
    if (a0 == TY_UNKNOWN) { buf_printf(b, "sp_%sArray_%s(", k, fn); emit_expr(c, recv, b); buf_puts(b, ", NULL)"); }
    else { buf_printf(b, "sp_%sArray_%s(", k, fn); emit_expr(c, recv, b); buf_puts(b, ", "); emit_expr(c, argv[0], b); buf_puts(b, ")"); }
    return 1;
  }
  /* typed-array receiver, different-kind typed-array or poly-array argument:
     box both operands to poly and run the poly set op (result poly). */
  if ((sp_streq(name, "&") || sp_streq(name, "intersection") ||
       sp_streq(name, "|") || sp_streq(name, "union") ||
       sp_streq(name, "-") || sp_streq(name, "difference")) && argc == 1 &&
      (a0 == TY_INT_ARRAY || a0 == TY_STR_ARRAY || a0 == TY_FLOAT_ARRAY || a0 == TY_POLY_ARRAY) && a0 != rt) {
    const char *fn = (sp_streq(name, "&") || sp_streq(name, "intersection")) ? "intersect" : (sp_streq(name, "|") || sp_streq(name, "union") ? "union" : "difference");
    const char *conv_l = rt == TY_INT_ARRAY ? "sp_IntArray_to_poly" :
                         rt == TY_STR_ARRAY ? "sp_StrArray_to_poly_fmt" : "sp_FloatArray_to_poly";
    const char *conv_r = a0 == TY_INT_ARRAY ? "sp_IntArray_to_poly" :
                         a0 == TY_STR_ARRAY ? "sp_StrArray_to_poly_fmt" :
                         a0 == TY_FLOAT_ARRAY ? "sp_FloatArray_to_poly" : NULL;
    /* the boxed receiver is rooted while the argument is boxed: the two
       conversions allocate, and a nested-call operand is nobody's root
       between its evaluation and the call */
    int tl = ++g_tmp;
    buf_printf(b, "({ sp_PolyArray *_t%d = %s(", tl, conv_l); emit_expr(c, recv, b); buf_printf(b, "); SP_GC_ROOT(_t%d); sp_PolyArray_%s(_t%d, ", tl, fn, tl);
    if (conv_r) { buf_printf(b, "%s(", conv_r); emit_expr(c, argv[0], b); buf_puts(b, ")"); }
    else emit_expr(c, argv[0], b);  /* already poly */
    buf_puts(b, "); })"); return 1;
  }
  /* typed-array receiver, POLY argument (a value whose static type widened,
     not a poly array): coerce it at run time -- an Array becomes the poly
     array the set-op primitives take, anything else raises the TypeError
     CRuby raises. Without this arm the call had nowhere to go and `&`/`|`
     failed to compile (#3475). */
  if ((sp_streq(name, "&") || sp_streq(name, "intersection") ||
       sp_streq(name, "|") || sp_streq(name, "union") ||
       sp_streq(name, "-") || sp_streq(name, "difference")) && argc == 1 &&
      a0 == TY_POLY) {
    const char *fn = (sp_streq(name, "&") || sp_streq(name, "intersection")) ? "intersect" : (sp_streq(name, "|") || sp_streq(name, "union") ? "union" : "difference");
    const char *conv_l = rt == TY_INT_ARRAY ? "sp_IntArray_to_poly" :
                         rt == TY_STR_ARRAY ? "sp_StrArray_to_poly_fmt" : "sp_FloatArray_to_poly";
    int tl = ++g_tmp;
    buf_printf(b, "({ sp_PolyArray *_t%d = %s(", tl, conv_l); emit_expr(c, recv, b);
    buf_printf(b, "); SP_GC_ROOT(_t%d); sp_PolyArray_%s(_t%d, sp_poly_set_operand(", tl, fn, tl); emit_expr(c, argv[0], b);
    buf_puts(b, ")); })"); return 1;
  }
  /* variadic named set ops: union/intersection/difference(*others) fold the
     binary operator over each argument, accumulating in a rooted temp. */
  if ((sp_streq(name, "intersection") || sp_streq(name, "union") ||
       sp_streq(name, "difference")) && argc >= 2) {
    int ok = 1;
    for (int j = 0; j < argc; j++) {
      TyKind atj = comp_ntype(c, argv[j]);
      if (atj != rt && atj != TY_UNKNOWN) { ok = 0; break; }
    }
    if (ok) {
      const char *fn = sp_streq(name, "intersection") ? "intersect" :
                       sp_streq(name, "union") ? "union" : "difference";
      int t = ++g_tmp;
      buf_printf(b, "({ sp_%sArray *_t%d = ", k, t); emit_expr(c, recv, b);
      buf_printf(b, "; SP_GC_ROOT(_t%d);", t);
      for (int j = 0; j < argc; j++) {
        buf_printf(b, " _t%d = sp_%sArray_%s(_t%d, ", t, k, fn, t);
        if (comp_ntype(c, argv[j]) == TY_UNKNOWN) buf_puts(b, "NULL");
        else emit_expr(c, argv[j], b);
        buf_puts(b, ");");
      }
      buf_printf(b, " _t%d; })", t);
      return 1;
    }
  }
  return 0;
}

/* Array#intersect? */
int emit_op_array_intersect_p(Compiler *c, const BopCtx *x, Buf *b) {
  const NodeTable *nt = c->nt;
  const char *name = x->name;
  int id = x->id, recv = x->recv, argc;
  const int *argv = call_args(nt, id, &argc);
  TyKind rt = x->rt;
  TyKind a0 = argc >= 1 ? comp_ntype(c, argv[0]) : TY_UNKNOWN;
  const char *k = array_kind(rt);
  int block = nt_ref(nt, id, "block");
  (void)name; (void)a0; (void)k; (void)block; (void)argv;
  if (rt == TY_POLY_ARRAY) {
    if (sp_streq(name, "intersect?") && argc == 1 &&
        (a0 == TY_POLY_ARRAY || a0 == TY_UNKNOWN || ty_is_array(a0) || a0 == TY_POLY)) {
      buf_puts(b, "sp_PolyArray_intersect_p("); emit_expr(c, recv, b); buf_puts(b, ", ");
      if (a0 == TY_UNKNOWN) buf_puts(b, "NULL");
      else if (a0 == TY_POLY_ARRAY) emit_expr(c, argv[0], b);
      else {
        /* a differently-stored Array argument coerces; Ruby has one Array */
        buf_puts(b, "sp_poly_to_poly_array(");
        Buf ab3; memset(&ab3, 0, sizeof ab3); emit_expr(c, argv[0], &ab3);
        if (a0 == TY_POLY) buf_puts(b, ab3.p ? ab3.p : "sp_box_nil()");
        else emit_boxed_text(c, a0, ab3.p ? ab3.p : "NULL", b);
        free(ab3.p);
        buf_puts(b, ")");
      }
      buf_puts(b, ")");
      return 1;
    }
    return 0;
  }
  if (sp_streq(name, "intersect?") && argc == 1 &&
      (a0 == rt || a0 == TY_UNKNOWN || ty_is_array(a0) || a0 == TY_POLY)) {
    /* Ruby has one Array; the storage kinds are ours. A receiver and an
       argument of different kinds -- a mapped String array against a
       poly-array constant, the shape this turned up in -- go through the
       generic comparison rather than declining to a NoMethodError. */
    if (a0 == rt) {
      buf_printf(b, "sp_%sArray_intersect_p(", k); emit_expr(c, recv, b); buf_puts(b, ", ");
      emit_expr(c, argv[0], b);
      buf_puts(b, ")");
      return 1;
    }
    if (a0 == TY_UNKNOWN) {
      buf_printf(b, "sp_%sArray_intersect_p(", k); emit_expr(c, recv, b); buf_puts(b, ", NULL)");
      return 1;
    }
    buf_puts(b, "sp_PolyArray_intersect_p(sp_poly_to_poly_array(");
    { Buf rb2; memset(&rb2, 0, sizeof rb2); emit_expr(c, recv, &rb2);
      emit_boxed_text(c, rt, rb2.p ? rb2.p : "NULL", b); free(rb2.p); }
    buf_puts(b, "), sp_poly_to_poly_array(");
    { Buf ab2; memset(&ab2, 0, sizeof ab2); emit_expr(c, argv[0], &ab2);
      if (a0 == TY_POLY) buf_puts(b, ab2.p ? ab2.p : "sp_box_nil()");
      else emit_boxed_text(c, a0, ab2.p ? ab2.p : "NULL", b);
      free(ab2.p); }
    buf_puts(b, "))");
    return 1;
  }
  return 0;
}

/* Array#replace(other): in place, answering self */
int emit_op_array_replace(Compiler *c, const BopCtx *x, Buf *b) {
  const NodeTable *nt = c->nt;
  const char *name = x->name;
  int id = x->id, recv = x->recv, argc;
  const int *argv = call_args(nt, id, &argc);
  TyKind rt = x->rt;
  TyKind a0 = argc >= 1 ? comp_ntype(c, argv[0]) : TY_UNKNOWN;
  const char *k = array_kind(rt);
  int block = nt_ref(nt, id, "block");
  (void)name; (void)a0; (void)k; (void)block; (void)argv;
  if (rt == TY_POLY_ARRAY) {
    if (sp_streq(name, "replace") && argc == 1 && a0 == TY_POLY_ARRAY) {
      buf_puts(b, "sp_PolyArray_replace("); emit_expr(c, recv, b); buf_puts(b, ", "); emit_expr(c, argv[0], b); buf_puts(b, ")");
      return 1;
    }
    /* ...and a source of ANOTHER kind, which `[1, 2].replace(["x"])` is:
       the widening makes the receiver poly, and the source is read through
       the boxed accessors rather than needing an arm of its own (#4339). */
    if (sp_streq(name, "replace") && argc == 1 && ty_is_array(rt) &&
        (ty_is_array(a0) || a0 == TY_POLY)) {
      buf_puts(b, "sp_PolyArray_replace_from("); emit_expr(c, recv, b);
      buf_puts(b, ", "); emit_boxed(c, argv[0], b); buf_puts(b, ")");
      return 1;
    }
    return 0;
  }
  if (sp_streq(name, "replace") && argc == 1 && a0 == rt) {
    int t = ++g_tmp;
    buf_printf(b, "({ sp_%sArray *_t%d = ", k, t); emit_expr(c, recv, b);
    buf_printf(b, "; sp_%sArray_replace(_t%d, ", k, t); emit_expr(c, argv[0], b);
    buf_printf(b, "); _t%d; })", t);
    return 1;
  }
  /* A source of another kind into a receiver that kept its own: only a
     true --rbs seed (`@storage: Array[Integer]`) pins it, since the
     mutation otherwise widens the receiver. The source converts to the
     receiver's kind, the way a seeded store converts it; with no arm the
     call fell to NoMethodError. nil or a non-Array is Ruby's TypeError. */
  if (sp_streq(name, "replace") && argc == 1 &&
      (rt == TY_INT_ARRAY || rt == TY_FLOAT_ARRAY || rt == TY_STR_ARRAY) &&
      (a0 == TY_POLY || a0 == TY_POLY_ARRAY || (ty_is_array(a0) && a0 != rt))) {
    int t = ++g_tmp, ts = ++g_tmp, tc = ++g_tmp;
    buf_printf(b, "({ sp_%sArray *_t%d = ", k, t); emit_recv_rooted(c, recv, t, "SP_GC_ROOT", b);
    buf_printf(b, "sp_RbVal _t%d = ", ts); emit_boxed(c, argv[0], b);
    buf_printf(b, "; SP_GC_ROOT_RBVAL(_t%d); ", ts);
    buf_printf(b, "if (_t%d.tag != SP_TAG_OBJ || !sp_poly_is_array_kind(_t%d.cls_id))"
                  " sp_raise_cls(\"TypeError\", sp_sprintf(\"no implicit conversion of %%s into Array\","
                  " sp_poly_class_name(_t%d))); ", ts, ts, ts);
    char src[32]; snprintf(src, sizeof src, "_t%d", ts);
    emit_ctype(c, rt, b); buf_printf(b, " _t%d = ", tc); emit_unbox_text(c, rt, src, b);
    buf_printf(b, "; sp_%sArray_replace(_t%d, _t%d); _t%d; })", k, t, tc, t);
    return 1;
  }
  return 0;
}

/* Array#minmax without a block */
int emit_op_array_minmax(Compiler *c, const BopCtx *x, Buf *b) {
  const NodeTable *nt = c->nt;
  const char *name = x->name;
  int id = x->id, recv = x->recv, argc;
  const int *argv = call_args(nt, id, &argc);
  TyKind rt = x->rt;
  TyKind a0 = argc >= 1 ? comp_ntype(c, argv[0]) : TY_UNKNOWN;
  const char *k = array_kind(rt);
  int block = nt_ref(nt, id, "block");
  (void)name; (void)a0; (void)k; (void)block; (void)argv;
  if (rt == TY_POLY_ARRAY) {
    /* minmax (no block): [min, max] via the poly comparator (user `<=>`
       through the cmp hook); incomparable raises the Comparable
       ArgumentError; empty -> [nil, nil]. Both temps rooted: min/max can
       allocate inside sp_poly_cmp (bigint temps) and push reallocs. */
    if (sp_streq(name, "minmax") && argc == 0 && nt_ref(nt, id, "block") < 0) {
      int t = ++g_tmp, o = ++g_tmp;
      buf_printf(b, "({ sp_PolyArray *_t%d = ", t); emit_expr(c, recv, b);
      buf_printf(b, "; SP_GC_ROOT(_t%d); sp_PolyArray *_t%d = sp_PolyArray_new(); SP_GC_ROOT(_t%d);"
                    " sp_PolyArray_push(_t%d, sp_PolyArray_min(_t%d));"
                    " sp_PolyArray_push(_t%d, sp_PolyArray_max(_t%d)); _t%d; })",
                 t, o, o, o, t, o, t, o);
      return 1;
    }
    return 0;
  }
  /* The extremes are read before the result is allocated: a fresh
     receiver (a Range's to_a) is held by nothing, and the allocation
     collected it before min/max read it. A number needs nothing held
     after that; a String extreme is one of the receiver's elements, so
     the receiver stays rooted across the allocation. Two pushes never
     grow a fresh array, so the result needs no root. */
  if (sp_streq(name, "minmax") && argc == 0 && block < 0) {
    int t = ++g_tmp, o = ++g_tmp;
    int is_str = rt == TY_STR_ARRAY;
    const char *et = is_str ? "const char *" : rt == TY_FLOAT_ARRAY ? "sp_float " : "sp_int ";
    buf_printf(b, "({ sp_%sArray *_t%d = ", k, t); emit_nil_ck_recv(c, recv, rt, "cmp", 0, b);
    buf_puts(b, ";");
    if (is_str) buf_printf(b, " SP_GC_ROOT(_t%d);", t);
    /* an empty receiver answers [nil, nil]: an Integer or Float pair
       notes those nils in may_nil */
    const char *ms = is_str ? "" : "_nilable";
    buf_printf(b, " %s_mn%d = sp_%sArray_min(_t%d); %s_mx%d = sp_%sArray_max(_t%d);"
                  " sp_%sArray *_t%d = sp_%sArray_new(); sp_%sArray_push%s(_t%d, _mn%d);"
                  " sp_%sArray_push%s(_t%d, _mx%d); _t%d; })",
               et, t, k, t, et, t, k, t, k, o, k, k, ms, o, t, k, ms, o, t, o);
    return 1;
  }
  return 0;
}

/* Array#sort: a typed receiver checks for its nil sentinel first; the
   poly form is the blockless one */
int emit_op_array_sort(Compiler *c, const BopCtx *x, Buf *b) {
  const NodeTable *nt = c->nt;
  const char *name = x->name;
  int id = x->id, recv = x->recv, argc;
  const int *argv = call_args(nt, id, &argc);
  TyKind rt = x->rt;
  TyKind a0 = argc >= 1 ? comp_ntype(c, argv[0]) : TY_UNKNOWN;
  const char *k = array_kind(rt);
  int block = nt_ref(nt, id, "block");
  (void)name; (void)a0; (void)k; (void)block; (void)argv;
  if (rt == TY_POLY_ARRAY) {
    if (sp_streq(name, "sort") && argc == 0 && nt_ref(nt, id, "block") < 0) {
      buf_puts(b, "sp_PolyArray_sort("); emit_expr(c, recv, b); buf_puts(b, ")");
      return 1;
    }
    return 0;
  }
  if (sp_streq(name, "sort") && argc == 0 &&
      (rt == TY_INT_ARRAY || rt == TY_FLOAT_ARRAY || rt == TY_STR_ARRAY)) {
    buf_printf(b, "sp_%sArray_sort(", k); emit_nil_ck_recv(c, recv, rt, "cmp", 0, b); buf_puts(b, ")");
    return 1;
  }
  return 0;
}

/* Array#uniq: the typed runtime call; a poly copy deduplicated in place */
int emit_op_array_uniq(Compiler *c, const BopCtx *x, Buf *b) {
  const NodeTable *nt = c->nt;
  const char *name = x->name;
  int id = x->id, recv = x->recv, argc;
  const int *argv = call_args(nt, id, &argc);
  TyKind rt = x->rt;
  TyKind a0 = argc >= 1 ? comp_ntype(c, argv[0]) : TY_UNKNOWN;
  const char *k = array_kind(rt);
  int block = nt_ref(nt, id, "block");
  (void)name; (void)a0; (void)k; (void)block; (void)argv;
  if (rt == TY_POLY_ARRAY) {
    if (rt == TY_POLY_ARRAY && sp_streq(name, "uniq") && argc == 0 &&
        nt_ref(nt, id, "block") < 0) {
      int t = ++g_tmp;
      buf_printf(b, "({ sp_PolyArray *_t%d = sp_PolyArray_dup(", t); emit_expr(c, recv, b);
      buf_printf(b, "); sp_PolyArray_uniq_bang(_t%d); _t%d; })", t, t);
      return 1;
    }
    return 0;
  }
  if (sp_streq(name, "uniq") && argc == 0 && (rt == TY_INT_ARRAY || rt == TY_STR_ARRAY || rt == TY_FLOAT_ARRAY)) {
    buf_printf(b, "sp_%sArray_uniq(", k); emit_expr(c, recv, b); buf_puts(b, ")");
    return 1;
  }
  return 0;
}

/* Array#min(n) / #max(n) without a block */
int emit_op_array_nmin(Compiler *c, const BopCtx *x, Buf *b) {
  const NodeTable *nt = c->nt;
  const char *name = x->name;
  int id = x->id, recv = x->recv, argc;
  const int *argv = call_args(nt, id, &argc);
  TyKind rt = x->rt;
  TyKind a0 = argc >= 1 ? comp_ntype(c, argv[0]) : TY_UNKNOWN;
  const char *k = array_kind(rt);
  int block = nt_ref(nt, id, "block");
  (void)name; (void)a0; (void)k; (void)block; (void)argv;
  if (rt == TY_POLY_ARRAY) {
    if ((sp_streq(name, "min") || sp_streq(name, "max")) && argc == 1 && nt_ref(nt, id, "block") < 0) {
      /* as CRuby's nmin_run computes it (sp_PolyArray_nmin), which checks
         the size first */
      int t = ++g_tmp;
      buf_printf(b, "({ sp_PolyArray *_t%d = ", t); emit_expr(c, recv, b);
      buf_printf(b, "; SP_GC_ROOT(_t%d); sp_PolyArray_nmin(_t%d, ", t, t); emit_int_expr(c, argv[0], b);
      buf_printf(b, ", %d); })", sp_streq(name, "max"));
      return 1;
    }
    return 0;
  }
  /* min(n) / max(n) as CRuby's nmin_run computes them
     (sp_PolyArray_nmin): the size is checked first, and a boxed array
     is cut and sorted by its comparisons. A typed one of plain numbers
     cannot tell the two orders apart and keeps its sort; one that can
     hold nil runs the boxed cut first, which raises where CRuby does
     (an unmarked one only when its may_nil flag says so). */
  if ((sp_streq(name, "min") || sp_streq(name, "max")) && argc == 1 && block < 0) {
    int want_max = sp_streq(name, "max");
    int t = ++g_tmp, tn = ++g_tmp;
    buf_printf(b, "({ sp_%sArray *_t%d = ", k, t); emit_expr(c, recv, b);
    buf_printf(b, "; SP_GC_ROOT(_t%d); sp_int _t%d = ", t, tn); emit_int_expr(c, argv[0], b);
    buf_printf(b, "; if (_t%d < 0) sp_raise_cls(\"ArgumentError\", sp_sprintf(\"negative size (%%lld)\", (long long)_t%d));",
               tn, tn);
    if (rt == TY_POLY_ARRAY) {
      buf_printf(b, " sp_PolyArray_nmin(_t%d, _t%d, %d); })", t, tn, want_max);
      return 1;
    }
    if ((rt == TY_INT_ARRAY || rt == TY_FLOAT_ARRAY) && elem_nil_sentinel(c, recv, rt)) {
      if (!elem_nil_marked(c, recv, rt)) buf_printf(b, " if (_t%d && SP_MAY_NIL(_t%d))", t, t);
      buf_printf(b, " (void)sp_PolyArray_nmin(%s(_t%d), _t%d, %d);",
                 rt == TY_INT_ARRAY ? "sp_IntArray_to_poly" : "sp_FloatArray_to_poly", t, tn, want_max);
    }
    buf_printf(b, " _t%d = sp_%sArray_sort(_t%d); SP_GC_ROOT(_t%d);", t, k, t, t);
    if (want_max) buf_printf(b, " sp_%sArray_reverse_bang(_t%d);", k, t);
    buf_printf(b, " sp_%sArray_slice(_t%d, 0, _t%d); })", k, t, tn);
    return 1;
  }
  return 0;
}
