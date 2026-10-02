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

/* Hash#default_proc: wrap the stored Hash.new{} dproc (a raw C fn +
   captures pointer) in a first-class Proc via a per-variant trampoline
   that adapts the sp_proc_call ABI (boxed side-channel args) back to the
   dproc signature. A hash without a dproc -- or a variant that cannot
   carry one -- yields NULL (nil). */
int emit_op_hash_default_proc(Compiler *c, const BopCtx *x, Buf *b) {
  int recv = x->recv;
  TyKind rt = x->rt;
  const char *hnn = ty_hash_cname(rt);
  int hdp_v = !hnn ? -1
            : sp_streq(hnn, "SymPoly") ? 0
            : sp_streq(hnn, "StrPoly") ? 1
            : sp_streq(hnn, "PolyPoly") ? 2 : -1;
  if (hdp_v < 0) {
    buf_puts(b, "((void)(");
    emit_expr(c, recv, b);
    buf_puts(b, "), (sp_Proc *)NULL)");
    return 1;
  }
  static char hdp_done[3];
  if (!hdp_done[hdp_v]) {
    hdp_done[hdp_v] = 1;
    if (!g_needs_proc_poly_argslot) {
      g_needs_proc_poly_argslot = 1;
      buf_puts(&g_proc_protos, "extern SP_TLS sp_RbVal _sp_proc_poly_args[SP_PROC_ARG_SLOTS];\n");
    }
    const char *kexpr = hdp_v == 0 ? "(sp_sym)sp_poly_to_i(_sp_proc_poly_args[1])"
                      : hdp_v == 1 ? "_sp_proc_poly_args[1].v.s"
                      : "_sp_proc_poly_args[1]";
    buf_printf(&g_procs,
      "static sp_int _hdp_tramp_%s(void *cap, sp_int argc, sp_int *args) {\n"
      "  sp_%sHash *src = (sp_%sHash *)cap; (void)args;\n"
      "  sp_%sHash *h = (argc >= 1 && _sp_proc_poly_args[0].tag == SP_TAG_OBJ)"
      " ? (sp_%sHash *)_sp_proc_poly_args[0].v.p : src;\n"
      "  _sp_proc_poly_ret = (src && src->dproc && argc >= 2)"
      " ? src->dproc(h, %s, src->dproc_self) : sp_box_nil();\n"
      "  return 0;\n}\n"
      "static sp_Proc *_hdp_%s(sp_%sHash *h) {\n"
      "  if (!h || !h->dproc) return NULL;\n"
      "  return sp_proc_new_meta((void *)_hdp_tramp_%s, h, sp_bm_cap_scan, 2, FALSE, 0, NULL, NULL);\n}\n",
      hnn, hnn, hnn, hnn, hnn, kexpr, hnn, hnn, hnn);
  }
  buf_printf(b, "_hdp_%s(", hnn);
  emit_expr(c, recv, b);
  buf_puts(b, ")");
  return 1;
}

/* Hash#to_proc: a Proc mapping a key to the hash value, closing over the
   hash. Emit a per-variant lookup fn matching the sp_proc_call ABI. */
int emit_op_hash_to_proc(Compiler *c, const BopCtx *x, Buf *b) {
  int recv = x->recv;
  TyKind rt = x->rt;
  const char *hn = ty_hash_cname(rt);
  TyKind kt = ty_hash_key(rt), vt = ty_hash_val(rt);
  int pn = ++g_proc_counter;
  /* a PolyPolyHash key is an sp_RbVal, delivered on the proc's poly
     side-channel (args[] carries only scalar bits); the get() takes it
     directly. Scalar-keyed variants read the sp_int slot. */
  const char *keyexpr = (kt == TY_SYMBOL) ? "(sp_sym)args[0]"
                      : (kt == TY_STRING) ? "(const char *)(uintptr_t)args[0]"
                      : (rt == TY_POLY_POLY_HASH) ? "_sp_proc_poly_args[0]"
                      : "args[0]";
  if (rt == TY_POLY_POLY_HASH) g_needs_proc_poly_argslot = 1;
  buf_printf(&g_proc_protos, "static sp_int _hashproc_%d(void *cap, sp_int argc, sp_int *args);\n", pn);
  buf_printf(&g_procs, "static sp_int _hashproc_%d(void *cap, sp_int argc, sp_int *args) {\n", pn);
  /* the hash proc is a lambda: exactly one key, as CRuby's raises --
     the old `argc < 1 -> return 0` left the return slot holding the
     previous call's value */
  buf_printf(&g_procs, "  if (argc != 1) sp_raise_cls(\"ArgumentError\","
             " sp_sprintf(\"wrong number of arguments (given %%lld, expected 1)\", (long long)argc));\n");
  buf_printf(&g_procs, "  sp_%sHash *_h = (sp_%sHash *)cap;\n", hn, hn);
  /* Universal return ABI: publish the boxed value into _sp_proc_poly_ret
     for every value type; the .call site reads the slot back. */
  buf_puts(&g_procs, "  _sp_proc_poly_ret = ");
  { char _ge[256];
    snprintf(_ge, sizeof _ge, "sp_%sHash_get(_h, %s)", hn, keyexpr);
    emit_boxed_text(c, vt, _ge, &g_procs); }
  buf_puts(&g_procs, ";\n  return 0;\n}\n");
  buf_printf(b, "sp_proc_new_meta((void *)_hashproc_%d, (void *)(", pn);
  emit_expr(c, recv, b);
  /* CRuby's Hash#to_proc is a lambda: lambda? answers true and a
     composed call enforces its 1-arity instead of reading a stale slot */
  buf_puts(b, "), sp_hashproc_cap_scan, 1, TRUE, 1, NULL, NULL)");
  return 1;
}

/* h[key]: the variant's getter, or the hash's default for a key of a kind
   the table cannot hold */
int emit_op_hash_aref(Compiler *c, const BopCtx *x, Buf *b) {
  int recv = x->recv;
  TyKind rt = x->rt;
  const char *hn = ty_hash_cname(rt);
  int argc;
  const int *argv = call_args(c->nt, x->id, &argc);
  TyKind arg_kt = comp_ntype(c, argv[0]);
  TyKind hash_kt = ty_hash_key(rt);
  /* key type mismatch: sym key on str-keyed hash (or vice versa) -- the key
     can never exist in the hash, so always return the hash's default
     value. A Symbol on a String-keyed hash was excepted here and
     coerced to its name; that was an older Hash.new{} model (#4531). */
  if (hash_kt != TY_POLY && hash_kt != TY_UNKNOWN &&
      arg_kt != TY_POLY && arg_kt != TY_UNKNOWN && arg_kt != hash_kt &&
      !(hash_kt == TY_STRING && arg_kt == TY_STRBUF) &&
      !hash_nil_key_stored(c, argv[0], hash_kt)) {
    TyKind vt = ty_hash_val(rt);
    int t = ++g_tmp;
    buf_printf(b, "({ %s _t%d = ", c_type_name(rt), t); emit_expr(c, recv, b); buf_puts(b, "; ");
    buf_puts(b, "(void)("); emit_expr(c, argv[0], b); buf_puts(b, "); ");  /* the key still evaluates */
    if (vt == TY_INT) buf_printf(b, "_t%d ? _t%d->default_v : SP_INT_NIL; })", t, t);
    /* absent means the hash's default, which is nil unless one was
       given -- not the empty string (#3790) */
    else if (vt == TY_STRING) buf_printf(b, "_t%d ? _t%d->default_v : NULL; })", t, t);
    else buf_printf(b, "_t%d ? _t%d->default_v : sp_box_nil(); })", t, t);
    return 1;
  }
  if (rt == TY_POLY_POLY_HASH) {
    buf_printf(b, "sp_%sHash_get(", hn);
    emit_expr(c, recv, b); buf_puts(b, ", "); emit_boxed(c, argv[0], b); buf_puts(b, ")");
  }
  else {
    /* int-valued hashes have a nullable get_opt; string-valued use get */
    const char *getter = ty_hash_val(rt) == TY_INT ? "get_opt" : "get";
    buf_printf(b, "sp_%sHash_%s(", hn, getter);
    emit_expr(c, recv, b); buf_puts(b, ", "); emit_hash_key(c, argv[0], ty_hash_key(rt), b); buf_puts(b, ")");
  }
  return 1;
}

/* has_key? / key? / include? / member? */
int emit_op_hash_has_key(Compiler *c, const BopCtx *x, Buf *b) {
  int recv = x->recv;
  TyKind rt = x->rt;
  const char *hn = ty_hash_cname(rt);
  int argc;
  const int *argv = call_args(c->nt, x->id, &argc);
  TyKind hash_kt = ty_hash_key(rt);
  if (hash_key_misses(c, argv[0], hash_kt) && !hash_nil_key_stored(c, argv[0], hash_kt)) {
    /* a key of a class the table cannot hold: false, the receiver and
       the key still evaluated */
    buf_puts(b, "({ (void)("); emit_expr(c, recv, b); buf_puts(b, "); (void)("); emit_expr(c, argv[0], b);
    buf_puts(b, "); 0; })");
    return 1;
  }
  buf_printf(b, "sp_%sHash_has_key(", hn);
  emit_expr(c, recv, b); buf_puts(b, ", "); emit_hash_key(c, argv[0], hash_kt, b); buf_puts(b, ")");
  return 1;
}

/* Hash#key(value): the first key mapping to value. A Symbol-keyed hash
   has a runtime helper; any other variant scans the boxed [key, value]
   pair list, answering the key or nil. */
int emit_op_hash_key(Compiler *c, const BopCtx *x, Buf *b) {
  int recv = x->recv;
  TyKind rt = x->rt;
  const char *hn = ty_hash_cname(rt);
  int argc;
  const int *argv = call_args(c->nt, x->id, &argc);
  if (rt == TY_SYM_POLY_HASH) {
    buf_puts(b, "sp_SymPolyHash_key(");
    emit_expr(c, recv, b); buf_puts(b, ", ");
    emit_boxed(c, argv[0], b);
    buf_puts(b, ")");
    return 1;
  }
  int tp = ++g_tmp, tv = ++g_tmp, tr = ++g_tmp, ti = ++g_tmp;
  buf_printf(b, "({ sp_PolyArray *_t%d = ", tp);
  emit_hash_pairs_expr(c, recv, rt, hn, b);
  buf_printf(b, "; sp_RbVal _t%d = ", tv); emit_boxed(c, argv[0], b);
  buf_printf(b, "; sp_RbVal _t%d = sp_box_nil();", tr);
  buf_printf(b, " for (sp_int _t%d = 0; _t%d < _t%d->len; _t%d++) {", ti, ti, tp, ti);
  buf_printf(b, " sp_PolyArray *_pr = (sp_PolyArray *)_t%d->data[_t%d].v.p;", tp, ti);
  buf_printf(b, " if (sp_poly_eq(_pr->data[1], _t%d)) { _t%d = _pr->data[0]; break; } }", tv, tr);
  buf_printf(b, " _t%d; })", tr);
  return 1;
}

/* Hash#default and #default(key) */
int emit_op_hash_default(Compiler *c, const BopCtx *x, Buf *b) {
  int recv = x->recv;
  TyKind rt = x->rt;
  int argc;
  const int *argv = call_args(c->nt, x->id, &argc);
  int t = ++g_tmp;
  buf_printf(b, "({ %s _t%d = ", c_type_name(rt), t); emit_expr(c, recv, b);
  if (rt == TY_SYM_POLY_HASH || rt == TY_STR_POLY_HASH || rt == TY_POLY_POLY_HASH) {
    /* default(key): a hash built with a block calls its default_proc with
       (self, key); default() (or a hash with no proc) returns default_v
       (#2464). Only the poly-value variants carry a dproc. */
    /* The proc takes the key in the hash's own key representation, so an
       argument of another type cannot be handed to it -- passing an
       Integer where a `const char *` key is expected did not even
       typecheck. Such a key can never be in this hash, so answer the
       plain default. */
    TyKind dkt = argc == 1 ? comp_ntype(c, argv[0]) : TY_UNKNOWN;
    int dkey_ok = rt == TY_POLY_POLY_HASH ||
                  (rt == TY_SYM_POLY_HASH && dkt == TY_SYMBOL) ||
                  (rt == TY_STR_POLY_HASH && (dkt == TY_STRING || dkt == TY_STRBUF));
    if (argc == 1 && dkey_ok) {
      buf_printf(b, "; (_t%d && _t%d->dproc) ? _t%d->dproc(_t%d, ", t, t, t, t);
      if (rt == TY_POLY_POLY_HASH) emit_boxed(c, argv[0], b);
      else emit_expr(c, argv[0], b);
      buf_printf(b, ", _t%d->dproc_self) : (_t%d ? _t%d->default_v : sp_box_nil()); })", t, t, t);
    }
    else if (argc == 1) {
      buf_printf(b, "; (void)("); emit_expr(c, argv[0], b);
      buf_printf(b, "); _t%d ? _t%d->default_v : sp_box_nil(); })", t, t);
    }
    else {
      buf_printf(b, "; _t%d ? _t%d->default_v : sp_box_nil(); })", t, t);
    }
  }
  else if (rt == TY_STR_INT_HASH || rt == TY_INT_INT_HASH) {
    buf_printf(b, "; (_t%d && _t%d->default_v != SP_INT_NIL) ? sp_box_int(_t%d->default_v) : sp_box_nil(); })", t, t, t);
  }
  else if (rt == TY_STR_STR_HASH || rt == TY_INT_STR_HASH) {
    buf_printf(b, "; (_t%d && _t%d->default_v) ? sp_box_str(_t%d->default_v) : sp_box_nil(); })", t, t, t);
  }
  else {
    buf_printf(b, "; (void)_t%d; sp_box_nil(); })", t);
  }
  return 1;
}

/* Hash#keys. A Symbol-keyed hash's runtime returns the sym ids as an
   IntArray, boxed here into a poly (Symbol) array. */
int emit_op_hash_keys(Compiler *c, const BopCtx *x, Buf *b) {
  int recv = x->recv;
  TyKind rt = x->rt;
  const char *hn = ty_hash_cname(rt);
  if (rt == TY_SYM_POLY_HASH) {
    /* runtime returns sym ids as an IntArray; box into a poly (sym) array */
    int ki = ++g_tmp, kp = ++g_tmp, ii = ++g_tmp;
    buf_printf(b, "({ sp_IntArray *_t%d = sp_SymPolyHash_keys(", ki); emit_expr(c, recv, b);
    buf_printf(b, "); SP_GC_ROOT(_t%d); sp_PolyArray *_t%d = sp_PolyArray_new(); SP_GC_ROOT(_t%d);", ki, kp, kp);
    buf_printf(b, " for (sp_int _t%d = 0; _t%d < sp_IntArray_length(_t%d); _t%d++)"
                  " sp_PolyArray_push(_t%d, sp_box_sym((sp_sym)sp_IntArray_get(_t%d, _t%d)));",
               ii, ii, ki, ii, kp, ki, ii);
    buf_printf(b, " _t%d; })", kp);
    return 1;
  }
  buf_printf(b, "sp_%sHash_keys(", hn); emit_expr(c, recv, b); buf_puts(b, ")");
  return 1;
}

/* fetch(key) with no default and no block raises KeyError on a miss */
int emit_op_hash_fetch(Compiler *c, const BopCtx *x, Buf *b) {
  int recv = x->recv;
  TyKind rt = x->rt;
  const char *hn = ty_hash_cname(rt);
  int argc;
  const int *argv = call_args(c->nt, x->id, &argc);
  TyKind vt = ty_hash_val(rt);
  int th = ++g_tmp, tk = ++g_tmp;
  char keytmp[32], htmp[32];
  snprintf(keytmp, sizeof keytmp, "_t%d", tk);
  snprintf(htmp, sizeof htmp, "_t%d", th);
  buf_printf(b, "({ %s _t%d = ", c_type_name(rt), th); emit_expr(c, recv, b);
  buf_printf(b, "; SP_GC_ROOT(_t%d)", th);   /* rooted across the key, as the array arms are */
  if (hash_key_misses(c, argv[0], ty_hash_key(rt)) && !hash_nil_key_stored(c, argv[0], ty_hash_key(rt))) {
    /* a key of a kind the table cannot hold: the KeyError names the
       key itself, so box it once rather than look it up */
    buf_printf(b, "; sp_RbVal _t%d = ", tk); emit_boxed(c, argv[0], b);
    buf_puts(b, "; sp_exc_stage_recv(");
    emit_boxed_text(c, rt, htmp, b);
    buf_printf(b, "); sp_raise_key_not_found(_t%d); %s; })", tk,
               vt == TY_POLY ? "sp_box_nil()" : default_value(vt));
    return 1;
  }
  buf_printf(b, "; %s _t%d = ", c_type_name(ty_hash_key(rt)), tk); emit_hash_key(c, argv[0], ty_hash_key(rt), b);
  buf_printf(b, "; sp_%sHash_has_key(_t%d, _t%d) ? sp_%sHash_get(_t%d, _t%d) : (",
             hn, th, tk, hn, th, tk);
  buf_puts(b, "sp_exc_stage_recv(");
  emit_boxed_text(c, rt, htmp, b);
  buf_puts(b, "), sp_raise_key_not_found(");
  emit_boxed_text(c, ty_hash_key(rt), keytmp, b);
  buf_printf(b, "), %s); })", vt == TY_POLY ? "sp_box_nil()" : default_value(vt));
  return 1;
}

/* Hash#to_s: the inspect text, or "" for a receiver that may be nil */
int emit_op_hash_to_s(Compiler *c, const BopCtx *x, Buf *b) {
  char fn[64]; snprintf(fn, sizeof fn, "sp_%sHash_inspect", ty_hash_cname(x->rt));
  emit_null_guarded_call(c, x->recv, x->rt, fn, "sp_str_empty", b);
  return 1;
}
