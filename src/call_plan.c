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
