/* call_plan.c -- the user method a call binds, resolved from the tables
   (see call_plan.h). */

#include <assert.h>
#include "codegen_internal.h"
#include "analyze_internal.h"
#include "call_plan.h"

static CallPlan *g_cp_memo = NULL;
static unsigned char *g_cp_have = NULL;
static int g_cp_cap = 0;
/* the name each memo entry was resolved under (a copy: a rename frees the
   node's string). A node codegen renames for a re-entry (Array#slice emitted
   as #[]) is resolved fresh, and not kept, while its name is not the memo's */
static char **g_cp_name = NULL;

/* a descendant of cid with its own `name`: the dispatch is a switch */
static int cplan_overridden(Compiler *c, int cid, const char *name, int cmeth) {
  int nd = 0;
  const int *ds = comp_descendants(c, cid, &nd);
  for (int i = 0; i < nd; i++) {
    int k = ds[i];
    if (k == cid) continue;
    if ((cmeth ? comp_cmethod_in_class(c, k, name) : comp_method_in_class(c, k, name)) >= 0)
      return 1;
  }
  return 0;
}

int cplan_dispatch_form(Compiler *c, int cid, const char *name, int has_base) {
  if (cid < 0 || !name) return has_base ? CP_DIRECT : CP_NONE;
  int n = dispatch_impl_count(c, cid, name);
  if (!(n > 1 || (!has_base && n >= 1))) return has_base ? CP_DIRECT : CP_NONE;
  return dispatch_arms_disagree(c, cid, name) ? CP_PER_ARM : CP_SWITCH;
}

static void cplan_set(CallPlan *p, int mi, int owner, int via, int dispatch) {
  p->mi = mi; p->owner_ci = (short)owner;
  p->via = (unsigned char)via; p->dispatch = (unsigned char)dispatch;
  p->by_name = 0;
  p->chain = 0;
}

/* the class a builtin receiver kind is reopened as, or NULL */
static const char *cplan_reopen_class(TyKind rt) {
  switch (rt) {
  case TY_STRING: return "String";
  case TY_INT:    return "Integer";
  case TY_FLOAT:  return "Float";
  case TY_SYMBOL: return "Symbol";
  case TY_RANGE:  return "Range";
  case TY_TIME:   return "Time";
  case TY_THREAD: return "Thread";
  case TY_FIBER:  return "Fiber";
  case TY_CLASS:  return "Class";
  case TY_BOOL:   return "TrueClass";
  default:        return NULL;
  }
}

/* a program's own Object method, for a name Object's builtin surface does
   not answer itself */
static void cplan_object_reopen(Compiler *c, const char *name, CallPlan *p) {
  if (builtin_object_method_known(name)) return;
  int oci = comp_class_index(c, "Object");
  int omi = oci >= 0 ? comp_method_in_chain(c, oci, name, NULL) : -1;
  if (omi >= 0) cplan_set(p, omi, oci, UC_REOPEN, CP_DIRECT);
}

/* the reopenings of builtin exception classes that define name: the first
   stands for them, picked among at run time by the class name */
static void cplan_exc_reopen(Compiler *c, const char *name, CallPlan *p) {
  int xr[8];
  int xn = exc_reopen_definers(c, name, xr, 8);
  if (xn <= 0) return;
  int mi = comp_method_in_chain(c, xr[0], name, NULL);
  if (mi >= 0) cplan_set(p, mi, xr[0], UC_REOPEN, xn > 1 ? CP_SWITCH : CP_DIRECT);
}

static void cplan_resolve_super(Compiler *c, int id, CallPlan *p) {
  Scope *s = comp_scope_of(c, id);
  if (!s || s->class_id < 0 || !s->name) return;
  const char *shadow = comp_super_shadow(c, s);
  if (shadow) {
    int mi = s->is_cmethod ? comp_cmethod_in_class(c, s->class_id, shadow)
                           : comp_method_in_class(c, s->class_id, shadow);
    if (mi >= 0) cplan_set(p, mi, s->class_id, UC_SUPER, CP_DIRECT);
    return;
  }
  int par = comp_super_parent(c, s->class_id, s->is_cmethod);
  if (par < 0) return;
  const char *uname = comp_super_name(c, par, s->name, s->is_cmethod);
  if (!uname) return;
  int mi = s->is_cmethod ? comp_cmethod_in_chain(c, par, uname, NULL)
                         : comp_method_in_chain(c, par, uname, NULL);
  if (mi >= 0) cplan_set(p, mi, par, UC_SUPER, CP_DIRECT);
}

static void cplan_resolve_call(Compiler *c, int id, CallPlan *p) {
  const NodeTable *nt = c->nt;
  const char *name = nt_str(nt, id, "name");
  if (!name) return;
  int recv = nt_ref(nt, id, "receiver");
  /* a singleton accessor folding to one constant: that class's method */
  if (recv >= 0) {
    int fold_ci = comp_sg_reader_const(c, recv);
    int fmi = fold_ci >= 0 ? comp_cmethod_in_chain(c, fold_ci, name, NULL) : -1;
    if (fmi >= 0) { cplan_set(p, fmi, fold_ci, UC_CMETH, CP_DIRECT); return; }
  }
  /* a retargeted `x.send(:m)` reaching a top-level def the receiver does
     not own itself */
  if (recv >= 0 && nt_str(nt, id, "send_blind") && nt_ref(nt, id, "block") < 0) {
    int smi = comp_method_index(c, name);
    if (smi >= 0 && !c->scopes[smi].yields) {
      if (!send_blind_recv_owns(c, recv, comp_ntype(c, recv), name)) {
        cplan_set(p, smi, -1, UC_SEND_BLIND, CP_DIRECT);
        return;
      }
    }
  }
  if (recv < 0) {
    /* inside an instance_eval/exec block self is the rebound receiver */
    int iec = ie_class_of(c, id);
    if (iec >= 0) {
      int imi = comp_method_in_chain(c, iec, name, NULL);
      if (imi >= 0) { cplan_set(p, imi, iec, UC_IE, CP_DIRECT); return; }
    }
    /* ...or one of several, by the receiver's runtime class */
    int pk[64], npk = ie_poly_classes_at(c, id, pk, 64);
    for (int i = 0; i < npk; i++) {
      int imi = comp_method_in_chain(c, pk[i], name, NULL);
      if (imi >= 0) { cplan_set(p, imi, pk[i], UC_IE, CP_SWITCH); return; }
    }
    int cb = comp_cbody_call_mi(c, id, name);
    if (cb >= 0) { cplan_set(p, cb, c->node_cbody[id], UC_CMETH, CP_DIRECT); return; }
    int mi = comp_self_call_mi(c, id, name);
    if (mi >= 0) {
      Scope *m = &c->scopes[mi];
      if (m->class_id < 0) { cplan_set(p, mi, -1, UC_TOP, CP_DIRECT); return; }
      Scope *self = comp_scope_of(c, id);
      int scls = self ? self->class_id : m->class_id;
      int form = m->is_cmethod ? (scls >= 0 && cplan_overridden(c, scls, name, 1) ? CP_SWITCH : CP_DIRECT)
               : scls >= 0 ? cplan_dispatch_form(c, scls, name, 1) : CP_DIRECT;
      cplan_set(p, mi, scls, m->is_cmethod ? UC_CMETH : UC_INST, form);
      /* an instance method comp_self_call_mi took from the self class's chain */
      p->chain = !m->is_cmethod && self && self->class_id >= 0;
      return;
    }
    int imi = comp_included_method_index(c, name, id);
    if (imi >= 0) { cplan_set(p, imi, c->scopes[imi].class_id, UC_INCLUDED, CP_DIRECT); return; }
    /* outside a class method, self reaches a program's own Object method */
    Scope *self = comp_scope_of(c, id);
    if (!(self && self->is_cmethod)) cplan_object_reopen(c, name, p);
    return;
  }
  const char *rty = nt_type(nt, recv);
  TyKind rt = comp_ntype(c, recv);
  /* a Class reopen's own method answers a class value first, as the
     inference arm for Range / Time / IO / Class receivers does */
  if (rt == TY_CLASS && !nt_int(nt, id, "builtin_only", 0)) {
    int kci = comp_class_index(c, "Class");
    int kmi = kci >= 0 ? comp_method_in_chain(c, kci, name, NULL) : -1;
    if (kmi >= 0) { cplan_set(p, kmi, kci, UC_REOPEN, CP_DIRECT); return; }
  }
  int sci = self_class_static_ci(c, recv);   /* `self.class` naming one class */
  if (sci >= 0 || (rty && (sp_streq(rty, "ConstantReadNode") || sp_streq(rty, "ConstantPathNode")))) {
    int ci = sci >= 0 ? sci : comp_class_index(c, nt_str(nt, recv, "name"));
    int mi = ci >= 0 ? comp_cmethod_in_chain(c, ci, name, NULL) : -1;
    if (mi >= 0) { cplan_set(p, mi, ci, UC_CMETH, CP_DIRECT); return; }
    /* a method the program adds to Class, on a builtin class constant */
    int rmi = class_reopen_cmethod(c, recv, name);
    if (rmi >= 0) { cplan_set(p, rmi, c->scopes[rmi].class_id, UC_CMETH, CP_DIRECT); return; }
    /* a constant holding an instance is read by its type below */
  }
  /* a class held in a variable: a switch over every class with a class
     method of the name */
  else if (rt == TY_CLASS) {
    int ncc = 0;
    const PolyCand *ccs = comp_cmethod_candidates(c, name, &ncc);
    for (int i = 0; i < ncc; i++)
      if (ccs[i].mi >= 0) {
        cplan_set(p, ccs[i].mi, ccs[i].cls, UC_CMETH, CP_SWITCH);
        p->by_name = 1;
        return;
      }
  }
  if (ty_is_object(rt)) {
    int cid = ty_object_class(rt);
    int mi = comp_method_in_chain(c, cid, name, NULL);
    if (mi >= 0) {
      cplan_set(p, mi, cid, UC_INST, cplan_dispatch_form(c, cid, name, 1));
      p->chain = 1;
      return;
    }
    /* the operators an object answers through another of its methods:
       `!=` through `==`, the comparisons through `<=>` */
    const char *via_op = sp_streq(name, "!=") ? "==" :
                         (sp_streq(name, "<") || sp_streq(name, "<=") || sp_streq(name, ">") ||
                          sp_streq(name, ">=") || sp_streq(name, "between?") ||
                          sp_streq(name, "clamp")) ? "<=>" : NULL;
    int dmi = via_op ? comp_method_in_chain(c, cid, via_op, NULL) : -1;
    if (dmi >= 0) {
      cplan_set(p, dmi, cid, UC_INST, cplan_dispatch_form(c, cid, via_op, 1));
      return;
    }
    /* a reader a subclass overrides with a method: the switch reaches the
       override for that subclass */
    if (comp_reader_in_chain(c, cid, name, NULL)) {
      int nd = 0;
      const int *ds = comp_descendants(c, cid, &nd);
      for (int i = 0; i < nd; i++) {
        int kmi = ds[i] != cid ? comp_method_in_class(c, ds[i], name) : -1;
        if (kmi >= 0) { cplan_set(p, kmi, cid, UC_INST, CP_SWITCH); return; }
      }
    }
    if (class_is_exc_subclass(c, cid)) cplan_exc_reopen(c, name, p);
    if (p->mi < 0) cplan_object_reopen(c, name, p);
    return;
  }
  if (rt == TY_POLY) {
    int npc = 0;
    const PolyCand *pcs = comp_poly_candidates(c, name, &npc);
    for (int i = 0; i < npc; i++) {
      if (c->classes[pcs[i].cls].is_native_class) continue;
      int pmi = pcs[i].mi >= 0 ? pcs[i].mi : comp_method_in_chain(c, pcs[i].cls, name, NULL);
      if (pmi >= 0) { cplan_set(p, pmi, pcs[i].cls, UC_POLY, CP_SWITCH); return; }
    }
    /* a boxed class value: the dispatch's class-method arms */
    int ncc = 0;
    const PolyCand *ccs = comp_cmethod_candidates(c, name, &ncc);
    for (int i = 0; i < ncc; i++)
      if (ccs[i].mi >= 0) { cplan_set(p, ccs[i].mi, ccs[i].cls, UC_POLY, CP_SWITCH); return; }
    return;
  }
  if (rt == TY_EXCEPTION) { cplan_exc_reopen(c, name, p); return; }
  if (nt_int(nt, id, "builtin_only", 0)) return;
  /* an IO handle's reopen: the File, IO or socket class that defines it */
  if (rt == TY_IO) {
    int eci = io_reopen_class(c, name);
    int emi = eci >= 0 ? comp_method_in_chain(c, eci, name, NULL) : -1;
    if (emi >= 0) { cplan_set(p, emi, eci, UC_REOPEN, CP_DIRECT); return; }
  }
  const char *rc = cplan_reopen_class(rt);
  if (rc) {
    int ci = comp_class_index(c, rc);
    int mi = ci >= 0 ? comp_method_in_chain(c, ci, name, NULL) : -1;
    if (mi >= 0) { cplan_set(p, mi, ci, UC_REOPEN, CP_DIRECT); return; }
  }
  /* a nil receiver's NilClass reopen, an Integer or Float receiver's
     Numeric reopen (the inference rule beside the scalar reopens) */
  if (rt == TY_NIL || rt == TY_INT || rt == TY_FLOAT || rt == TY_BIGINT) {
    const char *own = rt == TY_NIL ? "NilClass" : rt == TY_FLOAT ? "Float" : "Integer";
    const char *anc = rt == TY_NIL ? "NilClass" : "Numeric";
    if (!builtin_method_known(own, name) && !builtin_object_method_known(name)) {
      int aci = comp_class_index(c, anc);
      int ami = aci >= 0 ? comp_method_in_chain(c, aci, name, NULL) : -1;
      if (ami >= 0 && c->scopes[ami].class_id == aci) { cplan_set(p, ami, aci, UC_REOPEN, CP_DIRECT); return; }
    }
  }
  /* an Array or Hash reopen's own method of the name */
  if ((ty_is_array(rt) || ty_is_obj_array(rt) || ty_is_hash(rt)) && nt_ref(nt, id, "block") < 0) {
    int aci = comp_class_index(c, ty_is_hash(rt) ? "Hash" : "Array");
    int adc = -1, ami = aci >= 0 ? comp_method_in_chain(c, aci, name, &adc) : -1;
    if (ami >= 0 && adc == aci && c->scopes[ami].name && sp_streq(c->scopes[ami].name, name)) {
      cplan_set(p, ami, aci, UC_REOPEN, CP_DIRECT);
      return;
    }
  }
  /* last, a program's own Object method for a name the receiver's builtin
     class and Object's own surface do not have (object_reopen_answers) */
  const char *bcls = builtin_class_of_type(rt);
  if (bcls && !builtin_method_known(bcls, name)) cplan_object_reopen(c, name, p);
}

static void cplan_resolve(Compiler *c, int id, CallPlan *p) {
  cplan_set(p, -1, -1, UC_NONE, CP_NONE);
  NodeKind k = nt_kind(c->nt, id);
  if (k == NK_SuperNode || k == NK_ForwardingSuperNode) cplan_resolve_super(c, id, p);
  else if (k == NK_CallNode) cplan_resolve_call(c, id, p);
}

int cplan_virtual_member(Compiler *c, int id, const CallPlan *p, int mi) {
  if (p->mi < 0 || mi < 0) return 0;
  if (p->mi == mi) return 1;
  if (p->dispatch < CP_SWITCH) return 0;
  const char *name = nt_str(c->nt, id, "name");
  if (!name) return 0;
  if (p->by_name) {
    int ncc = 0;
    const PolyCand *ccs = comp_cmethod_candidates(c, name, &ncc);
    for (int i = 0; i < ncc; i++)
      if (ccs[i].mi == mi) return 1;
    return 0;
  }
  if (p->via == UC_POLY) {
    int npc = 0;
    const PolyCand *pcs = comp_poly_candidates(c, name, &npc);
    for (int i = 0; i < npc; i++)
      if (pcs[i].mi == mi || (pcs[i].mi < 0 && comp_method_in_chain(c, pcs[i].cls, name, NULL) == mi))
        return 1;
    int ncc = 0;
    const PolyCand *ccs = comp_cmethod_candidates(c, name, &ncc);
    for (int i = 0; i < ncc; i++)
      if (ccs[i].mi == mi) return 1;
    return 0;
  }
  if (p->via == UC_REOPEN) {
    int xr[8], xn = exc_reopen_definers(c, name, xr, 8);
    for (int i = 0; i < xn; i++)
      if (comp_method_in_chain(c, xr[i], name, NULL) == mi) return 1;
    return 0;
  }
  if (p->via == UC_IE) {
    int pk[64], npk = ie_poly_classes_at(c, id, pk, 64);
    for (int i = 0; i < npk; i++)
      if (comp_method_in_chain(c, pk[i], name, NULL) == mi) return 1;
    return 0;
  }
  /* an override in a descendant of the class the chain was searched from */
  int cmeth = c->scopes[p->mi].is_cmethod;
  int nd = 0;
  const int *ds = p->owner_ci >= 0 ? comp_descendants(c, p->owner_ci, &nd) : NULL;
  for (int i = 0; i < nd; i++)
    if ((cmeth ? comp_cmethod_in_class(c, ds[i], name) : comp_method_in_class(c, ds[i], name)) == mi)
      return 1;
  return 0;
}

static const char *g_cp_site[16];
static int g_cp_site_n[16];
static int g_cp_nsites;

void cplan_served(const char *site) {
  for (int i = 0; i < g_cp_nsites; i++)
    if (g_cp_site[i] == site || sp_streq(g_cp_site[i], site)) { g_cp_site_n[i]++; return; }
  if (g_cp_nsites < 16) { g_cp_site[g_cp_nsites] = site; g_cp_site_n[g_cp_nsites++] = 1; }
}

void cplan_served_report(void) {
  for (int i = 0; i < g_cp_nsites; i++)
    fprintf(stderr, "plan-check: cplan-served: %s %d\n", g_cp_site[i], g_cp_site_n[i]);
}

/* the node is read as itself: nothing re-types or re-scopes it */
static int cplan_plain_ctx(void) {
  return view_depth() == 0 && comp_scope_move_depth() == 0 && g_ie_class_id < 0 &&
         inline_splice_depth() == 0;
}

const CallPlan *cplan_user_in(Compiler *c, int id, int self_ci, int flags) {
  static CallPlan ctx;
  if (self_ci < 0) return cplan_user(c, id);
  cplan_set(&ctx, -1, -1, UC_NONE, CP_NONE);
  if (id < 0 || id >= c->node_cap || self_ci >= c->nclasses || nt_kind(c->nt, id) != NK_CallNode)
    return &ctx;
  const char *name = nt_str(c->nt, id, "name");
  int mi = name ? comp_method_in_chain(c, self_ci, name, NULL) : -1;
  if (mi >= 0) {
    cplan_set(&ctx, mi, self_ci, UC_INST, cplan_dispatch_form(c, self_ci, name, 1));
    ctx.chain = 1;
    return &ctx;
  }
  /* a miss is no method, but a dispatch on the class still has a form: a
     method only descendants define takes the switch */
  if (!(flags & CPX_IE) && name) {
    cplan_set(&ctx, -1, self_ci, UC_INST, cplan_dispatch_form(c, self_ci, name, 0));
    ctx.chain = 1;
    return &ctx;
  }
  if (flags & CPX_IE) {
#ifndef NDEBUG
    int tmp0 = g_tmp;
#endif
    cplan_resolve(c, id, &ctx);
#ifndef NDEBUG
    assert(g_tmp == tmp0);
#endif
  }
  return &ctx;
}

const CallPlan *cplan_user(Compiler *c, int id) {
  static CallPlan fresh;
  if (id < 0 || id >= c->node_cap) { cplan_set(&fresh, -1, -1, UC_NONE, CP_NONE); return &fresh; }
  int plain = cplan_plain_ctx();
  const char *nm = nt_str(c->nt, id, "name");
  if (plain && id < g_cp_cap && g_cp_have[id]) {
    const char *mn = g_cp_name[id];
    if (mn ? nm && sp_streq(mn, nm) : !nm) return &g_cp_memo[id];
    plain = 0;
  }
#ifndef NDEBUG
  int tmp0 = g_tmp;
#endif
  cplan_resolve(c, id, &fresh);
#ifndef NDEBUG
  assert(g_tmp == tmp0);   /* resolving emits nothing */
#endif
  if (!plain) return &fresh;
  if (id >= g_cp_cap) {
    int ncap = g_cp_cap ? g_cp_cap : 1024;
    while (ncap <= id) ncap *= 2;
    g_cp_memo = realloc(g_cp_memo, (size_t)ncap * sizeof *g_cp_memo);
    g_cp_have = realloc(g_cp_have, (size_t)ncap);
    g_cp_name = realloc(g_cp_name, (size_t)ncap * sizeof *g_cp_name);
    memset(g_cp_have + g_cp_cap, 0, (size_t)(ncap - g_cp_cap));
    memset(g_cp_name + g_cp_cap, 0, (size_t)(ncap - g_cp_cap) * sizeof *g_cp_name);
    g_cp_cap = ncap;
  }
  g_cp_memo[id] = fresh;
  free(g_cp_name[id]);
  g_cp_name[id] = nm ? strdup(nm) : NULL;
  g_cp_have[id] = 1;
  return &g_cp_memo[id];
}

/* ---- CP_POLY ---- */

static void cpoly_family(PolyPlan *p, int *cap, int fam);
static void cpoly_trial(PolyPlan *p, int *cap, int t);
static int cpoly_has_family(const PolyPlan *p, int fam);
static int cpoly_str_trial(Compiler *c, int id, const char *name, int argc, const int *argv,
                           const TyKind *atmp_ty, TyKind ret, const PolyPlan *p);
static int cpoly_cls_value_arms(Compiler *c, int id, const char *name, int argc, const PolyArgs *A,
                                TyKind ret, int has_tr, PolyPlan *p, int *cap);

static PolyConv cpoly_conv(TyKind ret, TyKind vty) {
  if (ret == TY_POLY && vty != TY_POLY) return PC_BOX;
  if (ret != TY_POLY && vty == TY_POLY) return PC_UNBOX;
  return PC_SAME;
}

static void cpoly_add(PolyPlan *p, int *cap, int kind, int key, int mi, TyKind vty, int conv) {
  if (p->n == *cap) {
    *cap = *cap ? *cap * 2 : 8;
    p->arm = realloc(p->arm, (size_t)*cap * sizeof *p->arm);
  }
  PolyArm *a = &p->arm[p->n++];
  a->kind = (unsigned char)kind; a->key = (short)key; a->mi = mi;
  a->vty = (unsigned char)vty; a->conv = (unsigned char)conv; a->def = -1;
}

/* The classes a dispatch of name can take an arm for, ascending: the ones
   whose chain has the method or a reader, and the native ones (the
   memoized candidates); every class while an exception reopening can lend
   its method to a class outside them. Into ks (sized nclasses). */
static int cpoly_arm_classes(Compiler *c, const char *name, int *ks) {
  int n = 0;
  if (any_exc_reopen(c)) {
    for (int k = 0; k < c->nclasses; k++) ks[n++] = k;
    return n;
  }
  int npc = 0;
  const PolyCand *pcs = comp_poly_candidates(c, name, &npc);
  for (int i = 0; i < npc; i++) ks[n++] = pcs[i].cls;
  return n;
}

/* The arms emit_poly_user_arms0 writes, class by class, in its order. */
static void cpoly_user_arms0(Compiler *c, int id, const char *name, TyKind ret, PolyPlan *p) {
  int cap = 0;
  int *ks = malloc(sizeof(int) * (size_t)(c->nclasses > 0 ? c->nclasses : 1));
  int nks = cpoly_arm_classes(c, name, ks);
  for (int ki = 0; ki < nks; ki++) {
    int k = ks[ki];
    if (!c->classes[k].instantiated && !class_is_prim_reopen(c, k)) continue;
    if (c->classes[k].is_native_class) {
      int nmi = comp_native_method_find(c, k, name, 0, 0);
      if (nmi >= 0 && native_takes(&c->native_methods[nmi], 0)) {
        TyKind mret = native_spec_to_ty(c->native_methods[nmi].ret);
        cpoly_add(p, &cap, PA_NATIVE, k, -1, mret, mret == TY_NIL ? PC_VOID : cpoly_conv(ret, mret));
      }
      else if (nmi >= 0 && c->native_methods[nmi].nargs > 0 && c->classes[k].instantiated)
        cpoly_add(p, &cap, PA_ARITY, k, -1, TY_UNKNOWN, PC_VOID);
      continue;
    }
    int defcls = -1;
    int mi = comp_method_in_chain(c, k, name, &defcls);
    if (mi < 0 && any_exc_reopen(c) && (class_has_exc_name(c, k) || class_is_exc_subclass(c, k))) {
      int xd = exc_arm_definer(c, k, name);
      if (xd >= 0) { defcls = xd; mi = comp_method_in_chain(c, xd, name, NULL); }
    }
    if (mi >= 0 && c->classes[k].is_struct && !c->classes[k].is_data && g_gen_obj_struct_values &&
        ret == TY_POLY && nt_ref(c->nt, id, "block") < 0 &&
        nt_str(c->nt, c->scopes[mi].def_node, "synth") &&
        (sp_streq(name, "each") || sp_streq(name, "each_pair"))) {
      cpoly_add(p, &cap, PA_SYNTH_ENUM, k, mi, TY_ENUMERATOR, PC_SAME);
      continue;
    }
    { char zexp[600]; int rdc0 = -1;
      if (poly_arm_refuses_none(c, mi, zexp, sizeof zexp) && !comp_reader_in_chain(c, k, name, &rdc0)) {
        cpoly_add(p, &cap, PA_ARITY, k, mi, TY_UNKNOWN, PC_VOID);
        continue;
      } }
    if (mi >= 0 && c->scopes[mi].nrequired == 0 &&
        (scope_has_callable_symbol(c, mi) || scope_needs_proc_form(c, mi)) &&
        !(c->classes[defcls].name && sp_streq(c->classes[defcls].name, "Class"))) {
      int pfi = scope_proc_form_of(c, mi);
      Scope *ms = &c->scopes[pfi >= 0 ? pfi : mi];
      TyKind cret = ms->ret;
      int conv;
      if (method_is_void(ms)) conv = PC_VOID;
      else {
        TyKind slotty = is_scalar_ret(ret) ? ret : TY_INT;
        conv = cpoly_conv(ret, cret);
        if (conv == PC_SAME && cret == TY_BIGINT && (slotty == TY_INT || slotty == TY_FLOAT)) conv = PC_NUM;
      }
      cpoly_add(p, &cap, pfi >= 0 ? PA_PROC_FORM : PA_USER, k, mi, cret, conv);
      p->arm[p->n - 1].def = (short)defcls;
      continue;
    }
    int rdcls = -1;
    if (comp_reader_in_chain(c, k, name, &rdcls)) {
      const char *rn = comp_resolve_alias(c, k, name);
      char ivn[256]; snprintf(ivn, sizeof ivn, "@%s", rn);
      int ivx = comp_ivar_index(&c->classes[rdcls], ivn);
      TyKind ivt = ivx >= 0 ? c->classes[rdcls].ivar_types[ivx] : TY_INT;
      int conv = ret == TY_POLY && ivt == TY_INT ? PC_BOX_OR_NIL
               : ivt == TY_STRBUF && ret == TY_STRING && cpoly_conv(ret, ivt) == PC_SAME ? PC_COPY
               : cpoly_conv(ret, ivt);
      cpoly_add(p, &cap, PA_READER, k, -1, ivt, conv);
      p->arm[p->n - 1].def = (short)rdcls;
    }
  }
  free(ks);
}

static int cpoly_native_conv(TyKind mret, TyKind ret, int is_setter_val) {
  if (mret == TY_NIL || is_setter_val) return PC_VOID;
  return cpoly_conv(ret, mret);
}

/* Can user arm `ks` take the call's argument types (arm_key_incompat in
   emit_poly_method_dispatch)? */
int cplan_arm_args_fit(Compiler *c, Scope *ks, const ArgLayout *L, int pos_argc,
                              const TyKind *atmp_ty, int kwall_any) {
  for (int a = 0; a < ks->nparams; a++) {
    if (L->from[a] != ARG_NODE || L->arg[a] >= pos_argc) continue;
    LocalVar *pv0 = (ks->pnames && ks->pnames[a]) ? scope_local(ks, ks->pnames[a]) : NULL;
    TyKind pt0 = pv0 ? pv0->type : TY_UNKNOWN;
    TyKind at0 = atmp_ty[L->arg[a]];
    if (pt0 == TY_STRBUF && pv0->str_shared && (at0 == TY_STRING || at0 == TY_STRBUF)) continue;
    int pc = pt0 != TY_POLY && pt0 != TY_UNKNOWN && pt0 != TY_NIL && pt0 != TY_VOID;
    int ac = at0 != TY_POLY && at0 != TY_UNKNOWN && at0 != TY_NIL && at0 != TY_VOID;
    if (pc && ac && pt0 != at0 &&
        (pt0 == TY_STRING || at0 == TY_STRING || needs_root(pt0) != needs_root(at0) ||
         ty_is_object(pt0) != ty_is_object(at0) ||
         (ty_is_object(pt0) && ty_is_object(at0) &&
          obj_class_unrelated(c, ty_object_class(pt0), ty_object_class(at0))) ||
         ty_is_struct_valued(pt0) || ty_is_struct_valued(at0) ||
         (ty_is_hash(pt0) && ty_is_hash(at0)) || (ty_is_array(pt0) && ty_is_array(at0))))
      return 0;
  }
  int kslot = L->kwh_slot;
  if (kslot >= 0 && L->from[kslot] != ARG_BY_NAME && ks->pnames && ks->pnames[kslot]) {
    LocalVar *kpv = scope_local(ks, ks->pnames[kslot]);
    TyKind kpt = kpv ? kpv->type : TY_UNKNOWN;
    if (ty_is_hash(kpt) && kpt != (kwall_any ? TY_POLY_POLY_HASH : TY_SYM_POLY_HASH)) return 0;
  }
  return 1;
}

/* The builtin cases emit_poly_cases_n writes after the class arms of a
   dispatch with arguments. */
static void cpoly_cases_n(Compiler *c, int id, const char *name, int argc, const int *argv, TyKind ret,
                          const TyKind *atmp_ty, const PolySpecialsN *ps, int splat_a, PolyPlan *p, int *cap) {
  int kwh = ps->kwh, plain = kwh < 0 && splat_a < 0;
  if (ps->index) cpoly_family(p, cap, PB_INDEX_CASES);
  if (sp_streq(name, "read_nonblock") && ps->pos_argc == 1 && splat_a < 0) cpoly_family(p, cap, PB_IO_READ_NB);
  if (sp_streq(name, "write") && argc == 1 && plain) cpoly_family(p, cap, PB_IO_WRITE);
  if (sp_streq(name, "syswrite") && argc == 1 && plain) cpoly_family(p, cap, PB_IO_SYSWRITE);
  if ((sp_streq(name, "puts") || sp_streq(name, "print")) && plain) cpoly_family(p, cap, PB_IO_PRINT);
  if (sp_streq(name, "putc") && argc == 1 && plain) cpoly_family(p, cap, PB_IO_PUTC);
  if (((sp_streq(name, "seek") && (argc == 1 || argc == 2)) ||
       (sp_streq(name, "read") && argc == 1 && (ret == TY_POLY || ret == TY_STRING))) && plain) {
    int int_args = 1;
    for (int a = 0; a < argc; a++)
      if (atmp_ty[a] != TY_INT && atmp_ty[a] != TY_POLY) int_args = 0;
    if (int_args) cpoly_family(p, cap, PB_IO_SEEK_READ);
  }
  if (ps->unshift) cpoly_family(p, cap, PB_UNSHIFT);
  if (ps->push) cpoly_family(p, cap, PB_PUSH);
  if (ps->ppack && !sp_streq(name, "unpack1")) cpoly_family(p, cap, PB_PACK);
  if (ps->pjoin) cpoly_family(p, cap, PB_JOIN_N);
  if (ps->include) cpoly_family(p, cap, PB_INCLUDE_CASES);
  if (ps->arr_index && argc == 1) cpoly_family(p, cap, PB_ARR_INDEX);
  if (ps->intersect) cpoly_family(p, cap, PB_INTERSECT);
  if (ps->strftime) cpoly_family(p, cap, PB_STRFTIME);
  /* a Hash's `[]` or fetch, by the key's kind */
  int aref = (sp_streq(name, "[]") && argc == 1 && splat_a < 0) ||
             (sp_streq(name, "fetch") && (argc == 1 || argc == 2) && splat_a < 0 &&
              nt_ref(c->nt, id, "block") < 0);
  TyKind kt = aref ? comp_ntype(c, argv[0]) : TY_UNKNOWN;
  if (aref && kt == TY_STRING) cpoly_family(p, cap, PB_AREF_STR);
  if (aref && kt == TY_SYMBOL) cpoly_family(p, cap, PB_AREF_SYM);
  if (aref && (kt == TY_POLY || kt == TY_UNKNOWN)) cpoly_family(p, cap, PB_AREF_POLY);
  if (ps->pred) cpoly_family(p, cap, PB_PRED_N);
  /* the `default:` arm (emit_poly_defaults_n) */
  int is_aref = sp_streq(name, "[]") && argc == 1 && splat_a < 0;
  int is_aref2 = sp_streq(name, "[]") && argc == 2 && splat_a < 0;
  int is_fetch = sp_streq(name, "fetch") && (argc == 1 || argc == 2) && splat_a < 0 &&
                 nt_ref(c->nt, id, "block") < 0;
  if (!ps->pred && !ps->strftime && !is_aref && !is_aref2 && !is_fetch && !ps->include && !ps->push &&
      !ps->cover && !ps->gcdlcm && !ps->strdel && !ps->strsplit && !ps->pdelete && !ps->pdig &&
      !ps->pvalues_at && !ps->pfirstn && !ps->pmerge) {
    cpoly_family(p, cap, PB_ND_GENERIC);
    if (sp_streq(name, "replace") && argc == 1 && splat_a < 0 && ret == TY_POLY) cpoly_family(p, cap, PB_ND_REPLACE);
    else if ((sp_streq(name, "round") || sp_streq(name, "ceil") || sp_streq(name, "floor") ||
              sp_streq(name, "truncate")) && argc == 1 && splat_a < 0)
      cpoly_family(p, cap, PB_ND_ROUND);
    else if (splat_a < 0 && poly_num_arm(name, argc) >= 0) cpoly_family(p, cap, PB_ND_NUM);
    else if (ps->arr_index && !sp_streq(name, "find_index")) cpoly_family(p, cap, PB_ND_STR_INDEX);
    else if (ps->arr_index && argc == 1) cpoly_family(p, cap, PB_ND_FIND_INDEX);
  }
  else if (ps->pfirstn) { if (ret == TY_POLY) cpoly_family(p, cap, PB_ND_FIRSTN); }
  else if (ps->pdelete || ps->pdig || ps->pvalues_at) { if (ret == TY_POLY) cpoly_family(p, cap, PB_ND_KEYS); }
  else if (ps->pmerge) cpoly_family(p, cap, PB_ND_MERGE);
  else if (is_aref2) cpoly_family(p, cap, PB_ND_AREF2);
  else if (is_aref || is_fetch) cpoly_family(p, cap, PB_ND_AREF);
}

/* The pre-arms of a dispatch with arguments (emit_poly_prearms_n, then
   emit_poly_prearms_n_blk): the tag pre-arm families, a class value's
   class-side arms, a callable value's call. */
static void cpoly_prearms_n(Compiler *c, int id, const char *name, int argc, const int *argv, TyKind ret,
                            const TyKind *atmp_ty, int kwall_any, int is_setter_val, PolyPlan *p, int *cap) {
  const NodeTable *nt = c->nt;
  PolySpecialsN ps;
  poly_specials_n(c, id, name, argc, argv, &ps);
  int splat_a = -1, splat_last = 0;
  poly_specials_n_splat(c, argv, &ps, &splat_a, &splat_last);
  int pos_argc = ps.pos_argc, kwh = ps.kwh;
  if (ps.cover) cpoly_family(p, cap, PB_COVER);
  if (ps.ctryconv) cpoly_family(p, cap, PB_TRY_CONVERT);
  if (ps.gcdlcm) cpoly_family(p, cap, PB_GCDLCM);
  if (ps.ppack && sp_streq(name, "unpack1")) cpoly_family(p, cap, PB_UNPACK1);
  if (ps.include) cpoly_family(p, cap, PB_INCLUDE);
  if (ps.strdel && (ret == TY_POLY || ret == TY_STRING)) cpoly_family(p, cap, PB_STR_DELETE);
  if (ps.strpart && (ret == TY_POLY || ret == TY_STR_ARRAY)) cpoly_family(p, cap, PB_STR_PARTITION);
  if (ps.strsetop_n &&
      (sp_streq(name, "count") ? ret == TY_POLY || ret == TY_INT : ret == TY_POLY || ret == TY_STRING))
    cpoly_family(p, cap, PB_STR_SETOP);
  if (ps.pstore && ret == TY_POLY) cpoly_family(p, cap, PB_STORE);
  if (ps.strencode && pos_argc <= 2 && (ret == TY_POLY || ret == TY_STRING)) cpoly_family(p, cap, PB_STR_ENCODE);
  if (ps.strsplit && (ret == TY_STR_ARRAY || ret == TY_POLY_ARRAY || ret == TY_POLY))
    cpoly_family(p, cap, PB_STR_SPLIT_N);
  if (ps.index) cpoly_family(p, cap, PB_INT_BITREF);
  /* the class-side arms read the keyword values' types when the keywords
     split off one by one */
  int kwn = 0;
  const int *kwels = NULL;
  TyKind *kwty = NULL;
  if (kwh >= 0 && !ps.kw_ds) {
    kwels = nt_arr(nt, kwh, "elements", &kwn);
    kwty = malloc(sizeof(TyKind) * (size_t)(kwn > 0 ? kwn : 1));
    for (int e = 0; e < kwn; e++) {
      int val = nt_ref(nt, kwels[e], "value");
      TyKind at = val >= 0 ? comp_ntype(c, val) : TY_NIL;
      kwty[e] = at == TY_NIL || at == TY_VOID || at == TY_UNKNOWN ? TY_POLY : at;
    }
  }
  PolyKw kw = { kwh, kwn, ps.kw_ds ? 0 : -1, kwels, NULL, kwty, kwall_any };
  PolyArgs A = { argv, pos_argc, NULL, atmp_ty, &kw, NULL };
  cpoly_cls_value_arms(c, id, name, pos_argc, &A, ret, !is_setter_val, p, cap);
  free(kwty);
  int callable = sp_streq(name, "call") || sp_streq(name, "()") || sp_streq(name, "[]");
  if (callable &&
      (ps.kw_pos && !ps.has_splat_arg ? (ps.kw_ds ? pos_argc : argc) <= SP_PROC_ARG_SLOTS
       : kwh >= 0 && !ps.has_splat_arg ? argc <= SP_PROC_ARG_SLOTS
       : splat_last))
    cpoly_family(p, cap, PB_CALLABLE);
  if (ps.kw_pos && !ps.has_splat_arg && cpoly_str_trial(c, id, name, argc, argv, atmp_ty, ret, p))
    cpoly_trial(p, cap, PT_STR);
  cpoly_cases_n(c, id, name, argc, argv, ret, atmp_ty, &ps, splat_a, p, cap);
  if (cpoly_has_family(p, PB_ND_GENERIC) && !cpoly_has_family(p, PB_ND_REPLACE) &&
      !cpoly_has_family(p, PB_ND_ROUND) && !cpoly_has_family(p, PB_ND_NUM))
    cpoly_trial(p, cap, PT_GENERIC_TAIL);
  /* the families that write the switch's `default:` themselves */
  static const int dflt[] = { PB_ND_GENERIC, PB_ND_FIRSTN, PB_ND_KEYS, PB_ND_MERGE, PB_ND_AREF2, PB_ND_AREF,
                              PB_PUSH, PB_INCLUDE_CASES, PB_STRFTIME, PB_PRED_N };
  int has_default = 0;
  for (size_t i = 0; i < sizeof dflt / sizeof dflt[0]; i++) has_default |= cpoly_has_family(p, dflt[i]);
  if (!is_setter_val && !has_default) cpoly_trial(p, cap, PT_DEFAULT_N);
}

/* The arms the user-class loop of a poly dispatch with arguments writes. */
static void cpoly_user_arms_n(Compiler *c, int id, const char *name, int argc, const int *argv,
                              TyKind ret, PolyPlan *p, int full) {
  const NodeTable *nt = c->nt;
  int cap = 0;
  int has_splat_arg = 0;
  for (int a = 0; a < argc; a++)
    if (nt_kind(nt, argv[a]) == NK_SplatNode) { has_splat_arg = 1; break; }
  int kwh = -1, pos_argc = argc, kw_ds = 0, kw_strkey = 0;
  if (nt_kind(nt, argv[argc - 1]) == NK_KeywordHashNode) {
    int en = 0; const int *els = nt_arr(nt, argv[argc - 1], "elements", &en);
    int plain = en > 0, nds = 0;
    for (int e = 0; e < en; e++) {
      if (nt_kind(nt, els[e]) == NK_AssocSplatNode) {
        if (!poly_kw_splat_ok(c, els[e])) { plain = 0; break; }
        nds++;
        continue;
      }
      int key = nt_ref(nt, els[e], "key");
      if (key < 0) { plain = 0; break; }
      if (nt_kind(nt, key) != NK_SymbolNode) kw_strkey = 1;
    }
    if (plain) { kwh = argv[argc - 1]; pos_argc = argc - 1; kw_ds = nds > 0 || kw_strkey; }
  }
  int kw_pos = kwh < 0 || kw_ds;
  int splat_a = -1;
  if (has_splat_arg)
    for (int a = 0; a < pos_argc && splat_a < 0; a++)
      if (nt_kind(nt, argv[a]) == NK_SplatNode) splat_a = a;
  int is_setter_val = argc == 1 && !has_splat_arg && call_is_setter_assign(nt, id) &&
                      nt_ref(nt, id, "block") < 0;
  TyKind *atmp_ty = malloc(sizeof(TyKind) * (size_t)argc);
  for (int a = 0; a < argc; a++) atmp_ty[a] = TY_UNKNOWN;
  for (int a = 0; a < pos_argc; a++) {
    if (nt_kind(nt, argv[a]) == NK_SplatNode) { atmp_ty[a] = TY_POLY_ARRAY; continue; }
    TyKind at = comp_ntype(c, argv[a]);
    atmp_ty[a] = at == TY_NIL || at == TY_VOID || at == TY_UNKNOWN ? TY_POLY : at;
  }
  int kwall_any = kw_ds && (kw_strkey || poly_kw_any_key(c, kwh));
  if (kw_ds) atmp_ty[pos_argc] = kwall_any ? TY_POLY_POLY_HASH : TY_SYM_POLY_HASH;
  else if (kwh >= 0 && sp_streq(name, "fetch") && argc == 2) atmp_ty[pos_argc] = TY_SYM_POLY_HASH;
  p->flags = PPF_ROOT | (poly_key_cls0(c, name, argc, kwh, pos_argc, splat_a) ? PPF_KEY_CLS0 : 0) |
             (poly_key_prim(c, name, argc, kwh, pos_argc, splat_a) ? PPF_KEY_PRIM : 0) |
             (poly_exc_cand(c, name) ? PPF_KEY_EXC : 0);
  PolyKw kw = { kwh, 0, kw_ds ? 0 : -1, NULL, NULL, NULL, kwall_any };
  PolyArgs pargs = { argv, pos_argc, NULL, atmp_ty, &kw, NULL };
  if (full) cpoly_prearms_n(c, id, name, argc, argv, ret, atmp_ty, kwall_any, is_setter_val, p, &cap);
  int *ks = malloc(sizeof(int) * (size_t)(c->nclasses > 0 ? c->nclasses : 1));
  int nks = cpoly_arm_classes(c, name, ks);
  for (int ki = 0; ki < nks; ki++) {
    int k = ks[ki];
    if (c->classes[k].is_native_class) {
      if (kw_pos && has_splat_arg && argc == 1 && splat_a == 0 && kwh < 0 && c->classes[k].instantiated) {
        const NativeMethod *rm = NULL;
        for (int i = 0; i < c->n_native_methods && !rm; i++) {
          const NativeMethod *m = &c->native_methods[i];
          if (m->class_id == k && m->kind == 0 && m->rest && m->nargs == 0 && sp_streq(m->name, name))
            rm = m;
        }
        if (!rm) continue;
        TyKind mret = sp_streq(rm->ret, "self") ? ty_object(k) : native_spec_to_ty(rm->ret);
        cpoly_add(p, &cap, PA_NATIVE, k, -1, mret, cpoly_native_conv(mret, ret, is_setter_val));
        continue;
      }
      if (!kw_pos || has_splat_arg || !c->classes[k].instantiated) continue;
      TyKind mret = TY_UNKNOWN;
      if (!kw_ds) {
        if (poly_native_arm_fits(c, k, name, argc, argv, atmp_ty, &mret) < 0) continue;
        cpoly_add(p, &cap, PA_NATIVE, k, -1, mret, cpoly_native_conv(mret, ret, is_setter_val));
        continue;
      }
      int fit = 0;
      for (int n = pos_argc; n <= argc && !fit; n++)
        if (poly_native_arm_fits(c, k, name, n, argv, atmp_ty, &mret) >= 0 &&
            (mret == TY_NIL || is_setter_val || ret == TY_POLY || mret == TY_POLY || mret == ret))
          fit = 1;
      if (fit) cpoly_add(p, &cap, PA_NATIVE, k, -1, TY_UNKNOWN, PC_SAME);
      continue;
    }
    int defcls = -1;
    int mi = comp_method_in_chain(c, k, name, &defcls);
    if (mi < 0 && any_exc_reopen(c) && (class_has_exc_name(c, k) || class_is_exc_subclass(c, k))) {
      int xd = exc_arm_definer(c, k, name);
      if (xd >= 0) { defcls = xd; mi = comp_method_in_chain(c, xd, name, NULL); }
    }
    if (mi < 0) continue;
    char arm_exp[600];
    int arm_fit = poly_arm_count(c, &c->scopes[mi], kwh, pos_argc, splat_a, arm_exp, sizeof arm_exp);
    if (arm_fit == 0) continue;
    if (!c->classes[k].instantiated && !class_is_prim_reopen(c, k)) continue;
    if (arm_fit < 0) { cpoly_add(p, &cap, PA_ARITY, k, mi, TY_UNKNOWN, PC_VOID); continue; }
    if (!scope_has_callable_symbol(c, mi) && !scope_needs_proc_form(c, mi)) continue;
    int pfi = scope_proc_form_of(c, mi);
    Scope *ks = &c->scopes[pfi >= 0 ? pfi : mi];
    ArgLayout L;
    poly_arm_layout(c, ks, &pargs, &L);
    int fits = cplan_arm_args_fit(c, ks, &L, pos_argc, atmp_ty, kwall_any);
    arg_layout_free(&L);
    if (!fits) continue;
    TyKind mret = ks->ret;
    int conv = is_setter_val || mret == TY_VOID || mret == TY_NIL || method_is_void(ks) ? PC_VOID
             : cpoly_conv(ret, mret);
    cpoly_add(p, &cap, pfi >= 0 ? PA_PROC_FORM : PA_USER, k, mi, mret, conv);
    p->arm[p->n - 1].def = (short)defcls;
  }
  free(atmp_ty);
  free(ks);
}

/* The `default:` arm emit_poly_obj_default0 writes for a zero-argument
   dispatch: the Object reopening's method of the name. */
static void cpoly_obj_default0(Compiler *c, int id, const char *name, TyKind ret, PolyPlan *p, int *cap) {
  int obj_cls = comp_class_index(c, "Object");
  if (obj_cls < 0) return;
  int obj_def = -1;
  int obj_mi = comp_method_in_chain(c, obj_cls, name, &obj_def);
  int blk = nt_ref(c->nt, id, "block");
  int obj_pf = obj_mi >= 0 && obj_def == obj_cls && c->scopes[obj_mi].yields && blk >= 0
               ? scope_proc_form_of(c, obj_mi) : -1;
  if (obj_pf >= 0 && (c->scopes[obj_pf].nparams != 0 || c->scopes[obj_pf].rest_idx >= 0)) obj_pf = -1;
  if (obj_pf >= 0 && resolve_forwarded_block(c, blk) < 0) obj_pf = -1;
  char oexp[600];
  if (obj_pf >= 0) {
    Scope *ps = &c->scopes[obj_pf];
    cpoly_add(p, cap, PA_PROC_FORM, PA_KEY_DEFAULT, obj_mi, ps->ret,
              method_is_void(ps) ? PC_VOID : cpoly_conv(ret, ps->ret));
  }
  else if (obj_mi >= 0 && obj_def == obj_cls && c->scopes[obj_mi].nrequired == 0 &&
           scope_has_callable_symbol(c, obj_mi)) {
    Scope *ms = &c->scopes[obj_mi];
    cpoly_add(p, cap, PA_USER, PA_KEY_DEFAULT, obj_mi, ms->ret,
              method_is_void(ms) ? PC_VOID : cpoly_conv(ret, ms->ret));
  }
  else if (obj_def == obj_cls && poly_arm_refuses_none(c, obj_mi, oexp, sizeof oexp))
    cpoly_add(p, cap, PA_ARITY, PA_KEY_DEFAULT, obj_mi, TY_UNKNOWN, PC_VOID);
}

static int cpoly_name_in(const char *name, const char *const *list) {
  for (int i = 0; list[i]; i++) if (sp_streq(name, list[i])) return 1;
  return 0;
}

static void cpoly_family(PolyPlan *p, int *cap, int fam) {
  cpoly_add(p, cap, PA_BUILTIN, PA_KEY_BUILTIN + fam, -1, TY_UNKNOWN, PC_SAME);
}

/* a trial arm the dispatch offers: what it answers is the emission's */
static void cpoly_trial(PolyPlan *p, int *cap, int t) {
  cpoly_add(p, cap, PA_TRIAL, PA_KEY_TRIAL + t, -1, TY_UNKNOWN, PC_SAME);
}

static int cpoly_has_family(const PolyPlan *p, int fam) {
  for (int i = 0; i < p->n; i++)
    if (p->arm[i].key == PA_KEY_BUILTIN + fam) return 1;
  return 0;
}

/* Does the dispatch offer a String the builtin answer (emit_poly_str_prearm)?
   Not when an earlier pre-arm already took the String tag. */
static int cpoly_str_trial(Compiler *c, int id, const char *name, int argc, const int *argv,
                           const TyKind *atmp_ty, TyKind ret, const PolyPlan *p) {
  if (!(poly_string_read_p(name) || (argc == 1 && sp_streq(name, "to_i")))) return 0;
  if (nt_ref(c->nt, id, "block") >= 0) return 0;
  for (int a = 0; a < argc; a++)
    if (subtree_has_side_effect(c, argv[a]) && comp_ntype(c, argv[a]) != atmp_ty[a]) return 0;
  TyKind bt = c->poly_builtin_ty && id < c->node_cap ? c->poly_builtin_ty[id] : TY_UNKNOWN;
  if (bt == TY_UNKNOWN || (ret != TY_POLY && bt != ret)) return 0;
  static const int str_tag[] = { PB_LEN, PB_EMPTY, PB_STRT, PB_SPLIT, PB_UNPACK1, PB_STR_DELETE,
                                 PB_STR_PARTITION, PB_STR_SETOP, PB_STR_ENCODE, PB_STR_SPLIT_N };
  for (size_t i = 0; i < sizeof str_tag / sizeof str_tag[0]; i++)
    if (cpoly_has_family(p, str_tag[i])) return 0;
  /* an Integer's bit reference reads a String's character too */
  if (cpoly_has_family(p, PB_INT_BITREF) && (ret == TY_POLY || ret == TY_STRING)) return 0;
  return 1;
}

/* The tag pre-arms emit_poly_prearms0 writes: a builtin value's answer to
   a name a user class also owns. */
static void cpoly_prearms0(Compiler *c, int id, const char *name, const PolySpecials0 *ps, TyKind ret,
                           PolyPlan *p, int *cap) {
  static const char *const ioz[] = { "close", "closed?", "eof?", "eof", "tty?", "isatty", "flush",
    "fileno", "tell", "pos", "lineno", "sync", "gets", "getc", "readchar", "readline", "readbyte",
    "getbyte", "readlines", NULL };
  static const char *const reduce[] = { "sum", "min", "max", "first", "last", NULL };
  /* the String transforms, by what they answer: a String, an Integer
     array, a String array */
  static const char *const strt_s[] = { "upcase", "downcase", "capitalize", "swapcase", "strip",
    "reverse", "chomp", "chop", "succ", "next", "chr", NULL };
  int blockless = nt_ref(c->nt, id, "block") < 0;
  if (ps->lengthlike) cpoly_family(p, cap, PB_LEN);
  if (ps->empty) cpoly_family(p, cap, PB_EMPTY);
  if (ps->class_named) cpoly_family(p, cap, PB_CLASS_NAMED);
  if (ps->class_reflect) cpoly_family(p, cap, PB_CLASS_REFLECT);
  if (ps->ostruct) cpoly_family(p, cap, PB_OSTRUCT);
  if (ps->poly_to_a) cpoly_family(p, cap, PB_TO_A);
  if (ps->io_rewind) cpoly_family(p, cap, PB_IO_REWIND);
  if (blockless && sp_streq(name, "puts")) cpoly_family(p, cap, PB_IO_PUTS);
  if (blockless && cpoly_name_in(name, ioz)) cpoly_family(p, cap, PB_IOZ);
  if (blockless && cpoly_name_in(name, reduce)) cpoly_family(p, cap, PB_REDUCE);
  int sci = comp_class_index(c, "String");
  if (sci >= 0 && comp_method_in_chain(c, sci, name, NULL) >= 0) return;   /* the reopen answers */
  int fits = cpoly_name_in(name, strt_s) ? ret == TY_POLY || ret == TY_STRING
           : sp_streq(name, "bytes") ? ret == TY_POLY || ret == TY_INT_ARRAY
           : sp_streq(name, "chars") ? ret == TY_POLY || ret == TY_STR_ARRAY : 0;
  if (fits && sp_streq(name, "chr")) cpoly_family(p, cap, PB_INT_CHR);
  if (fits) cpoly_family(p, cap, PB_STRT);
  if (sp_streq(name, "split") && (ret == TY_STR_ARRAY || ret == TY_POLY_ARRAY || ret == TY_POLY))
    cpoly_family(p, cap, PB_SPLIT);
}

/* The class-side arms a class-valued receiver takes ahead of the instance
   switch (emit_poly_cls_value_prearm). Their count. */
static int cpoly_cls_value_arms(Compiler *c, int id, const char *name, int argc, const PolyArgs *A,
                                TyKind ret, int has_tr, PolyPlan *p, int *cap) {
  int ncc = 0;
  (void)comp_cmethod_candidates(c, name, &ncc);
  int *ccls = malloc(sizeof(int) * (size_t)(ncc > 0 ? ncc : 1));
  int *cmi = malloc(sizeof(int) * (size_t)(ncc > 0 ? ncc : 1));
  char (*cexp)[600] = malloc(sizeof *cexp * (size_t)(ncc > 0 ? ncc : 1));
  int wants_blk = 0;
  int n = poly_cls_value_cands(c, id, name, argc, A, 0, ccls, cmi, cexp, &wants_blk);
  for (int i = 0; i < n; i++) {
    Scope *ks = &c->scopes[cmi[i]];
    if (cexp[i][0]) cpoly_add(p, cap, PA_ARITY, PA_KEY_CLASS_VALUE + ccls[i], cmi[i], TY_UNKNOWN, PC_VOID);
    else
      cpoly_add(p, cap, PA_USER, PA_KEY_CLASS_VALUE + ccls[i], cmi[i], ks->ret,
                !has_tr || method_is_void(ks) ? PC_VOID : cpoly_conv(ret, ks->ret));
  }
  free(ccls); free(cmi); free(cexp);
  return n;
}

/* The pre-arms emit_poly_prearms0_blk writes: a builtin container or a
   Mutex driving the call's block as a proc, a callable value, a class
   value's class-side arms, or else a Struct class's members. */
static void cpoly_prearms0_blk(Compiler *c, int id, const char *name, const PolySpecials0 *ps, TyKind ret,
                               PolyPlan *p, int *cap) {
  int blk = nt_ref(c->nt, id, "block");
  int live_blk = blk >= 0 && resolve_forwarded_block(c, blk) >= 0;
  if (live_blk && poly_enum_op_for(name)) cpoly_family(p, cap, PB_ENUM_PROC);
  if (live_blk && sp_streq(name, "synchronize")) cpoly_family(p, cap, PB_SYNC);
  if (sp_streq(name, "call") || sp_streq(name, "()") || sp_streq(name, "[]")) cpoly_family(p, cap, PB_CALLABLE);
  PolyArgs none = { NULL, 0, NULL, NULL, NULL, NULL };
  if (!cpoly_cls_value_arms(c, id, name, 0, &none, ret, 1, p, cap) && ps->cls_members)
    cpoly_family(p, cap, PB_CLS_MEMBERS);
}

/* The builtin cases emit_poly_cases0 writes after the class arms (the
   container read re-entered as a builtin is a trial, not listed here). */
static void cpoly_cases0(const char *name, const PolySpecials0 *ps, PolyPlan *p, int *cap) {
  if (sp_streq(name, "length") || sp_streq(name, "size") || sp_streq(name, "count"))
    cpoly_family(p, cap, PB_LEN_CASES);
  if (sp_streq(name, "clear")) cpoly_family(p, cap, PB_CLEAR);
  if (ps->empty) cpoly_family(p, cap, PB_EMPTY_CASES);
  if (sp_streq(name, "compare_by_identity?")) cpoly_family(p, cap, PB_CMP_BY_ID);
}

/* The builtin `default:` arm emit_poly_defaults0 writes when the Object
   reopening has none (the first that applies), and its named cases. */
static void cpoly_defaults0(Compiler *c, int id, const char *name, const PolySpecials0 *ps, TyKind ret,
                            int obj_done, PolyPlan *p, int *cap) {
  static const char *const case_conv[] = { "upcase", "downcase", "capitalize", "swapcase", NULL };
  static const char *const num[] = { "abs", "round", "succ", "next", "pred", "ceil", "floor", "truncate",
    "abs2", "infinite?", "numerator", "denominator", "nonzero?", "bit_length", NULL };
  static const char *const arr_t[] = { "flatten", "compact", "uniq", NULL };
  static const char *const queue[] = { "size", "length", "empty?", "pop", "shift", "deq", "num_waiting",
    "closed?", "max", "close", NULL };
  int blockless = nt_ref(c->nt, id, "block") < 0;
  int fam = -1;
  if (obj_done) fam = -1;
  else if (sp_streq(name, "__to_enum_each") && (ret == TY_POLY || ret == TY_ENUMERATOR)) fam = PB_D_ENUM_EACH;
  else if (sp_streq(name, "to_s") || sp_streq(name, "inspect")) fam = PB_D_TO_S;
  else if (cpoly_name_in(name, case_conv)) fam = PB_D_CASE_CONV;
  else if (cpoly_name_in(name, num)) fam = PB_D_NUM;
  else if (sp_streq(name, "digits")) fam = PB_D_DIGITS;
  else if (cpoly_name_in(name, arr_t) && (ret == TY_POLY || ret == TY_POLY_ARRAY)) fam = PB_D_ARRAY_TRANSFORM;
  else if (ps->pred) fam = PB_D_PRED;
  else if (sp_streq(name, "to_i") || sp_streq(name, "to_f")) fam = PB_D_TO_IF;
  else if (blockless && (sp_streq(name, "any?") || sp_streq(name, "none?"))) fam = PB_D_ANY_NONE;
  else if (sp_streq(name, "to_h") && blockless && ret == TY_POLY) fam = PB_D_TO_H;
  if (fam >= 0) cpoly_family(p, cap, fam);
  if (sp_streq(name, "each_index") || sp_streq(name, "each_with_index")) cpoly_family(p, cap, PB_N_EACH_INDEX);
  if (sp_streq(name, "join")) cpoly_family(p, cap, PB_N_JOIN);
  if (sp_streq(name, "alive?")) cpoly_family(p, cap, PB_N_ALIVE);
  if (sp_streq(name, "kill")) cpoly_family(p, cap, PB_N_KILL);
  if (sp_streq(name, "status")) cpoly_family(p, cap, PB_N_STATUS);
  if (cpoly_name_in(name, queue)) cpoly_family(p, cap, PB_N_QUEUE);
  if (sp_streq(name, "read") && (ret == TY_POLY || ret == TY_STRING)) cpoly_family(p, cap, PB_N_IO_READ);
  if (sp_streq(name, "flush")) cpoly_family(p, cap, PB_N_IO_FLUSH);
  if (sp_streq(name, "close")) cpoly_family(p, cap, PB_N_IO_CLOSE);
  if (sp_streq(name, "__enum_to_a")) cpoly_family(p, cap, PB_N_ENUM_TO_A);
}

/* How a zero-argument dispatch holds and keys its receiver, and the type
   its arms answer into (an OpenStruct member read makes an untyped call
   poly), as emit_poly_method_dispatch decides them. */
static void cpoly_flags0(Compiler *c, int id, const char *name, PolyPlan *p, PolySpecials0 *out) {
  PolySpecials0 ps;
  poly_specials0(c, id, name, &ps);
  *out = ps;
  if (ps.ostruct && (p->ret == TY_UNKNOWN || p->ret == TY_VOID || p->ret == TY_NIL)) p->ret = TY_POLY;
  int root = ps.ncall_arm > 0 || ps.lengthlike || ps.empty || ps.pred || ps.class_named ||
             ps.class_reflect || ps.ostruct || ps.io_rewind || ps.poly_to_a || ps.poly_to_h;
  unsigned sface = ty_poly_face_owners(name, 0, nt_ref(c->nt, id, "block") >= 0, 1, 1);
  int deref = (ps.lengthlike || ps.empty || ((sface & PF_STRING) && !(sface & PF_MUT))) &&
              !sp_str_mutator(name, SP_MUT_LOCAL);
  p->flags = (root ? PPF_ROOT : 0) | (deref ? PPF_DEREF : 0) |
             (poly_key_cls0(c, name, 0, -1, 0, -1) ? PPF_KEY_CLS0 : 0) |
             (poly_key_prim(c, name, 0, -1, 0, -1) ? PPF_KEY_PRIM : 0) |
             (poly_exc_cand(c, name) ? PPF_KEY_EXC : 0);
}

static void cpoly_resolve(Compiler *c, int id, PolyPlan *p, int full) {
  free(p->arm);
  p->arm = NULL; p->n = 0; p->flags = 0; p->full = full;
  p->ntype = p->ret = comp_ntype(c, id);
  const char *name = nt_str(c->nt, id, "name");
  int recv = nt_ref(c->nt, id, "receiver");
  int argc = 0;
  int args = nt_ref(c->nt, id, "arguments");
  if (args >= 0) (void)nt_arr(c->nt, args, "arguments", &argc);
  if (!name || recv < 0) return;
  if (argc == 0) {
    PolySpecials0 ps;
    cpoly_flags0(c, id, name, p, &ps);
    cpoly_user_arms0(c, id, name, p->ret, p);
    if (!full) return;
    int cap = p->n;
    cpoly_prearms0(c, id, name, &ps, p->ret, p, &cap);
    cpoly_prearms0_blk(c, id, name, &ps, p->ret, p, &cap);
    cpoly_cases0(name, &ps, p, &cap);
    if (cpoly_str_trial(c, id, name, 0, NULL, NULL, p->ret, p)) cpoly_trial(p, &cap, PT_STR);
    if (p->ret == TY_POLY && nt_ref(c->nt, id, "block") < 0 && poly_container_read_p(name))
      cpoly_trial(p, &cap, PT_CONTAINER);
    int n0 = p->n;
    cpoly_obj_default0(c, id, name, p->ret, p, &cap);
    int n1 = p->n;
    cpoly_defaults0(c, id, name, &ps, p->ret, p->n > n0, p, &cap);
    /* a default written by now (the Object reopening's, a builtin one), or
       the builtin surface's, and the raise when it declines */
    int done = n1 > n0;
    for (int f = PB_D_ENUM_EACH; f <= PB_D_TO_H; f++) done |= cpoly_has_family(p, f);
    if (cpoly_has_family(p, PB_D_ARRAY_TRANSFORM)) cpoly_trial(p, &cap, PT_ARRAY_FALLBACK);
    if (!done) cpoly_trial(p, &cap, PT_DEFAULT0);
  }
  else cpoly_user_arms_n(c, id, name, argc, nt_arr(c->nt, args, "arguments", &argc), p->ret, p, full);
}

static PolyPlan *g_pp_memo;
static char **g_pp_name;
static int g_pp_cap;

static const PolyPlan *cplan_poly_level(Compiler *c, int id, int full);

const PolyPlan *cplan_poly(Compiler *c, int id) { return cplan_poly_level(c, id, 1); }
const PolyPlan *cplan_poly_arms(Compiler *c, int id) { return cplan_poly_level(c, id, 0); }

static const PolyPlan *cplan_poly_level(Compiler *c, int id, int full) {
  static PolyPlan fresh;
  if (id < 0 || id >= c->node_cap) { free(fresh.arm); fresh.arm = NULL; fresh.n = 0; return &fresh; }
  const char *nm = nt_str(c->nt, id, "name");
  int plain = cplan_plain_ctx();
  if (plain && id < g_pp_cap && g_pp_name[id] && nm && sp_streq(g_pp_name[id], nm) &&
      g_pp_memo[id].ntype == comp_ntype(c, id) && (g_pp_memo[id].full || !full))
    return &g_pp_memo[id];
#ifndef NDEBUG
  int tmp0 = g_tmp;
#endif
  PolyPlan *p = &fresh;
  if (plain) {
    if (id >= g_pp_cap) {
      int ncap = g_pp_cap ? g_pp_cap : 1024;
      while (ncap <= id) ncap *= 2;
      g_pp_memo = realloc(g_pp_memo, (size_t)ncap * sizeof *g_pp_memo);
      g_pp_name = realloc(g_pp_name, (size_t)ncap * sizeof *g_pp_name);
      memset(g_pp_memo + g_pp_cap, 0, (size_t)(ncap - g_pp_cap) * sizeof *g_pp_memo);
      memset(g_pp_name + g_pp_cap, 0, (size_t)(ncap - g_pp_cap) * sizeof *g_pp_name);
      g_pp_cap = ncap;
    }
    p = &g_pp_memo[id];
    free(g_pp_name[id]);
    g_pp_name[id] = nm ? strdup(nm) : NULL;
  }
  cpoly_resolve(c, id, p, full);
#ifndef NDEBUG
  assert(g_tmp == tmp0);   /* resolving emits nothing */
#endif
  return p;
}

const PolyPlan *cplan_poly_block(Compiler *c, int id) {
  static PolyPlan bp;
  free(bp.arm);
  bp.arm = NULL; bp.n = 0; bp.flags = 0;
  bp.ntype = bp.ret = comp_ntype(c, id);
  int cap = 0;
  int cand[64];
  int nc = poly_block_dispatch_cands(c, id, cand, 64);
  const char *name = nt_str(c->nt, id, "name");
  for (int i = 0; i < nc; i++)
    cpoly_add(&bp, &cap, PA_USER, cand[i], comp_method_in_chain(c, cand[i], name, NULL), TY_UNKNOWN, PC_VOID);
  if (nc == 0) return &bp;
  /* map!/collect! rewrites a builtin array in place, given a block body */
  int block = nt_ref(c->nt, id, "block");
  int map_bang = 0;
  if (sp_streq(name, "map!") || sp_streq(name, "collect!")) {
    int body = nt_ref(c->nt, block, "body");
    int bn = 0;
    if (body >= 0) (void)nt_arr(c->nt, body, "body", &bn);
    map_bang = bn >= 1 && block_param_name(c, block, 0);
  }
  if (map_bang) cpoly_family(&bp, &cap, PB_BD_MAP_BANG);
  else cpoly_trial(&bp, &cap, PT_BD_DEFAULT);
  return &bp;
}

const PolyPlan *cplan_poly_cmeth(Compiler *c, int id) {
  static PolyPlan cp;
  free(cp.arm);
  cp.arm = NULL; cp.n = 0; cp.flags = 0;
  cp.ntype = cp.ret = comp_ntype(c, id);
  int cap = 0;
  const char *name = nt_str(c->nt, id, "name");
  if (!name) return &cp;
  for (int k = 0; k < c->nclasses; k++) {
    int mi = comp_cmethod_in_chain(c, k, name, NULL);
    if (mi < 0) continue;
    int pf = scope_proc_form_of(c, mi);
    if (pf >= 0 && !proc_form_live(c, pf)) pf = -1;
    if (!scope_has_callable_symbol(c, mi) && pf < 0) continue;
    TyKind mret = c->scopes[pf >= 0 ? pf : mi].ret;
    cpoly_add(&cp, &cap, pf >= 0 ? PA_PROC_FORM : PA_USER, k, mi, mret, mret == TY_POLY ? PC_SAME : PC_BOX);
  }
  return &cp;
}

const PolyPlan *cplan_poly_sub(Compiler *c, int id) {
  static PolyPlan sp;
  free(sp.arm);
  sp.arm = NULL; sp.n = 0; sp.flags = 0;
  sp.ntype = sp.ret = comp_ntype(c, id);
  int cap = 0;
  const char *name = nt_str(c->nt, id, "name");
  int recv = nt_ref(c->nt, id, "receiver");
  if (!name || recv < 0) return &sp;
  TyKind rt = comp_ntype(c, recv);
  if (!ty_is_object(rt) || comp_ty_value_obj(c, rt)) return &sp;
  int bcid = ty_object_class(rt);
  for (int k = 0; k < c->nclasses; k++) {
    if (k == bcid) continue;
    int anc = 0;
    for (int p2 = c->classes[k].parent; p2 >= 0; p2 = c->classes[p2].parent)
      if (p2 == bcid) { anc = 1; break; }
    if (anc && (comp_method_in_chain(c, k, name, NULL) >= 0 || comp_reader_in_chain(c, k, name, NULL))) {
      cpoly_family(&sp, &cap, PB_SUBDISPATCH);
      break;
    }
  }
  return &sp;
}

const PolyPlan *cplan_poly_redispatch(Compiler *c, int id) {
  static PolyPlan rp;
  free(rp.arm);
  rp.arm = NULL; rp.n = 0; rp.flags = 0;
  rp.ntype = rp.ret = comp_ntype(c, id);
  int cap = 0;
  const char *name = nt_str(c->nt, id, "name");
  int recv = nt_ref(c->nt, id, "receiver");
  int argc = 0;
  (void)call_args(c->nt, id, &argc);
  if (!name || recv < 0 || comp_recv_type(c, recv) != TY_POLY) return &rp;
  int kind = poly_redispatch_kind(c, id, name, argc);
  if (kind) cpoly_family(&rp, &cap, kind == 2 ? PB_REDISPATCH_RECV : PB_REDISPATCH);
  return &rp;
}

const PolyPlan *cplan_poly_face(Compiler *c, int id) {
  static PolyPlan fp;
  free(fp.arm);
  fp.arm = NULL; fp.n = 0; fp.flags = 0;
  fp.ntype = fp.ret = comp_ntype(c, id);
  int cap = 0;
  const NodeTable *nt = c->nt;
  const char *name = nt_str(nt, id, "name");
  int argc = 0;
  const int *argv = call_args(nt, id, &argc);
  int has_blk = nt_ref(nt, id, "block") >= 0, plain = nt_call_args_plain(nt, id);
  if (!name) return &fp;
  unsigned own = an_zero_arg_builtin_shadowed(c, name, argc) ? 0
                 : ty_poly_face_owners(name, argc, has_blk, plain, 0);
  unsigned kinds = own & PF_OWNERS;
  if (own & PF_STR_BANG) { cpoly_family(&fp, &cap, PB_FACE_STR_BANG); return &fp; }
  for (unsigned kind = 1; kind & PF_OWNERS; kind <<= 1) {
    if (!(kinds & kind)) continue;
    /* several owners: an argument of another kind is the owner's TypeError */
    int misfit = 0;
    if (kinds & (kinds - 1)) {
      unsigned fl = ty_poly_face_owner_flags(name, argc, has_blk, plain, kind);
      if ((fl & PF_ARGS_OWN) && plain)
        for (int i = 0; i < argc && !misfit; i++) misfit = face_arg_misfit(c, kind, argv[i]);
    }
    cpoly_add(&fp, &cap, misfit ? PA_BUILTIN : PA_TRIAL, PA_KEY_FACE + face_kind_index(kind), -1, TY_UNKNOWN,
              PC_SAME);
  }
  return &fp;
}

PolyPlan *cplan_poly_copy(const PolyPlan *p) {
  PolyPlan *q = malloc(sizeof *q);
  *q = *p;
  q->arm = malloc(sizeof *q->arm * (size_t)(p->n > 0 ? p->n : 1));
  if (p->n) memcpy(q->arm, p->arm, sizeof *q->arm * (size_t)p->n);
  return q;
}

void cplan_poly_free(PolyPlan *p) {
  if (!p) return;
  free(p->arm);
  free(p);
}
