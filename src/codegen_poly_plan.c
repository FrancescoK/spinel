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
typedef struct { int id; unsigned flags; int n, cap; PolyArm *arm; } PaFrame;
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
  f->id = id; f->n = 0; f->flags = 0;
  return g_pa_n++;
}

void pa_resume(int frame) {
  if (frame >= 0 && frame < g_pa_n) g_pa_n = frame + 1;
}

void pa_flags(unsigned flags) {
  if (g_pa_n > 0) g_pa[g_pa_n - 1].flags = flags | PPF_SEEN;
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

void pa_observe_at(int id, int kind, int key, int mi, TyKind vty, int conv) {
  if (g_pa_n > 0 && g_pa[g_pa_n - 1].id == id) pa_observe(kind, key, mi, vty, conv);
}

static const char *pa_kind_name(int k) {
  static const char *const nm[] = { "user", "proc-form", "reader", "native", "arity", "synth-enum",
                                    "builtin" };
  return k >= 0 && k < (int)(sizeof nm / sizeof nm[0]) ? nm[k] : "?";
}

static void pa_arm_text(Compiler *c, const PolyArm *a, char *out, size_t n) {
  static const char *const fam[] = { "len", "empty", "class-named", "class-reflect", "ostruct", "to_a",
                                     "io-rewind", "io-puts", "io-zero", "reduce", "int-chr", "str-transform",
                                     "split", "enum-proc", "synchronize", "callable", "class-members" };
  char kb[48];
  if (a->key >= 0 && a->key < c->nclasses) snprintf(kb, sizeof kb, "%s", c->classes[a->key].name);
  else if (a->key == PA_KEY_DEFAULT) snprintf(kb, sizeof kb, "default");
  else if (a->key >= PA_KEY_CLASS_VALUE && a->key < PA_KEY_BUILTIN && a->key - PA_KEY_CLASS_VALUE < c->nclasses)
    snprintf(kb, sizeof kb, "%s (class value)", c->classes[a->key - PA_KEY_CLASS_VALUE].name);
  else if (a->key >= PA_KEY_BUILTIN && a->key - PA_KEY_BUILTIN < (int)(sizeof fam / sizeof fam[0]))
    snprintf(kb, sizeof kb, "%s", fam[a->key - PA_KEY_BUILTIN]);
  else snprintf(kb, sizeof kb, "key %d", a->key);
  snprintf(out, n, "%s %s mi %d vty %d conv %d", kb, pa_kind_name(a->kind), a->mi, a->vty, a->conv);
}

static int pa_key_cmp(const void *x, const void *y) {
  return ((const PolyArm *)x)->key - ((const PolyArm *)y)->key;
}

void pa_end(Compiler *c, int frame, const PolyPlan *p) {
  if (frame < 0 || frame >= g_pa_n) return;
  PaFrame *f = &g_pa[frame];
  const char *nm = nt_str(c->nt, f->id, "name");
  char pt[400], ct[400];
  g_pa_compared++;
  g_pa_arms += f->n;
  if ((f->flags & PPF_SEEN) && (f->flags & ~PPF_SEEN) != (p->flags & ~PPF_SEEN)) {
    fprintf(stderr, "plan-check: poly-conflict: node %d %s: flags: plan %#x, codegen %#x\n", f->id,
            nm ? nm : "?", p->flags & ~PPF_SEEN, f->flags & ~PPF_SEEN);
    g_pa_conflict++;
  }
  /* both lists by key: the switch writes its tag pre-arms and builtin cases
     around the class arms */
  PolyArm *pl = p->n ? malloc((size_t)p->n * sizeof *pl) : NULL;
  if (p->n) memcpy(pl, p->arm, (size_t)p->n * sizeof *pl);
  qsort(pl, (size_t)p->n, sizeof *pl, pa_key_cmp);
  qsort(f->arm, (size_t)f->n, sizeof *f->arm, pa_key_cmp);
  int i = 0, j = 0;
  while (i < p->n || j < f->n) {
    const PolyArm *pa = i < p->n ? &pl[i] : NULL, *ca = j < f->n ? &f->arm[j] : NULL;
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
  free(pl);
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

/* The names a blockless-or-not zero-argument poly dispatch answers
   beside its user arms (the pre-arms and builtin cases of
   emit_poly_method_dispatch), and its user candidates: ncand classes own
   the name at all, ncall_arm of them get a calling arm (the root
   decision). Shared by the dispatch and the resolver (cplan_poly). */
void poly_specials0(Compiler *c, int id, const char *name, PolySpecials0 *s) {
  const NodeTable *nt = c->nt;
  int argc = 0;
  int is_lengthlike = sp_streq(name, "length") || sp_streq(name, "size") || sp_streq(name, "count");
  int is_empty = sp_streq(name, "empty?");
  /* A class-tagged poly value answers these with its class name (#2656); only
     when no user class defines them, or that user method is the real target. */
  int is_class_named = (sp_streq(name, "name") || sp_streq(name, "to_s") ||
                        sp_streq(name, "inspect")) && !recv_user_defines(c, name);
  /* The Module reflection a class-tagged poly value answers. `ancestors` and
     friends had an arm only for a receiver typed TY_CLASS -- a constant --
     so iterating an Array of classes and asking the block parameter left the
     call with no arm at all and it reported the method as undefined (#4018). */
  int is_class_reflect = (sp_streq(name, "ancestors") || sp_streq(name, "included_modules") ||
                          sp_streq(name, "superclass") ||
                          /* the class-side names the generated sp_cls_* answer
                             (members has its arm in emit_poly_call) */
                          (g_gen_cls_answers && nt_ref(nt, id, "block") < 0 &&
                           (sp_streq(name, "subclasses") || sp_streq(name, "allocate") ||
                            sp_streq(name, "keyword_init?")))) &&
                         !recv_user_defines(c, name);
  /* `members` on a Class read out of a container is its member list (the
     generated sp_cls_members). emit_poly_call's arm answers that, unless
     a class reads a value of its own as `members` or defines the method:
     then the call is this dispatch's, and a boxed class, which carries the
     CLASS's id, would take that class's instance arm. Where no class-side
     switch takes class values (emit_poly_cls_value_prearm), they are
     told apart ahead of the instance switch. */
  int is_cls_members = sp_streq(name, "members") && g_gen_cls_answers &&
                       nt_ref(nt, id, "block") < 0;
  int is_pred = nt_ref(nt, id, "block") < 0 && poly_pred_kind(name, 0);
  /* When ostruct is in the program a bare `obj.reader` on a poly value may be
     an OpenStruct member access (any name) -- read it at runtime (#3197).
     The check keys on cls_id == SP_BUILTIN_OPENSTRUCT, so it cannot alias a
     user-class arm and coexists with them: a poly value that unions an
     OpenStruct with user objects (OpenStruct|nil return) still reads the
     member when a user class happens to define the same name (#3264). */
  /* An OpenStruct answers ANY reader with a member; but a name the poly
     dispatch already serves with a real builtin arm must keep that arm, or
     the member fetch replaces it and returns nil (#3341). */
  int is_ostruct = argc == 0 && nt_ref(nt, id, "block") < 0 &&
                   !is_lengthlike && !is_empty && !is_pred &&
                   !poly_builtin_zero_arg_name(name) &&
                   sp_feature_required("ostruct");
  /* `rewind` on a poly stream (a param unioning StringIO and IO, #3257):
     both are builtins/native classes with no user arm, so without this
     pre-arm the call was silently dropped. */
  int is_io_rewind = sp_streq(name, "rewind") && !recv_user_defines(c, name);
  /* to_a on a poly value that is really a builtin hash/array (a yield-result
     union of an rbs-seeded Hash and a class instance, #3278): the user-class
     switch has no builtin arm, so the hash fell through to the nil seed. */
  int is_poly_to_a = sp_streq(name, "to_a") &&
                     (comp_ntype(c, id) == TY_POLY_ARRAY || comp_ntype(c, id) == TY_POLY);
  /* to_h on a poly value that is really a builtin hash (or an Array of
     pairs, or a Struct): the user-class switch carries an arm per class that
     defines to_h and none for the builtin, so a plain Hash reached the
     default and raised -- naming Hash, the class whose method it is. Every
     sibling (to_a, to_s, keys, length) already had its arm (#4170). */
  int is_poly_to_h = sp_streq(name, "to_h") && argc == 0 &&
                     nt_ref(nt, id, "block") < 0 &&
                     comp_ntype(c, id) == TY_POLY;
  int ncand = 0, ncall_arm = 0;
  for (int k = 0; k < c->nclasses; k++) {
    /* comp_poly_arm_defines: a native class counts only through its
       declared bindings (#4504) -- its Ruby-side defs get no arm in the
       BLOCKLESS switch below. A block-carrying call is different: the
       block dispatch reaches Ruby-side defs through their proc form, and
       poly_block_call_needs_dispatch stands the element-loop emitters
       down on their account -- so the claim here has to keep counting
       them, or `arr.each { }` beside a loaded StringIO had no emitter at
       all and became the terminal raise. */
    int is_call = comp_poly_arm_defines(c, k, name) ||
                  (nt_ref(nt, id, "block") >= 0 && c->classes[k].is_native_class &&
                   comp_method_in_chain(c, k, name, NULL) >= 0);
    if (is_call || (!c->classes[k].is_native_class && comp_reader_in_chain(c, k, name, NULL))) ncand++;
    /* The root decision counts only the arms the switch below will carry:
       a class no reachable code constructs gets no arm, so it must not
       decide the root either. A dead FFI wrapper's Vector2 counted as a
       calling arm, and every `x` read of a Struct field paid a root push
       and pop for an arm that could not run (#4460). ncand keeps every
       candidate, as the choice to emit a dispatch at all always has. */
    if (is_call && (c->classes[k].instantiated || class_is_prim_reopen(c, k))) ncall_arm++;
  }
  s->lengthlike = is_lengthlike;
  s->empty = is_empty;
  s->class_named = is_class_named;
  s->class_reflect = is_class_reflect;
  s->cls_members = is_cls_members;
  s->pred = is_pred;
  s->ostruct = is_ostruct;
  s->io_rewind = is_io_rewind;
  s->poly_to_a = is_poly_to_a;
  s->poly_to_h = is_poly_to_h;
  s->ncand = ncand;
  s->ncall_arm = ncall_arm;
}

/* The Object reopening's method of the name, as a zero-argument poly
   dispatch's `default:` arm (any receiver no class arm took): through its
   proc form with the call's block, plainly, or an arity refusal. 1 when the
   arm was written. *blk_tmp0 is the hoisted block, made here when the proc
   form needs it. */
int emit_poly_obj_default0(Compiler *c, int id, const char *name, int argc, TyKind ret, int tv, int tr,
                           int *blk_tmp0, Buf *b) {
  const NodeTable *nt = c->nt;
  int done = 0;
  { int obj_cls = comp_class_index(c, "Object");
    if (obj_cls >= 0) {
      int obj_def = -1;
      int obj_mi = comp_method_in_chain(c, obj_cls, name, &obj_def);
      /* A yielding one is reached with the call's block through its proc
         form: a user class's chain does not name Object, so without this
         arm an instance of it took the raise (#5101) */
      int obj_pf = (obj_mi >= 0 && obj_def == obj_cls && argc == 0 &&
                    c->scopes[obj_mi].yields && nt_ref(nt, id, "block") >= 0)
                   ? scope_proc_form_of(c, obj_mi) : -1;
      if (obj_pf >= 0 && (c->scopes[obj_pf].nparams != 0 || c->scopes[obj_pf].rest_idx >= 0))
        obj_pf = -1;
      if (obj_pf >= 0 && (*blk_tmp0) < 0) {
        int cblk3 = resolve_forwarded_block(c, nt_ref(nt, id, "block"));
        if (cblk3 < 0) obj_pf = -1;
        else (*blk_tmp0) = hoist_block_proc(c, cblk3);
      }
      if (obj_pf >= 0) {
        Buf oc; memset(&oc, 0, sizeof oc);
        emit_method_cname(c, &c->scopes[obj_pf], &oc);
        buf_printf(&oc, "(_t%d, _t%d)", tv, (*blk_tmp0));
        TyKind pr = (TyKind)c->scopes[obj_pf].ret;
        buf_puts(b, " default: ");
        int pconv = PC_SAME;
        if (method_is_void(&c->scopes[obj_pf])) { buf_puts(b, oc.p); pconv = PC_VOID; }
        else {
          buf_printf(b, "_t%d = ", tr);
          if (ret == TY_POLY && pr != TY_POLY) { emit_boxed_text(c, pr, oc.p, b); pconv = PC_BOX; }
          else if (ret != TY_POLY && pr == TY_POLY) {
            emit_unbox_text(c, is_scalar_ret(ret) ? ret : TY_INT, oc.p, b);
            pconv = PC_UNBOX;
          }
          else buf_puts(b, oc.p);
        }
        buf_puts(b, "; break;");
        free(oc.p);
        done = 1;
        if (g_plan_check) pa_observe(PA_PROC_FORM, PA_KEY_DEFAULT, obj_mi, pr, pconv);
      }
      else if (obj_mi >= 0 && obj_def == obj_cls && c->scopes[obj_mi].nrequired == 0 &&
          scope_has_callable_symbol(c, obj_mi)) {
        /* an optional parameter takes its default, spelled with the
           boxed receiver as self */
        Buf ob; memset(&ob, 0, sizeof ob);
        buf_printf(&ob, "sp_Object_%s(_t%d", mc(c->scopes[obj_mi].name), tv);
        { const char *saved_self = g_self;
          char oselfbuf[32]; snprintf(oselfbuf, sizeof oselfbuf, "_t%d", tv);
          g_self = oselfbuf;
          for (int a = 0; a < c->scopes[obj_mi].nparams; a++) {
            buf_puts(&ob, ", "); emit_arg_or_default(c, &c->scopes[obj_mi], a, -1, &ob);
          }
          g_self = saved_self; }
        emit_trailing_blk_arg(c, &c->scopes[obj_mi], id, (*blk_tmp0), &ob);
        buf_puts(&ob, ")");
        const char *ocall = ob.p;
        buf_puts(b, " default: ");
        int pconv = PC_SAME;
        if (method_is_void(&c->scopes[obj_mi])) { buf_puts(b, ocall); pconv = PC_VOID; }
        else {
          TyKind oslot = is_scalar_ret(ret) ? ret : TY_INT;
          buf_printf(b, "_t%d = ", tr);
          if (ret == TY_POLY && c->scopes[obj_mi].ret != TY_POLY) {
            emit_boxed_text(c, c->scopes[obj_mi].ret, ocall, b);
            pconv = PC_BOX;
          }
          else if (ret != TY_POLY && c->scopes[obj_mi].ret == TY_POLY) {
            emit_unbox_text(c, oslot, ocall, b);
            pconv = PC_UNBOX;
          }
          else buf_puts(b, ocall);
        }
        buf_puts(b, "; break;");
        free(ob.p);
        done = 1;
        if (g_plan_check) pa_observe(PA_USER, PA_KEY_DEFAULT, obj_mi, c->scopes[obj_mi].ret, pconv);
      }
      /* ... and one that needs arguments refuses them for any receiver */
      else { char oexp[600];
        if (obj_def == obj_cls && poly_arm_refuses_none(c, obj_mi, oexp, sizeof oexp)) {
          buf_puts(b, " default: "); emit_poly_arity_raise(b, oexp); buf_puts(b, " break;");
          done = 1;
          if (g_plan_check) pa_observe(PA_ARITY, PA_KEY_DEFAULT, obj_mi, TY_UNKNOWN, PC_VOID);
        } }
    } }
  return done;
}

/* Does class 0 take a `case 0:` arm in a poly dispatch of name with argc
   arguments (kwh, pos_argc, splat_a as poly_arm_count reads them)? The
   dispatch key then keeps a non-object value off it. */
int poly_key_cls0(Compiler *c, const char *name, int argc, int kwh, int pos_argc, int splat_a) {
  if (argc == 0) {
    int cls0_d = -1, cls0_rd = -1;
    int cls0_mi = c->nclasses > 0 ? comp_method_in_chain(c, 0, name, &cls0_d) : -1;
    char cls0_exp[600];
    return ((cls0_mi >= 0 && c->scopes[cls0_mi].nrequired == 0) ||
            /* an arm refusing no arguments raises, and is a `case 0:` all the same */
            poly_arm_refuses_none(c, cls0_mi, cls0_exp, sizeof cls0_exp) ||
            (c->nclasses > 0 && comp_reader_in_chain(c, 0, name, &cls0_rd))) &&
           c->nclasses > 0 &&
           (c->classes[0].instantiated || class_is_prim_reopen(c, 0));
  }
  int cls0_mi2 = c->nclasses > 0 ? comp_method_in_chain(c, 0, name, NULL) : -1;
  int cls0_cand2 = cls0_mi2 >= 0 &&
                   (c->classes[0].instantiated || class_is_prim_reopen(c, 0));
  if (cls0_cand2) {
    /* the same widened arity as the candidate count: a keyword hash
       funds the declared keyword params it names (#4205) */
    /* an arm refusing the count raises, and is a `case 0:` all the same */
    char exp0[600];
    cls0_cand2 = poly_arm_count(c, &c->scopes[cls0_mi2], kwh, pos_argc, splat_a,
                                exp0, sizeof exp0) != 0;
  }
  return cls0_cand2;
}

/* Does a primitive reopening (String, Integer, ...) take an arm in that
   dispatch? The key then maps a runtime tag to its class (#4219). */
int poly_key_prim(Compiler *c, const char *name, int argc, int kwh, int pos_argc, int splat_a) {
  for (int k = 0; k < c->nclasses; k++) {
    if (!class_is_prim_reopen(c, k)) continue;
    int pmi = comp_method_in_chain(c, k, name, NULL);
    char pexp[600];
    if (pmi < 0) continue;
    int fits = argc == 0 ? c->scopes[pmi].nrequired == 0 || poly_arm_refuses_none(c, pmi, pexp, sizeof pexp)
                         : poly_arm_count(c, &c->scopes[pmi], kwh, pos_argc, splat_a, pexp, sizeof pexp) != 0;
    if (fits && (scope_has_callable_symbol(c, pmi) || scope_needs_proc_form(c, pmi))) return 1;
  }
  return 0;
}

/* The tag pre-arms of a zero-argument poly dispatch: the if-chain ahead of
   its cls_id switch, for a builtin value (a String, a Symbol, a class, an
   IO, a container) whose method shares its name with a user class's. Each
   writes `if (<tag test>) <result>; else `. */
void emit_poly_prearms0(Compiler *c, int id, const char *name, const PolySpecials0 *ps, TyKind ret,
                        int tv, int tr, Buf *b) {
  const NodeTable *nt = c->nt;
  int argc = 0;
  int is_lengthlike = ps->lengthlike, is_empty = ps->empty, is_class_named = ps->class_named;
  int is_class_reflect = ps->class_reflect, is_ostruct = ps->ostruct, is_poly_to_a = ps->poly_to_a;
  int is_io_rewind = ps->io_rewind;
  /* When the dispatch result feeds a poly context, tr is sp_RbVal, so the
     length-like answer is boxed */
  const char *bopen = (ret == TY_POLY) ? "sp_box_int(" : "";
  const char *bclose = (ret == TY_POLY) ? ")" : "";
  const char *ebopen = (ret == TY_POLY) ? "sp_box_bool(" : "";
  const char *ebclose = (ret == TY_POLY) ? ")" : "";
  /* string/symbol-tagged poly values answer length/size directly */
  if (is_lengthlike) {
    if (g_plan_check) pa_observe(PA_BUILTIN, PA_KEY_BUILTIN + PB_LEN, -1, TY_UNKNOWN, PC_SAME);
    buf_printf(b, "if (_t%d.tag == SP_TAG_SYM) _t%d = %ssp_str_length(sp_sym_to_s((sp_sym)_t%d.v.i))%s; else ", tv, tr, bopen, tv, bclose);
    buf_printf(b, "if (_t%d.tag == SP_TAG_STR) _t%d = %s(sp_int)sp_str_length(_t%d.v.s)%s; else ", tv, tr, bopen, tv, bclose);
    /* A handle answers File#size through the runtime's own dispatch,
       which knows whether it is a File (fstat) or an IO (CRuby's
       NoMethodError). This chain is built when a user class owns the
       name too, and its default arm raised for the File the same
       program keeps beside those objects in one Hash (#4734). */
    if (sp_streq(name, "size"))
      buf_printf(b, "if (_t%d.tag == SP_TAG_OBJ && _t%d.cls_id == SP_BUILTIN_IO) _t%d = %ssp_poly_size(_t%d)%s; else ",
                 tv, tv, tr, bopen, tv, bclose);
  }
  /* a string/symbol-tagged poly value answers empty? directly (#1438) */
  if (is_empty) {
    if (g_plan_check) pa_observe(PA_BUILTIN, PA_KEY_BUILTIN + PB_EMPTY, -1, TY_UNKNOWN, PC_SAME);
    buf_printf(b, "if (_t%d.tag == SP_TAG_STR) _t%d = %ssp_str_length(_t%d.v.s) == 0%s; else ", tv, tr, ebopen, tv, ebclose);
    buf_printf(b, "if (_t%d.tag == SP_TAG_SYM) _t%d = %sstrlen(sp_sym_to_s((sp_sym)_t%d.v.i)) == 0%s; else ", tv, tr, ebopen, tv, ebclose);
  }
  /* a class-tagged poly value answers its name: `Base.subclasses` and
     `#ancestors` hand back boxed classes, so `.map { |c| c.name }` reaches
     here (#2656). The tag is checked ahead of the cls_id switch, because a
     boxed class carries the CLASS's id and would otherwise alias that
     user class's arm. Declined when a user class defines the method --
     then a user object is the likelier receiver and it must win. */
  if (is_class_named) {
    if (g_plan_check) pa_observe(PA_BUILTIN, PA_KEY_BUILTIN + PB_CLASS_NAMED, -1, TY_UNKNOWN, PC_SAME);
    const char *sbopen = (ret == TY_POLY) ? "sp_box_str(" : "";
    const char *sbclose = (ret == TY_POLY) ? ")" : "";
    /* a boxed class's #name is the interned frozen String the typed
       forms answer (sp_str_frozen_name, which emit_call wraps around
       those), as the Encoding and Symbol arms below intern theirs; its
       to_s and inspect are not frozen */
    int fzn = sp_streq(name, "name");
    buf_printf(b, "if (_t%d.tag == SP_TAG_CLASS) _t%d = %s%ssp_class_val_name(_t%d)%s%s; else ",
               tv, tr, sbopen, fzn ? "sp_str_uminus_val(" : "", tv, fzn ? ")" : "", sbclose);
    /* `name` on an Encoding (always carried boxed) and on a Symbol: a
       frozen String, as CRuby answers and as the typed Symbol#name does */
    if (sp_streq(name, "name"))
      buf_printf(b, "if (_t%d.tag == SP_TAG_ENCODING) _t%d = %ssp_str_uminus_val(_t%d.v.s)%s; "
                    "else if (_t%d.tag == SP_TAG_SYM) "
                    "_t%d = %ssp_str_uminus_val(sp_sym_to_s((sp_sym)_t%d.v.i))%s; else ",
                 tv, tr, sbopen, tv, sbclose, tv, tr, sbopen, tv, sbclose);
  }
  if (is_class_reflect) {
    if (g_plan_check) pa_observe(PA_BUILTIN, PA_KEY_BUILTIN + PB_CLASS_REFLECT, -1, TY_UNKNOWN, PC_SAME);
    /* sp_class_superclass only knows the user chain; a builtin class needs
       sp_builtin_superclass, exactly as the typed arm does. allocate and
       keyword_init? answer a boxed value already. */
    int boxed_ans = sp_streq(name, "allocate") || sp_streq(name, "keyword_init?");
    const char *cbo = (ret == TY_POLY && !boxed_ans)
                        ? (sp_streq(name, "superclass") ? "sp_box_class(" : "sp_box_poly_array(")
                        : "";
    const char *cbc = (ret == TY_POLY && !boxed_ans) ? ")" : "";
    buf_printf(b, "if (_t%d.tag == SP_TAG_CLASS) _t%d = %s", tv, tr, cbo);
    if (sp_streq(name, "ancestors"))
      buf_printf(b, "sp_class_ancestors(sp_unbox_class(_t%d))", tv);
    else if (sp_streq(name, "included_modules"))
      buf_printf(b, "sp_class_included_modules(sp_unbox_class(_t%d))", tv);
    else if (sp_streq(name, "subclasses"))
      buf_printf(b, "sp_cls_subclasses(_t%d)", tv);
    else if (sp_streq(name, "allocate"))
      buf_printf(b, "sp_cls_allocate(_t%d)", tv);
    else if (sp_streq(name, "keyword_init?"))
      buf_printf(b, "sp_cls_keyword_init_p(_t%d)", tv);
    else
      buf_printf(b, "({ sp_Class _cs%d = sp_unbox_class(_t%d); _cs%d.cls_id >= 0 ? sp_class_superclass(_cs%d) : sp_builtin_superclass(_cs%d); })",
                 tv, tv, tv, tv, tv);
    buf_printf(b, "%s; else ", cbc);
  }
  /* an OpenStruct answers ANY reader with its member value; checked ahead of
     the cls_id switch since its id is a builtin, not a user class (#3197). */
  if (is_ostruct) {
    if (g_plan_check) pa_observe(PA_BUILTIN, PA_KEY_BUILTIN + PB_OSTRUCT, -1, TY_UNKNOWN, PC_SAME);
    char osget[192];
    snprintf(osget, sizeof osget,
             "sp_OpenStruct_get((sp_OpenStruct *)_t%d.v.p, sp_sym_intern(\"%s\"))", tv, name);
    buf_printf(b, "if (_t%d.tag == SP_TAG_OBJ && _t%d.cls_id == SP_BUILTIN_OPENSTRUCT) _t%d = ",
               tv, tv, tr);
    if (ret == TY_POLY) buf_puts(b, osget);
    else emit_unbox_text(c, ret, osget, b);   /* result slot is user-typed (#3264) */
    buf_puts(b, "; else ");
  }
  /* to_a on a runtime builtin hash/array: pair-array via the boxed
     converter (#3278) */
  if (is_poly_to_a) {
    if (g_plan_check) pa_observe(PA_BUILTIN, PA_KEY_BUILTIN + PB_TO_A, -1, TY_UNKNOWN, PC_SAME);
    buf_printf(b, "if (_t%d.tag == SP_TAG_OBJ && (sp_poly_is_hash_kind(_t%d.cls_id)"
                  " || sp_poly_is_array_kind(_t%d.cls_id)"
                  " || _t%d.cls_id == SP_BUILTIN_RANGE"
                  " || _t%d.cls_id == SP_BUILTIN_STR_RANGE)) { _t%d = ",
               tv, tv, tv, tv, tv, tr);
    if (ret == TY_POLY) buf_printf(b, "sp_box_poly_array(sp_poly_to_a_arr(_t%d))", tv);
    else buf_printf(b, "sp_poly_to_a_arr(_t%d)", tv);
    buf_puts(b, "; }\nelse ");
    /* an Enumerator materializes through its own reader (#3624) */
    buf_printf(b, "if (_t%d.tag == SP_TAG_OBJ && _t%d.cls_id == SP_BUILTIN_ENUMERATOR) { _t%d = ",
               tv, tv, tr);
    if (ret == TY_POLY)
      buf_printf(b, "sp_box_poly_array(sp_Enumerator_to_a((sp_Enumerator *)_t%d.v.p))", tv);
    else buf_printf(b, "sp_Enumerator_to_a((sp_Enumerator *)_t%d.v.p)", tv);
    buf_puts(b, "; }\nelse ");
  }
  /* rewind on a runtime IO / StringIO stream (#3257); value is the seed
     (rewind's return is rarely consumed through a poly union) */
  if (is_io_rewind) {
    if (g_plan_check) pa_observe(PA_BUILTIN, PA_KEY_BUILTIN + PB_IO_REWIND, -1, TY_UNKNOWN, PC_SAME);
    buf_printf(b, "if (_t%d.tag == SP_TAG_OBJ && _t%d.cls_id == SP_BUILTIN_IO)"
                  " { sp_File_rewind((sp_File *)_t%d.v.p); }\nelse ", tv, tv, tv);
    int sio_cid3 = comp_class_index(c, "StringIO");
    if (sio_cid3 >= 0)
      buf_printf(b, "if (_t%d.tag == SP_TAG_OBJ && _t%d.cls_id == %d)"
                    " { sp_StringIO_rewind((sp_StringIO *)_t%d.v.p); }\nelse ",
                 tv, tv, sio_cid3, tv);
  }
  /* A zero-arg IO method whose name a user class ALSO owns. The cls_id
     switch below carries an arm per user class only, so an `@io` that
     holds a Socket here and a plain object there left the real stream at
     the NoMethodError default (#4341): `def close; @io.close; end` on a
     wrapper reported `close` as undefined for the Socket. Guarded on
     SP_BUILTIN_IO, which no user-class arm can alias, so an object still
     takes its own arm -- the same shape the rewind pre-arm above uses.
     `close` leaves the seed alone: nil is what it answers. */
  if (argc == 0 && nt_ref(nt, id, "block") < 0) {
    /* the readers answer what the typed receiver's arms answer: gets and
       getc a nil-able String (NULL boxes to nil), getbyte an Integer or
       the nil sentinel, readline/readchar/readbyte raise EOFError */
    static const struct { const char *nm, *fn; TyKind rt; const char *tail; } IOZ[] = {
      {"close",   "sp_File_close",    TY_VOID},
      {"closed?", "sp_File_closed_p", TY_BOOL},
      {"eof?",    "sp_File_eof_p",    TY_BOOL},
      {"eof",     "sp_File_eof_p",    TY_BOOL},
      {"tty?",    "sp_File_tty_p",    TY_BOOL},
      {"isatty",  "sp_File_tty_p",    TY_BOOL},
      {"flush",   "sp_File_flush",    TY_VOID},
      {"fileno",  "sp_File_fileno",   TY_INT},
      {"tell",    "sp_File_tell",     TY_INT},
      {"pos",     "sp_File_tell",     TY_INT},
      {"lineno",  "sp_File_lineno",   TY_INT},
      {"sync",    "sp_File_sync_p",   TY_BOOL},
      {"gets",    "sp_File_gets",     TY_STRING},
      {"getc",    "sp_File_getc",     TY_STRING},
      {"readchar", "sp_File_readchar", TY_STRING},
      {"readline", "sp_File_readline_sep", TY_STRING, ", \"\\n\", 0, 0"},
      {"readbyte", "sp_File_readbyte", TY_INT},
      {"getbyte", "sp_File_getbyte",  TY_INT},
      {"readlines", "sp_File_readlines", TY_STR_ARRAY},
      {NULL, NULL, TY_VOID, NULL}
    };
    /* a bare puts writes the newline and answers nil (#6158) */
    if (sp_streq(name, "puts")) {
      if (g_plan_check) pa_observe(PA_BUILTIN, PA_KEY_BUILTIN + PB_IO_PUTS, -1, TY_UNKNOWN, PC_SAME);
      buf_printf(b, "if (_t%d.tag == SP_TAG_OBJ && _t%d.cls_id == SP_BUILTIN_IO) { "
                    "sp_File_puts((sp_File *)_t%d.v.p, \"\"); ", tv, tv, tv);
      if (ret == TY_POLY) buf_printf(b, "_t%d = sp_box_nil(); ", tr);
      buf_puts(b, "}\nelse ");
    }
    for (int i = 0; IOZ[i].nm; i++) {
      if (!sp_streq(name, IOZ[i].nm)) continue;
      if (g_plan_check) pa_observe(PA_BUILTIN, PA_KEY_BUILTIN + PB_IOZ, -1, TY_UNKNOWN, PC_SAME);
      char ioex[128];
      snprintf(ioex, sizeof ioex, "%s((sp_File *)_t%d.v.p%s)", IOZ[i].fn, tv,
               IOZ[i].tail ? IOZ[i].tail : "");
      buf_printf(b, "if (_t%d.tag == SP_TAG_OBJ && _t%d.cls_id == SP_BUILTIN_IO) { ",
                 tv, tv);
      /* the value only lands when the result slot can hold it: poly boxes
         it, an exactly matching concrete slot takes it raw, anything else
         keeps the call for its effect and leaves the seed */
      if (ret == TY_POLY && sp_streq(name, "getbyte"))
        buf_printf(b, "_t%d = sp_box_int_or_nil(%s)", tr, ioex);
      else if (ret == TY_POLY && IOZ[i].rt != TY_VOID) {
        buf_printf(b, "_t%d = ", tr);
        emit_boxed_text(c, IOZ[i].rt, ioex, b);
      }
      else if (ret == IOZ[i].rt && IOZ[i].rt != TY_VOID)
        buf_printf(b, "_t%d = %s", tr, ioex);
      else buf_puts(b, ioex);
      buf_puts(b, "; }\nelse ");
      break;
    }
  }
  /* A zero-arg CONTAINER reduction whose name a user class also owns
     (`TreeNode#sum` next to a real Array's). The switch below covers
     SP_TAG_OBJ user classes only, so an Array receiver fell through to the
     NoMethodError default. Runtime-guarded on the container kinds, so a
     user object still takes its own arm. */
  if (argc == 0 && nt_ref(nt, id, "block") < 0) {
    const char *cfn = sp_streq(name, "sum")   ? "sp_poly_sum"
                    : sp_streq(name, "min")   ? "sp_poly_min"
                    : sp_streq(name, "max")   ? "sp_poly_max"
                    : sp_streq(name, "first") ? "sp_poly_first"
                    : sp_streq(name, "last")  ? "sp_poly_last" : NULL;
    if (cfn) {
      if (g_plan_check) pa_observe(PA_BUILTIN, PA_KEY_BUILTIN + PB_REDUCE, -1, TY_UNKNOWN, PC_SAME);
      char cex[96];
      snprintf(cex, sizeof cex, "%s(_t%d)", cfn, tv);
      /* Time#min is the MINUTE, and sp_poly_min answers it. A boxed Time
         is neither an array nor a hash kind, so without this arm it fell
         past the guard into the user-class switch and raised
         NoMethodError -- the second symptom of #4192, reached only when
         some user class happens to define `min`. A boxed Range is in the
         same position for all five names: the helpers own it (Range#sum
         always did; min/max/first/last since #4192's follow-up), so it
         must not fall into the user switch either. */
      char tg[128];
      int tn = snprintf(tg, sizeof tg, " || _t%d.cls_id == SP_BUILTIN_RANGE", tv);
      if (sp_streq(name, "min"))
        snprintf(tg + tn, sizeof tg - (size_t)tn,
                 " || _t%d.cls_id == SP_BUILTIN_TIME", tv);
      buf_printf(b, "if (_t%d.tag == SP_TAG_OBJ && (sp_poly_is_array_kind(_t%d.cls_id) ||"
                    " sp_poly_is_hash_kind(_t%d.cls_id)%s)) { _t%d = ", tv, tv, tv, tg, tr);
      if (ret == TY_POLY) buf_puts(b, cex);
      else emit_unbox_text(c, ret, cex, b);
      buf_puts(b, "; }\nelse ");
    }
  }
  /* A zero-arg String transform whose name a user class ALSO owns. The
     poly String shortcuts decline to this dispatch so a Struct member or
     attr_reader called `upcase` answers the member rather than the upcased
     #inspect of the object holding it (#3364, #3380) -- but the cls_id
     switch below only covers SP_TAG_OBJ, so a genuine String receiver then
     fell through to the seed (nil, or 0 for #bytes). Same tag pre-arm the
     `[]` and #include? cases above use: String at run time takes the
     String method, an object takes its member. */
  /* ... unless the program REOPENED String with that very name, in which
     case the String arm below (case 0 / the reopen's own method) is the
     answer and this shortcut would take it away: `class String; def
     upcase; "nope"; end` has to reach "nope" for a run-time-typed
     receiver too, the way it now does for a concrete one. */
  int str_reopen_owns = 0;
  { int sci = comp_class_index(c, "String");
    if (sci >= 0 && comp_method_in_chain(c, sci, name, NULL) >= 0) str_reopen_owns = 1; }
  if (argc == 0 && !str_reopen_owns) {
    static const struct { const char *nm, *fn; int arr; } STRT[] = {
      {"upcase","sp_str_upcase",0}, {"downcase","sp_str_downcase",0},
      {"capitalize","sp_str_capitalize",0}, {"swapcase","sp_str_swapcase",0},
      {"strip","sp_str_strip",0}, {"reverse","sp_str_reverse",0},
      {"chomp","sp_str_chomp",0}, {"chop","sp_str_chop",0},
      {"succ","sp_str_succ",0}, {"next","sp_str_succ",0},
      {"chr","sp_str_chr",0},
      {"bytes","sp_str_bytes",1}, {"chars","sp_str_chars",2}, {NULL,NULL,0}
    };
    for (int si = 0; STRT[si].nm; si++) {
      if (!sp_streq(name, STRT[si].nm)) continue;
      /* the result has to fit the slot the dispatch assigns into */
      int ok = STRT[si].arr == 0 ? (ret == TY_POLY || ret == TY_STRING)
             : STRT[si].arr == 1 ? (ret == TY_POLY || ret == TY_INT_ARRAY)
             :                     (ret == TY_POLY || ret == TY_STR_ARRAY);
      if (!ok) break;
      /* #chr is Integer#chr on an int tag: stringifying first turns
         65.chr into "65".chr == "6" (#3328). */
      if (sp_streq(name, "chr")) {
        if (g_plan_check) pa_observe(PA_BUILTIN, PA_KEY_BUILTIN + PB_INT_CHR, -1, TY_UNKNOWN, PC_SAME);
        buf_printf(b, "if (_t%d.tag == SP_TAG_INT) { _t%d = ", tv, tr);
        if (ret == TY_STRING) buf_printf(b, "sp_int_chr(_t%d.v.i)", tv);
        else buf_printf(b, "sp_box_str(sp_int_chr(_t%d.v.i))", tv);
        buf_puts(b, "; }\nelse ");
      }
      if (g_plan_check) pa_observe(PA_BUILTIN, PA_KEY_BUILTIN + PB_STRT, -1, TY_UNKNOWN, PC_SAME);
      buf_printf(b, "if (_t%d.tag == SP_TAG_STR) { _t%d = ", tv, tr);
      if (ret != TY_POLY) buf_printf(b, "%s(_t%d.v.s)", STRT[si].fn, tv);
      else if (STRT[si].arr == 1) buf_printf(b, "sp_box_int_array(%s(_t%d.v.s))", STRT[si].fn, tv);
      else if (STRT[si].arr == 2) buf_printf(b, "sp_box_str_array(%s(_t%d.v.s))", STRT[si].fn, tv);
      else buf_printf(b, "sp_box_str(%s(_t%d.v.s))", STRT[si].fn, tv);
      buf_puts(b, "; }\nelse ");
      break;
    }
    /* #split is the same shape but answers an ARRAY, so it needs the slot
       conversion the table above cannot express: a user class owning
       `split` (Pathname does) turned `str.split.join(" ")` into a switch
       with no String arm, and the NULL that fell out joined to "" (#3394). */
    if (sp_streq(name, "split") &&
        (ret == TY_STR_ARRAY || ret == TY_POLY_ARRAY || ret == TY_POLY)) {
      if (g_plan_check) pa_observe(PA_BUILTIN, PA_KEY_BUILTIN + PB_SPLIT, -1, TY_UNKNOWN, PC_SAME);
      buf_printf(b, "if (_t%d.tag == SP_TAG_STR) { _t%d = ", tv, tr);
      if (ret == TY_STR_ARRAY) buf_printf(b, "sp_str_split_ws(_t%d.v.s)", tv);
      else if (ret == TY_POLY_ARRAY) buf_printf(b, "sp_StrArray_to_poly_fmt(sp_str_split_ws(_t%d.v.s))", tv);
      else buf_printf(b, "sp_box_str_array(sp_str_split_ws(_t%d.v.s))", tv);
      buf_puts(b, "; }\nelse ");
    }
  }
}

/* The rest of a zero-argument poly dispatch's pre-arms, after the tag
   chain (emit_poly_prearms0): the block a candidate takes, hoisted once as
   a proc (its temp is the result), a builtin container or Mutex driving
   that proc, a callable value, a class value's class-side arms. */
int emit_poly_prearms0_blk(Compiler *c, int id, const char *name, const PolySpecials0 *ps, TyKind ret,
                           int tv, int tr, Buf *b) {
  const NodeTable *nt = c->nt;
  int argc = 0;
  /* class 0 emits a `case 0:` arm here when it defines/inherits the method
     (nrequired 0) or exposes it as a reader; the dispatch key is then guarded
     so a boxed scalar (cls_id 0) does not alias it (issue #1576). */
  /* A candidate whose method takes `&blk` needs the call's block passed
     to it. Materialize the proc ONCE, ahead of the switch, and hand the
     same temp to every arm -- only one arm runs, and building it per arm
     would allocate a proc per candidate class (#3399). Mirrors the
     class-method cascade, which already does this. */
  int blk_tmp0 = -1;
  { int cblk0 = resolve_forwarded_block(c, nt_ref(nt, id, "block"));
    if (cblk0 >= 0) {
      int npc0 = 0;
      const PolyCand *pc0 = comp_poly_candidates(c, name, &npc0);   /* (#4966) */
      for (int ki = 0; ki < npc0 && blk_tmp0 < 0; ki++) {
        int k = pc0[ki].cls;
        if (!c->classes[k].instantiated) continue;
        int mi0 = pc0[ki].mi;
        if (mi0 < 0) continue;
        Scope *cm0 = &c->scopes[mi0];
        /* a yielding candidate is reachable through its proc form */
        if (!scope_has_callable_symbol(c, mi0) && !scope_needs_proc_form(c, mi0)) continue;
        if ((cm0->blk_param && cm0->blk_param[0] && !cm0->yields) ||
            scope_needs_proc_form(c, mi0)) {
          /* `&blk` that survived the forwarding resolution names a REAL
             proc (this function's own block param), not a literal to
             materialize: write the proc expression itself. */
          blk_tmp0 = hoist_block_proc(c, cblk0);
        }
      }
    } }
  /* A builtin Array receiver reaching a dispatch that exists only because
     a USER class defines this name. Without an arm it falls to the raise:
     `NoMethodError: undefined method 'map' for an instance of Array` at a
     site where the block-carrying call is plainly Array#map. The builtin
     is normally served by splicing the block inline, which is not
     available here -- the block was materialized once as a proc and shared
     by every arm, and a second spliced copy would disagree with whichever
     arm ran. Drive the same proc over the elements instead (#3409).

     Only reachable at all since a yielding method became dispatchable: a
     non-yielding user `map` leaves a block-carrying call to the builtin
     path entirely, which is why the same shape is correct without the
     yield. */
  { const char *pen_op = argc == 0 && nt_ref(nt, id, "block") >= 0
                       ? poly_enum_op_for(name) : NULL;
    /* A candidate that neither yields nor keeps a real &blk left no proc
       materialized -- it ignores the block. The builtin arm still needs
       one, so build it here; only one arm runs either way. */
    if (pen_op && blk_tmp0 < 0) {
      int cblk1 = resolve_forwarded_block(c, nt_ref(nt, id, "block"));
      if (cblk1 < 0) pen_op = NULL;
      else blk_tmp0 = hoist_block_proc(c, cblk1);
    }
    if (pen_op) {
      if (g_plan_check) pa_observe(PA_BUILTIN, PA_KEY_BUILTIN + PB_ENUM_PROC, -1, TY_UNKNOWN, PC_SAME);
      char pcall[160];
      snprintf(pcall, sizeof pcall, "sp_poly_enum_proc(_t%d, %s, _t%d)", tv, pen_op, blk_tmp0);
      /* an Integer Range walks through the same helper (its length and
         members are known to it); without it a boxed Range fell to the
         user-class switch's NoMethodError (#4840) */
      buf_printf(b, "if (_t%d.tag == SP_TAG_OBJ && (sp_poly_is_array_kind(_t%d.cls_id) || sp_poly_is_hash_kind(_t%d.cls_id) || _t%d.cls_id == SP_BUILTIN_RANGE || _t%d.cls_id == SP_BUILTIN_ENUMERATOR)) { _t%d = ", tv, tv, tv, tv, tv, tr);
      if (ret == TY_POLY) buf_puts(b, pcall);
      else emit_unbox_text(c, ret, pcall, b);
      buf_puts(b, "; }\nelse ");
    } }
  /* A boxed Mutex reaching a dispatch that exists because a user class
     also defines `synchronize`: without an arm the Mutex fell to the
     raise. The static arm (the lock/ensure shape in the synchronize
     emitter) cannot serve it here, the block being a materialized proc
     shared by every arm, so the runtime arm locks around the proc. */
  if (sp_streq(name, "synchronize") && argc == 0 && nt_ref(nt, id, "block") >= 0) {
    if (blk_tmp0 < 0) {
      int cblk2 = resolve_forwarded_block(c, nt_ref(nt, id, "block"));
      if (cblk2 >= 0) blk_tmp0 = hoist_block_proc(c, cblk2);
    }
    if (blk_tmp0 >= 0) {
      if (g_plan_check) pa_observe(PA_BUILTIN, PA_KEY_BUILTIN + PB_SYNC, -1, TY_UNKNOWN, PC_SAME);
      char mcall[96];
      snprintf(mcall, sizeof mcall, "sp_Mutex_synchronize_proc((sp_mutex *)_t%d.v.p, _t%d)", tv, blk_tmp0);
      buf_printf(b, "if (_t%d.tag == SP_TAG_OBJ && _t%d.cls_id == SP_BUILTIN_MUTEX) { _t%d = ", tv, tv, tr);
      if (ret == TY_POLY) buf_puts(b, mcall);
      else emit_unbox_text(c, ret, mcall, b);
      buf_puts(b, "; }\nelse ");
    }
  }
  /* a boxed Proc/Curry/Method in a slot a user `call`/`[]` shadows (#4395) */
  if (emit_poly_callable_prearm(c, name, 0, NULL, NULL, NULL, tv, tr, ret, 0, b) && g_plan_check)
    pa_observe(PA_BUILTIN, PA_KEY_BUILTIN + PB_CALLABLE, -1, TY_UNKNOWN, PC_SAME);
  /* a class-valued receiver dispatches class-side, ahead of the instance
     arms (#4218) */
  if (!emit_poly_cls_value_prearm(c, id, name, 0, NULL, NULL, NULL, NULL, tv, tr, ret, blk_tmp0, b) &&
      ps->cls_members) {
    if (g_plan_check) pa_observe(PA_BUILTIN, PA_KEY_BUILTIN + PB_CLS_MEMBERS, -1, TY_UNKNOWN, PC_SAME);
    if (ret == TY_POLY || ret == TY_POLY_ARRAY)
      buf_printf(b, "if (_t%d.tag == SP_TAG_CLASS) _t%d = %ssp_cls_members(_t%d)%s; else ",
                 tv, tr, ret == TY_POLY ? "sp_box_poly_array(" : "", tv, ret == TY_POLY ? ")" : "");
    else
      buf_printf(b, "if (_t%d.tag == SP_TAG_CLASS) sp_raise_nomethod(sp_nomethod_msg(\"members\", _t%d)); else ",
                 tv, tv);
  }
  return blk_tmp0;
}
