/* codegen_poly_plan.c -- the poly dispatch's arm families, moved out of
   emit_poly_method_dispatch (codegen_call.c), and the --plan-check shadow
   that holds the arms it writes against the resolver's (cplan_poly,
   call_plan.c; #7100 Phase C). */

#include "codegen_internal.h"
#include "call_plan.h"

/* ---- --plan-check: the arms one emitted switch wrote ----
   A frame per switch being written; a nested dispatch (an argument's
   default) opens its own. A probe that longjmps out of a frame leaves it
   behind, and the enclosing pa_end drops it with its own. */
typedef struct { int id; int n, cap; PolyArm *arm; } PaFrame;
static PaFrame *g_pa;
static int g_pa_n, g_pa_cap;
static long g_pa_compared, g_pa_arms, g_pa_conflict, g_pa_missing, g_pa_extra;

int pa_begin(int id) {
  if (g_pa_n == g_pa_cap) {
    int ncap = g_pa_cap ? g_pa_cap * 2 : 8;
    g_pa = realloc(g_pa, (size_t)ncap * sizeof *g_pa);
    memset(g_pa + g_pa_cap, 0, (size_t)(ncap - g_pa_cap) * sizeof *g_pa);
    g_pa_cap = ncap;
  }
  PaFrame *f = &g_pa[g_pa_n];
  f->id = id; f->n = 0;
  return g_pa_n++;
}

void pa_observe(int kind, int key, int mi, TyKind vty, int conv) {
  if (g_pa_n <= 0) return;
  PaFrame *f = &g_pa[g_pa_n - 1];
  if (f->n == f->cap) {
    f->cap = f->cap ? f->cap * 2 : 8;
    f->arm = realloc(f->arm, (size_t)f->cap * sizeof *f->arm);
  }
  PolyArm *a = &f->arm[f->n++];
  a->kind = (unsigned char)kind; a->key = (short)key; a->mi = mi;
  a->vty = (unsigned char)vty; a->conv = (unsigned char)conv;
}

static const char *pa_kind_name(int k) {
  static const char *const nm[] = { "user", "proc-form", "reader", "native", "arity", "synth-enum" };
  return k >= 0 && k < (int)(sizeof nm / sizeof nm[0]) ? nm[k] : "?";
}

static void pa_arm_text(Compiler *c, const PolyArm *a, char *out, size_t n) {
  snprintf(out, n, "%s %s mi %d vty %d conv %d", c->classes[a->key].name, pa_kind_name(a->kind),
           a->mi, a->vty, a->conv);
}

void pa_end(Compiler *c, int frame, const PolyPlan *p) {
  if (frame < 0 || frame >= g_pa_n) return;
  PaFrame *f = &g_pa[frame];
  const char *nm = nt_str(c->nt, f->id, "name");
  char pt[400], ct[400];
  g_pa_compared++;
  g_pa_arms += f->n;
  /* both lists are in class order: walk them together by key */
  int i = 0, j = 0;
  while (i < p->n || j < f->n) {
    const PolyArm *pa = i < p->n ? &p->arm[i] : NULL, *ca = j < f->n ? &f->arm[j] : NULL;
    if (pa && (!ca || pa->key < ca->key)) {
      pa_arm_text(c, pa, pt, sizeof pt);
      fprintf(stderr, "plan-check: poly-missing: node %d %s: plan %s\n", f->id, nm ? nm : "?", pt);
      g_pa_missing++; i++;
    }
    else if (ca && (!pa || ca->key < pa->key)) {
      pa_arm_text(c, ca, ct, sizeof ct);
      fprintf(stderr, "plan-check: poly-extra: node %d %s: codegen %s\n", f->id, nm ? nm : "?", ct);
      g_pa_extra++; j++;
    }
    else {
      if (pa->kind != ca->kind || pa->mi != ca->mi || pa->vty != ca->vty || pa->conv != ca->conv) {
        pa_arm_text(c, pa, pt, sizeof pt); pa_arm_text(c, ca, ct, sizeof ct);
        fprintf(stderr, "plan-check: poly-conflict: node %d %s: plan %s, codegen %s\n", f->id,
                nm ? nm : "?", pt, ct);
        g_pa_conflict++;
      }
      i++; j++;
    }
  }
  g_pa_n = frame;
}

void pa_report(void) {
  fprintf(stderr, "plan-check: poly-arms: %ld switches, %ld arms, %ld conflicts, %ld missing, %ld extra\n",
          g_pa_compared, g_pa_arms, g_pa_conflict, g_pa_missing, g_pa_extra);
}

/* The user-class arms of a blockless zero-argument poly dispatch
   (emit_poly_method_dispatch): one `case` per class a boxed receiver can be
   at run time -- its method (or proc form), a reader, a native binding, an
   arity refusal -- writing the result temp _t<tr> from receiver _t<tv>.
   --plan-check observes each arm for the shadow comparison with
   cplan_poly. */
void emit_poly_user_arms0(Compiler *c, int id, const char *name, int argc, TyKind ret, int tv, int tr,
                          int blk_tmp0, Buf *b) {
  const NodeTable *nt = c->nt;
  for (int k = 0; k < c->nclasses; k++) {
    /* A never-instantiated class can't be this poly value's runtime class,
       so drop its arm (method or reader); the referenced symbol then DCEs
       as an unreferenced static (#1608). A primitive reopen's instances
       exist without any constructor, so it keeps its arm (#4219). */
    if (!c->classes[k].instantiated && !class_is_prim_reopen(c, k)) continue;
    /* native (C-backed) class arm: dispatch a declared no-arg method to its
       C symbol on the cast receiver, coercing the result into the slot. */
    if (c->classes[k].is_native_class) {
      int nmi = comp_native_method_find(c, k, name, 0, 0);
      /* only a binding that takes no argument: the lookup falls back to
         any arity, and StringScanner#peek(len) beside two user `peek`s
         got an arm calling it with none, which C refused (#5359). A
         receiver of that class then lands in the default arm. */
      if (nmi >= 0 && native_takes(&c->native_methods[nmi], 0)) {
        NativeMethod *nmet = &c->native_methods[nmi];
        char nbuf[300];
        const char *rest0 = nmet->rest ? ", 0, NULL" : "";
        if (sp_streq(nmet->ret, "string?"))
          snprintf(nbuf, sizeof nbuf, "sp_box_nullable_str(%s((%s *)_t%d.v.p%s))", nmet->csym, c->classes[k].c_struct, tv, rest0);
        else
          snprintf(nbuf, sizeof nbuf, "%s((%s *)_t%d.v.p%s)", nmet->csym, c->classes[k].c_struct, tv, rest0);
        TyKind mret = native_spec_to_ty(nmet->ret);
        buf_printf(b, " case %d: ", k);
        int pconv = PC_SAME;
        if (mret == TY_NIL) { buf_puts(b, nbuf); pconv = PC_VOID; }
        else {
          buf_printf(b, "_t%d = ", tr);
          if (ret == TY_POLY && mret != TY_POLY) { emit_boxed_text(c, mret, nbuf, b); pconv = PC_BOX; }
          else if (ret != TY_POLY && mret == TY_POLY) {
            emit_unbox_poly_ret(c, is_scalar_ret(ret) ? ret : TY_INT, nbuf, b);
            pconv = PC_UNBOX;
          }
          else buf_puts(b, nbuf);
        }
        buf_puts(b, "; break;");
        if (g_plan_check) pa_observe(PA_NATIVE, k, -1, mret, pconv);
      }
      /* one that needs arguments is CRuby's ArgumentError for this call */
      else if (nmi >= 0 && c->native_methods[nmi].nargs > 0 && c->classes[k].instantiated) {
        char am[128];
        arity_message(am, sizeof am, 0, c->native_methods[nmi].nargs, c->native_methods[nmi].nargs, NULL);
        buf_printf(b, " case %d: sp_raise_cls(\"ArgumentError\", \"%s\"); break;", k, am);
        if (g_plan_check) pa_observe(PA_ARITY, k, -1, TY_UNKNOWN, PC_VOID);
      }
      continue;
    }
    int defcls = -1;
    int mi = comp_method_in_chain(c, k, name, &defcls);
    /* an exception class with no method of its own for the name takes
       the builtin reopening's (`class Exception; def brief`) */
    if (mi < 0 && any_exc_reopen(c) && (class_has_exc_name(c, k) || class_is_exc_subclass(c, k))) {
      int xd = exc_arm_definer(c, k, name);
      if (xd >= 0) { defcls = xd; mi = comp_method_in_chain(c, xd, name, NULL); }
    }
    /* A Struct's synthesized each or each_pair, called with no block on a
       boxed receiver: the typed receiver answers an Enumerator over the
       members (its blockless each is redirected through __enum_to_a, its
       each_pair through to_h), and the synthesized method, which yields,
       raised LocalJumpError when this arm called it with no block. The
       each Enumerator is built over the member array the generated
       per-class dispatch answers, the each_pair one over the member hash
       the to_h hook answers, so it yields [name, value] pairs. Not for a
       Data class, which has neither name in CRuby. */
    if (mi >= 0 && c->classes[k].is_struct && !c->classes[k].is_data &&
        g_gen_obj_struct_values && ret == TY_POLY && argc == 0 &&
        nt_ref(nt, id, "block") < 0 &&
        nt_str(nt, c->scopes[mi].def_node, "synth") &&
        (sp_streq(name, "each") || sp_streq(name, "each_pair"))) {
      buf_printf(b, " case %d: _t%d = sp_box_obj(sp_Enumerator_new_from(%s(_t%d)), "
                    "SP_BUILTIN_ENUMERATOR); break;",
                 k, tr, sp_streq(name, "each") ? "sp_obj_struct_values_fn" : "sp_obj_to_h_fn", tv);
      if (g_plan_check) pa_observe(PA_SYNTH_ENUM, k, mi, TY_ENUMERATOR, PC_SAME);
      continue;
    }
    /* Skip a method with no standalone definition to call: DCE-pruned (its
       params stayed TY_UNKNOWN so it was marked unreachable) or inlined at
       call sites because it yields. Emitting a `case` arm that calls the
       absent `sp_Class_method` symbol dangles at link (issue #1583). The
       class can never be the receiver of this poly value anyway. */
    /* A yielding candidate has a proc form emitted for exactly this
       dispatch (#3399); it is as callable as any other symbol here. */
    { char zexp[600]; int rdc0 = -1;
      if (poly_arm_refuses_none(c, mi, zexp, sizeof zexp) &&
          !comp_reader_in_chain(c, k, name, &rdc0)) {
        buf_printf(b, " case %d: ", k); emit_poly_arity_raise(b, zexp); buf_puts(b, " break;");
        if (g_plan_check) pa_observe(PA_ARITY, k, mi, TY_UNKNOWN, PC_VOID);
        continue;
      } }
    if (mi >= 0 && c->scopes[mi].nrequired == 0 &&
        (scope_has_callable_symbol(c, mi) || scope_needs_proc_form(c, mi)) &&
        !(c->classes[defcls].name && sp_streq(c->classes[defcls].name, "Class"))) {
      nd_callee(c, id, mi, defcls, 1);   /* one switch arm (#4557) */
      /* Build the call; append default values for any optional params
         not provided by the (zero-arg) call site. */
      Buf cb; memset(&cb, 0, sizeof cb);
      /* A reopened primitive (Integer/Float/String/Symbol) method takes the
         unboxed value, not a struct pointer -- read the matching union field
         instead of casting .v.p to a non-existent sp_<Prim> struct. */
      const char *_dcn = c->classes[defcls].c_name;
      char _dself[320];
      int _dstruct = 0;   /* the receiver is a struct pointer in .v.p */
      if (sp_streq(_dcn, "Integer")) snprintf(_dself, sizeof _dself, "_t%d.v.i", tv);
      /* a Numeric reopen takes self BOXED (it serves Integer and Float
         alike), not the int payload (blank.rb) */
      else if (sp_streq(_dcn, "Numeric")) snprintf(_dself, sizeof _dself, "_t%d", tv);
      else if (sp_streq(_dcn, "Float")) snprintf(_dself, sizeof _dself, "_t%d.v.f", tv);
      /* a plain string box or a mutable handle: deref answers the live
         text for the handle and is the identity for the plain box */
      else if (sp_streq(_dcn, "String")) snprintf(_dself, sizeof _dself, "sp_poly_strbuf_deref(_t%d).v.s", tv);
      else if (sp_streq(_dcn, "Symbol")) snprintf(_dself, sizeof _dself, "(sp_sym)_t%d.v.i", tv);
      else if (sp_streq(_dcn, "NilClass")) snprintf(_dself, sizeof _dself, "0");
      /* Object's (and Array's) methods take self boxed */
      else if (sp_streq(_dcn, "Object") || sp_streq(_dcn, "Array"))
        snprintf(_dself, sizeof _dself, "_t%d", tv);
      else if (sp_streq(_dcn, "TrueClass") || sp_streq(_dcn, "FalseClass"))
        snprintf(_dself, sizeof _dself, "(int)_t%d.v.b", tv);
      else if (sp_streq(_dcn, "NilClass")) snprintf(_dself, sizeof _dself, "0");
      else if (sp_streq(_dcn, "TrueClass") || sp_streq(_dcn, "FalseClass")) snprintf(_dself, sizeof _dself, "(int)_t%d.v.i", tv);
      else if (sp_streq(_dcn, "Array") || sp_streq(_dcn, "Hash") || sp_streq(_dcn, "Object"))
        snprintf(_dself, sizeof _dself, "_t%d", tv);
      /* a boxed Time / Range points at the value; the reopen takes it by value */
      else if (sp_streq(_dcn, "Time") || sp_streq(_dcn, "Range"))
        snprintf(_dself, sizeof _dself, "*(sp_%s *)_t%d.v.p", _dcn, tv);
      /* a boxed thread is the runtime's sp_thread handle (not an sp_Thread struct) */
      else if (sp_streq(_dcn, "Thread")) { snprintf(_dself, sizeof _dself, "(sp_thread *)_t%d.v.p", tv); _dstruct = 1; }
      /* a boxed IO or socket is the runtime's sp_File handle */
      else if (io_family_class(c, defcls)) {
        /* a block-taking IO reopening has no standalone function (as typed) */
        if (c->scopes[mi].yields || (c->scopes[mi].blk_param && c->scopes[mi].blk_param[0]))
          unsupported(c, id, "call");
        snprintf(_dself, sizeof _dself, "(sp_File *)_t%d.v.p", tv); _dstruct = 1;
      }
      /* a boxed exception is the runtime's sp_Exception, whatever its class */
      else if (class_has_exc_name(c, defcls)) { snprintf(_dself, sizeof _dself, "(sp_Exception *)_t%d.v.p", tv); _dstruct = 1; }
      /* a by-value (value-type) class method takes self by value:
         dereference the boxed pointer instead of passing it (#2441) */
      else if (c->classes[defcls].is_value_type) {
        snprintf(_dself, sizeof _dself, "*(sp_%s *)_t%d.v.p", _dcn, tv); _dstruct = 1; }
      else { snprintf(_dself, sizeof _dself, "(sp_%s *)_t%d.v.p", _dcn, tv); _dstruct = 1; }
      /* a yielding candidate is called through its proc-form clone (#3399) */
      int pfi9 = scope_proc_form_of(c, mi);
      buf_printf(&cb, "sp_%s_%s(%s", mc_reopen_cls(c, defcls, c->scopes[mi].name),
                 mc(pfi9 >= 0 ? c->scopes[pfi9].name : c->scopes[mi].name), _dself);
      if (c->scopes[mi].nparams > 0) {
        const char *saved_self = g_self;
        const char *saved_deref = g_self_deref;
        char selfpbuf[320];  /* stack-local: nested inlines each need their own receiver buffer */
        /* A default reads the receiver's ivars as `<self><deref><iv>`, so
           the receiver is parenthesized: a bare cast binds looser than
           `->`. A by-value class is spelled as the dereferenced value, so
           a `self` default passes what the callee takes. */
        if (_dstruct && c->classes[defcls].is_value_type) {
          snprintf(selfpbuf, sizeof selfpbuf, "(*(sp_%s *)_t%d.v.p)", _dcn, tv);
          g_self_deref = ".";
        }
        else if (_dstruct && io_family_class(c, defcls)) {
          snprintf(selfpbuf, sizeof selfpbuf, "((sp_File *)_t%d.v.p)", tv);
          g_self_deref = "->";
        }
        else if (_dstruct && class_has_exc_name(c, defcls)) {
          snprintf(selfpbuf, sizeof selfpbuf, "((sp_Exception *)_t%d.v.p)", tv);
          g_self_deref = "->";
        }
        else if (_dstruct) {
          snprintf(selfpbuf, sizeof selfpbuf, "((sp_%s *)_t%d.v.p)", _dcn, tv);
          g_self_deref = "->";
        }
        else snprintf(selfpbuf, sizeof selfpbuf, "%s", _dself);
        g_self = selfpbuf;
        /* the defaults are spelled for the proc form's own parameter
           types when that is the symbol called (#4492) */
        Scope *ds = &c->scopes[pfi9 >= 0 ? pfi9 : mi];
        for (int a = 0; a < ds->nparams; a++) {
          buf_puts(&cb, ", "); emit_arg_or_default(c, ds, a, -1, &cb);
        }
        g_self = saved_self; g_self_deref = saved_deref;
      }
      /* self is always the first argument here, so a zero-param method
         still needs the separator the helper only adds after a real
         parameter list. */
      if (c->scopes[mi].nparams == 0 && c->scopes[mi].blk_param &&
          c->scopes[mi].blk_param[0] && !c->scopes[mi].yields)
        buf_puts(&cb, ", ");
      if (scope_needs_proc_form(c, mi)) {
        /* the proc form always takes the block, and its scope still reads
           as yielding, so the helper declines it (#3399) */
        if (blk_tmp0 >= 0) buf_printf(&cb, ", _t%d", blk_tmp0);
        else buf_puts(&cb, ", NULL");
      }
      else emit_cmethod_block_arg(c, id, &c->scopes[mi], blk_tmp0, &cb);
      buf_puts(&cb, ")");
      const char *call = cb.p ? cb.p : "";
      buf_printf(b, " case %d: ", k);
      /* A proc form is a separately inferred clone, so its own return type
         is the one to read -- not the original's, which an inlined-only
         method never needed (#3399). */
      int pf9 = pfi9 >= 0;
      TyKind cret9 = pf9 ? c->scopes[pfi9].ret : c->scopes[mi].ret;
      if (!(pf9 ? method_is_void(&c->scopes[pfi9]) : method_is_void(&c->scopes[mi]))) { }
      int pconv = PC_SAME;
      if ((pf9 ? method_is_void(&c->scopes[pfi9]) : method_is_void(&c->scopes[mi]))) {
        buf_puts(b, call);  /* void: no usable value */
        pconv = PC_VOID;
      }
      else {
        TyKind slotty = is_scalar_ret(ret) ? ret : TY_INT;
        buf_printf(b, "_t%d = ", tr);
        if (ret == TY_POLY && cret9 != TY_POLY) { emit_boxed_text(c, cret9, call, b); pconv = PC_BOX; }
        /* The slot is scalar (e.g. a length dispatch fixed to sp_int) but
           this class's method widened its return to poly: coerce down. */
        else if (ret != TY_POLY && cret9 == TY_POLY) { emit_unbox_poly_ret(c, slotty, call, b); pconv = PC_UNBOX; }
        /* Two classes own the name and answer different types (one an
           Integer, another a Bignum): the slot took one of them, so the
           odd arm converts into it rather than emitting a type error. */
        else if (slotty == TY_INT && cret9 == TY_BIGINT) { buf_printf(b, "sp_bigint_to_int(%s)", call); pconv = PC_NUM; }
        else if (slotty == TY_FLOAT && cret9 == TY_BIGINT) { buf_printf(b, "sp_bigint_to_double(%s)", call); pconv = PC_NUM; }
        else buf_puts(b, call);
      }
      buf_puts(b, "; break;");
      free(cb.p);
      if (g_plan_check) pa_observe(pf9 ? PA_PROC_FORM : PA_USER, k, mi, cret9, pconv);
      continue;
    }
    int rdcls = -1;
    if (comp_reader_in_chain(c, k, name, &rdcls)) {
      const char *rn3 = comp_resolve_alias(c, k, name);
      char fld[600];
      snprintf(fld, sizeof fld, "((sp_%s *)_t%d.v.p)->iv_%s", c->classes[rdcls].c_name, tv, iv_c(rn3));
      char ivn[256]; snprintf(ivn, sizeof ivn, "@%s", rn3);
      int ivx = comp_ivar_index(&c->classes[rdcls], ivn);
      TyKind ivt = ivx >= 0 ? c->classes[rdcls].ivar_types[ivx] : TY_INT;
      buf_printf(b, " case %d: _t%d = ", k, tr);
      int pconv = PC_SAME;
      /* an int ivar is SP_INT_NIL-defaulted: box the sentinel as nil
         (#3288); or_nil is a no-op on a real int */
      if (ret == TY_POLY && ivt == TY_INT) {
        buf_printf(b, "sp_box_int_or_nil(%s)", fld);
        pconv = PC_BOX_OR_NIL;
      }
      else if (ret == TY_POLY && ivt != TY_POLY) { emit_boxed_text(c, ivt, fld, b); pconv = PC_BOX; }
      /* The slot is scalar (e.g. a length dispatch fixed to sp_int) but
         this class's ivar widened to poly: coerce down. */
      else if (ret != TY_POLY && ivt == TY_POLY) {
        emit_unbox_text(c, is_scalar_ret(ret) ? ret : TY_INT, fld, b);
        pconv = PC_UNBOX;
      }
      /* shared-mutable ivar read into a plain string slot: the safe
         copy, not the raw handle pointer (#3227) */
      else if (ivt == TY_STRBUF && ret == TY_STRING) {
        buf_printf(b, "%s ? sp_str_concat(sp_String_cstr(%s), (&(\"\\xff\")[1])) : NULL", fld, fld);
        pconv = PC_COPY;
      }
      else buf_puts(b, fld);
      buf_puts(b, "; break;");
      if (g_plan_check) pa_observe(PA_READER, k, -1, ivt, pconv);
    }
  }
}

/* One user-class arm of a poly dispatch with arguments: `case k:` calling
   `call`, its value (mret, from the method or its proc form ms) into the
   result temp _t<tr> as the call's type ret takes it. The conversion
   applied (PolyConv). */
int emit_poly_user_arm_n(Compiler *c, int k, const char *call, TyKind mret, Scope *ms, TyKind ret,
                         int tr, int is_setter_val, Buf *b) {
  int conv = PC_SAME;
  buf_printf(b, " case %d: ", k);
  if (is_setter_val || mret == TY_VOID || mret == TY_NIL || method_is_void(ms)) {
    buf_puts(b, call);  /* no usable value */
    conv = PC_VOID;
  }
  else {
    buf_printf(b, "_t%d = ", tr);
    if (ret == TY_POLY && mret != TY_POLY) { emit_boxed_text(c, mret, call, b); conv = PC_BOX; }
    else if (ret != TY_POLY && mret == TY_POLY) {
      emit_unbox_text(c, is_scalar_ret(ret) ? ret : TY_INT, call, b);
      conv = PC_UNBOX;
    }
    else buf_puts(b, call);
  }
  buf_puts(b, "; break;");
  return conv;
}

/* The builtin array arms of a poly `x[i]`: the element at index expression
   idxref, into the result temp. */
void emit_poly_index_cases(TyKind ret, int tr, int tv, const char *idxref, Buf *b) {
  if (ret == TY_POLY) {
    /* An Integer or Float array answers a nil element, and any index
       past its end, with its sentinel: the _or_nil box reads that as
       nil. The plain box made `x[9]` the sentinel as a number -- nil?
       false, and NaN for a Float array. */
    buf_printf(b, " case SP_BUILTIN_INT_ARRAY: _t%d = sp_box_int_or_nil(sp_IntArray_get((sp_IntArray *)_t%d.v.p, %s)); break;", tr, tv, idxref);
    buf_printf(b, " case SP_BUILTIN_STR_ARRAY: _t%d = sp_box_str(sp_StrArray_get((sp_StrArray *)_t%d.v.p, %s)); break;", tr, tv, idxref);
    buf_printf(b, " case SP_BUILTIN_FLT_ARRAY: _t%d = sp_box_float_or_nil(sp_FloatArray_get((sp_FloatArray *)_t%d.v.p, %s)); break;", tr, tv, idxref);
    buf_printf(b, " case SP_BUILTIN_POLY_ARRAY: _t%d = sp_PolyArray_get((sp_PolyArray *)_t%d.v.p, %s); break;", tr, tv, idxref);
    buf_printf(b, " case SP_BUILTIN_PTR_ARRAY: _t%d = sp_PtrArray_get_box((sp_PtrArray *)_t%d.v.p, %s); break;", tr, tv, idxref);
  }
  else {
    buf_printf(b, " case SP_BUILTIN_INT_ARRAY: _t%d = sp_IntArray_get((sp_IntArray *)_t%d.v.p, %s); break;", tr, tv, idxref);
  }
}
