/* codegen_call_hash.c -- the builtin-op emitters of the Hash receiver arms
   that are more than one C expression around the receiver and its
   operands: they branch on the receiver's variant or an operand's kind, or
   build a statement expression of their own. The rest are templates in
   builtin_ops.c. Each answers 1 when it emitted the call, 0 (having emitted
   nothing and taken no temp) to leave it to the arms after the lookup in
   emit_hash_call. */

#include "codegen_internal.h"
#include "builtin_ops.h"

/* any?(pattern) / none? / one? / count with one argument and no block:
   compare each [key, value] pair by == (sp_poly_eq covers array-vs-array
   value equality, which is what a pair pattern is) */
int emit_op_hash_pattern(Compiler *c, const BopCtx *x, Buf *b) {
  const char *name = x->name;
  int recv = x->recv;
  int argc;
  const int *argv = call_args(c->nt, x->id, &argc);
  int th = ++g_tmp, tv = ++g_tmp, tn = ++g_tmp, tc2 = ++g_tmp, ti = ++g_tmp, tp = ++g_tmp;
  buf_printf(b, "({ sp_RbVal _t%d = ", th);
  emit_boxed(c, recv, b);
  buf_printf(b, "; SP_GC_ROOT_RBVAL(_t%d); sp_RbVal _t%d = ", th, tv);
  emit_boxed(c, argv[0], b);
  buf_printf(b, "; SP_GC_ROOT_RBVAL(_t%d); sp_int _t%d = sp_poly_length(_t%d); sp_int _t%d = 0;",
             tv, tn, th, tc2);
  /* a CLASS pattern is a kind-of test, not equality: `h.any?(Array)`
     compared each pair to the class value and answered false (#3565).
     #count is the exception: it counts elements EQUAL to its argument
     (Enumerable#count uses ==, the predicates use ===), so a class
     argument counts the class itself, not its instances (#3817). */
  if (comp_ntype(c, argv[0]) == TY_CLASS && !sp_streq(name, "count"))
    buf_printf(b, " for (sp_int _t%d = 0; _t%d < _t%d; _t%d++) {"
                  " sp_RbVal _t%d = sp_poly_each_elem(_t%d, _t%d);"
                  " if (sp_poly_is_a(_t%d, (sp_Class){(sp_int)_t%d.v.i, NULL})) _t%d++; }",
               ti, ti, tn, ti, tp, th, ti, tp, tv, tc2);
  else
    buf_printf(b, " for (sp_int _t%d = 0; _t%d < _t%d; _t%d++) {"
                  " sp_RbVal _t%d = sp_poly_each_elem(_t%d, _t%d);"
                  " if (sp_poly_eq(_t%d, _t%d)) _t%d++; }",
               ti, ti, tn, ti, tp, th, ti, tp, tv, tc2);
  if (sp_streq(name, "any?"))       buf_printf(b, " _t%d > 0; })", tc2);
  else if (sp_streq(name, "none?")) buf_printf(b, " _t%d == 0; })", tc2);
  else if (sp_streq(name, "one?"))  buf_printf(b, " _t%d == 1; })", tc2);
  else                              buf_printf(b, " _t%d; })", tc2);
  return 1;
}

/* all?(pattern) with no block: test each [key, value] pair with
   `pattern === pair`. An Array pattern (the common destructured-pair form)
   compares by ==, served by sp_poly_eq; a CLASS pattern is a kind-of test,
   and comparing the pair to the class value by equality answered false for
   every pair (#3565). any?/none?/one? with a pattern take
   emit_op_hash_pattern. */
int emit_op_hash_pattern_all(Compiler *c, const BopCtx *x, Buf *b) {
  int recv = x->recv;
  TyKind rt = x->rt;
  const char *hn = ty_hash_cname(rt);
  int argc;
  const int *argv = call_args(c->nt, x->id, &argc);
  int tp = ++g_tmp, tpat = ++g_tmp, tc = ++g_tmp, ti = ++g_tmp;
  buf_printf(b, "({ sp_PolyArray *_t%d = ", tp);
  emit_hash_pairs_expr(c, recv, rt, hn, b);
  buf_printf(b, "; sp_RbVal _t%d = ", tpat); emit_boxed(c, argv[0], b);
  buf_printf(b, "; sp_int _t%d = 0;", tc);
  buf_printf(b, " for (sp_int _t%d = 0; _t%d < _t%d->len; _t%d++)", ti, ti, tp, ti);
  if (comp_ntype(c, argv[0]) == TY_CLASS)
    buf_printf(b, " if (sp_poly_is_a(_t%d->data[_t%d], (sp_Class){(sp_int)_t%d.v.i, NULL})) _t%d++;", tp, ti, tpat, tc);
  else
    buf_printf(b, " if (sp_poly_eq(_t%d->data[_t%d], _t%d)) _t%d++;", tp, ti, tpat, tc);
  buf_printf(b, " _t%d == _t%d->len; })", tc, tp);
  return 1;
}
