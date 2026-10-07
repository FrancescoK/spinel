/* repr.c -- a value's C representation, read off the analysis's flags
   (see repr.h). Pure: it reads the types and the flags and changes
   nothing. */

#include <string.h>
#include "repr.h"
#include "codegen_internal.h"
#include "share.h"
#include "holder.h"

static int repr_sealed_flag;

/* the kind a value of type t is held in, before any flag refines it */
static ReprKind repr_kind_of_type(const Compiler *c, TyKind t) {
  switch (t) {
  case TY_UNKNOWN: case TY_VOID:
    return RK_NONE;
  case TY_INT: case TY_FLOAT: case TY_BOOL: case TY_SYMBOL: case TY_NIL:
    return RK_SCALAR;
  case TY_RANGE: case TY_FLOAT_RANGE: case TY_STR_RANGE: case TY_TIME:
  case TY_TMS: case TY_COMPLEX: case TY_RATIONAL: case TY_CLASS:
    return RK_STRUCT;
  case TY_STRBUF:
    return RK_STRBUF;
  case TY_POLY:
    return RK_BOXED;
  default:
    break;
  }
  if (ty_is_object(t)) {
    int cid = ty_object_class(t);
    if (cid >= 0 && cid < c->nclasses && c->classes[cid].is_value_type) return RK_VOBJ;
  }
  return RK_PTR;
}

/* The layout of a value stored as t that its type names and its kind does
   not: every Array and Hash is a pointer, and which container it points to
   -- what an Array holds its elements as (ty_array_elem), what a Hash
   holds its keys and its values as (its variant's row: ty_hash_key,
   ty_hash_val) -- decides the helpers a call on it takes and the C type
   they name; an Integer is an sp_int scalar, and one held big an
   sp_Bigint * pointer, which takes the Bignum helpers. */
static void repr_layout(Repr *r, TyKind t) {
  r->elem = ty_is_array(t) || ty_is_obj_array(t) ? ty_array_elem(t) : TY_UNKNOWN;
  r->key = ty_hash_key(t);
  r->val = ty_hash_val(t);
  r->big = t == TY_BIGINT;
}

int repr_hash_is(Repr r, TyKind key, TyKind val) {
  return r.key != TY_UNKNOWN && r.key == key && r.val == val;
}

/* an object whose class some other class inherits from: its static type is
   only the base, so its box reads the class from the object */
int repr_dyn_cls(const Compiler *c, TyKind t) {
  if (!ty_is_object(t)) return 0;
  int cid = ty_object_class(t);
  if (cid < 0 || cid >= c->nclasses) return 0;
  /* an exception's object starts with its class name, not a class id, so
     it is boxed with the static id (emit_boxed) */
  if (c->classes[cid].is_value_type || class_is_exc_subclass((Compiler *)c, cid)) return 0;
  /* an Array subclass instance is boxed as its Array (arysub_box_id) */
  if (c->classes[cid].ary_root > 0) return 0;
  for (int k = 0; k < c->nclasses; k++)
    if (k != cid && c->classes[k].parent == cid) return 1;
  return 0;
}

/* An Integer or Float node whose box has to test for the nil sentinel, as
   emit_boxed decides it: the analysis's answer for the node
   (nullable_int_value, through call_returns_nullable_int, which also reads
   a local's slot and a builtin's name), an Integer ivar read (every one is
   nil-initialized), a parameter bound from such an ivar (box_nullable_arg),
   a node in a Ruby-defined builtin (enum_builtin_node), and every Integer
   under --int-overflow=promote.
   nullable_int_value re-derives a receiver's type (infer_type), so the
   questions are asked as a pure read (an_pure_read_begin): nothing derived
   is recorded, and asking changes nothing codegen reads next. */
int repr_nil_scalar(const Compiler *c, int node, TyKind t) {
  Compiler *mc = (Compiler *)c;
  int r = 0;
  an_pure_read_begin();
  if (t == TY_INT)
    r = g_promote_mode || call_returns_nullable_int(mc, node) ||
        nt_kind(c->nt, node) == NK_InstanceVariableReadNode ||
        box_nullable_arg(mc, node) || enum_builtin_node(mc, node);
  else if (t == TY_FLOAT)
    r = call_returns_nullable_int(mc, node) || box_nullable_arg(mc, node) ||
        enum_builtin_node(mc, node);
  an_pure_read_end();
  return r;
}

/* Where the boxed form of a shared-mutable String comes from, as emit_boxed
   decides it for a node stored as (or holding) the handle. */
static int repr_strbuf_src(const Compiler *c, int node, TyKind t) {
  Compiler *mc = (Compiler *)c;
  const NodeTable *nt = c->nt;
  NodeKind k = nt_kind(nt, node);
  if (t == TY_STRING) {
    /* a global holding the handle (--share-strings): its read boxes it */
    if (repr_static_read_kind(k)) return repr_static_share(c, node) ? RS_HANDLE : RS_NONE;
    /* a local promoted to the handle after the node types were final */
    if (k != NK_LocalVariableReadNode) return RS_NONE;
    const char *ln = nt_str(nt, node, "name");
    Scope *s = ln ? comp_scope_of(mc, node) : NULL;
    LocalVar *lv = s ? scope_local(s, ln) : NULL;
    return lv && lv->type == TY_STRBUF && lv->str_shared ? RS_HANDLE : RS_NONE;
  }
  if (t != TY_STRBUF) return RS_NONE;
  if (k == NK_LocalVariableReadNode) {
    /* the mark can outlive the slot's type: a slot that settled poly holds
       the box already */
    const char *ln = nt_str(nt, node, "name");
    Scope *s = ln ? comp_scope_of(mc, node) : NULL;
    LocalVar *lv = s ? scope_local(s, ln) : NULL;
    return lv && lv->type == TY_POLY ? RS_SLOT_POLY : RS_HANDLE;
  }
  if (k == NK_InstanceVariableReadNode) {
    const char *nm = nt_str(nt, node, "name");
    int cid = nm ? strbuf_ivar_owner(mc, node) : -1;
    int iv = cid >= 0 ? comp_ivar_index(&c->classes[cid], nm) : -1;
    if (iv >= 0 && c->classes[cid].ivar_types[iv] == TY_STRBUF) return RS_HANDLE;
  }
  /* a global holding the handle (--share-strings) */
  if ((repr_static_read_kind(k) || k == NK_GlobalVariableWriteNode) && repr_static_share(c, node))
    return RS_HANDLE;
  /* an ivar write's value is the slot */
  if (k == NK_InstanceVariableWriteNode) return RS_HANDLE;
  /* an element a boxed container hands out is a boxed handle already */
  if (strbuf_boxed_elem_read(mc, node)) return RS_ELEM;
  /* a reader call (or a call answering its receiver) that renders the
     handle itself */
  if (k == NK_CallNode) {
    int r = nt_ref(nt, node, "receiver");
    if (r >= 0 && ty_is_object(comp_ntype(c, r)) &&
        (strbuf_marked_yields_handle(mc, node) || c->strbuf_handle_demand[node]))
      return RS_DEMANDED;
  }
  /* a String value stored where a handle is demanded: a fresh one */
  return RS_FRESH;
}

/* The type a node is STORED as, given its cached type t (comp_ntype's
   String-handle refinement). TY_STRBUF is a codegen-only storage refinement
   (a mutable sp_String for a `<<`-appended local): all type-directed logic
   treats it as a String, and only a read marked strbuf_box yields the live
   HANDLE, so the mutation is observable through the container it is stored
   in (#3227). A node under a handle demand STORES as the handle -- a temp
   spilled from it has to be an sp_String *, not a const char * -- while
   still dispatching as a String, which comp_recv_type answers for. That
   split is the whole point of the second array (#4363). */
TyKind repr_stored_type(const Compiler *c, int id, TyKind t) {
  if (t == TY_STRBUF) return c->strbuf_box[id] ? TY_STRBUF : TY_STRING;
  if (c->strbuf_handle_demand[id]) return TY_STRBUF;
  return t;
}

/* 1 iff t is a user-object type whose class is represented by value (sp_X,
   not a heap pointer). See detect_value_types. */
int repr_value_obj(const Compiler *c, TyKind t) {
  if (!ty_is_object(t)) return 0;
  int cid = ty_object_class(t);
  return cid >= 0 && cid < c->nclasses && c->classes[cid].is_value_type;
}

/* An argument whose boxing must allow nil though its typed reads need no
   nil check: an int ivar read nothing has to assign first, or a parameter
   already bound from one (box_nullable_arg). */
int repr_box_nullable_arg(Compiler *c, int v) {
  const NodeTable *nt = c->nt;
  if (v < 0) return 0;
  if (nt_kind(nt, v) == NK_InstanceVariableReadNode) {
    Scope *s = comp_scope_of(c, v);
    int cid = s ? s->class_id : -1;
    if (cid < 0) cid = comp_class_index(c, "Toplevel");
    if (cid < 0 || cid >= c->nclasses) return 0;
    ClassInfo *ci = &c->classes[cid];
    const char *ivn = nt_str(nt, v, "name");
    int iv = comp_ivar_index(ci, ivn);
    if (iv < 0 || (ci->ivar_types[iv] != TY_INT && ci->ivar_types[iv] != TY_FLOAT)) return 0;
    return !ivar_assigned_in_initialize(c, cid, ivn);
  }
  if (nt_kind(nt, v) == NK_LocalVariableReadNode) {
    Scope *s = comp_scope_of(c, v);
    const char *ln = nt_str(nt, v, "name");
    LocalVar *lv = s && ln ? scope_local(s, ln) : NULL;
    return lv && lv->is_param && lv->box_nullable;
  }
  return 0;
}

/* A local that was assigned a nilable Integer result carries the sentinel
   just as the call did: `i = s.index("z")` then `i == nil` has to answer
   true. The analysis marks the local (call_returns_nullable_int's local
   arm). */
int repr_local_nullable_int(Compiler *c, int node) {
  const NodeTable *nt = c->nt;
  const char *ln = nt_str(nt, node, "name");
  Scope *sc = ln ? comp_scope_of(c, node) : NULL;
  LocalVar *lv = sc ? scope_local(sc, ln) : NULL;
  return lv && lv->nullable_int;
}

Repr repr_of(const Compiler *c, int node) {
  Repr r;
  memset(&r, 0, sizeof r);
  r.ty = r.as_ty = r.narrowed = r.elem = r.key = r.val = TY_UNKNOWN;
  r.kind = RK_NONE;
  if (node < 0 || node >= c->nt->count) return r;
  r.ty = c->ntype[node];
  r.as_ty = comp_ntype(c, node);
  r.narrowed = c->nilnarrow ? c->nilnarrow[node] : TY_UNKNOWN;
  r.handle = c->strbuf_box[node] != 0;
  r.demand = c->strbuf_handle_demand[node] != 0;
  r.read_raw = c->strbuf_read_raw ? c->strbuf_read_raw[node] != 0 : 0;
  r.poly_lift = c->poly_strbuf_lift ? c->poly_strbuf_lift[node] != 0 : 0;
  r.nil_tested = c->nil_tested ? c->nil_tested[node] != 0 : 0;
  r.nil_cold = c->nil_tested ? c->nil_tested[node] == 2 : 0;
  /* a node is boxed as the type it is stored as; a nil-guard narrowing is
     read where the value is used, not where it is boxed */
  TyKind kt = r.as_ty;
  r.kind = (unsigned char)repr_kind_of_type(c, kt);
  r.dyn_cls = repr_dyn_cls(c, kt);
  repr_layout(&r, kt);
  if (repr_nil_scalar(c, node, kt)) {
    r.kind = RK_SENTINEL;
    r.may_nil = r.nil_scalar = 1;
  }
  r.strbuf_src = (unsigned char)repr_strbuf_src(c, node, kt);
  r.share = (unsigned)repr_static_share(c, node);
  if (r.strbuf_src == RS_SLOT_POLY) r.kind = RK_BOXED;
  else if (r.strbuf_src != RS_NONE) r.kind = RK_STRBUF;
  /* a user object the nil fact says may be nil (analyze_nil.c, #7444); a
     by-value one too, whose layout has no nil to hold it in; a builtin
     pointer (a String, an Array, a Hash, an IO) whose NULL is its nil, and
     a shared String's handle */
  if ((r.kind == RK_PTR || r.kind == RK_VOBJ || r.kind == RK_STRBUF) && nil_fact_tracked(kt) &&
      nil_fact_node(c, node))
    r.may_nil = 1;
  return r;
}

ReprForm repr_box_form(const Compiler *c, Repr r) {
  TyKind t = r.as_ty;
  switch ((ReprKind)r.kind) {
  case RK_NONE:     return RF_NIL_EFFECT;
  case RK_BOXED:    return RF_PASS;
  case RK_SENTINEL: return t == TY_FLOAT ? RF_FLT_NIL : RF_INT_NIL;
  case RK_STRUCT:   return RF_STRUCT;
  case RK_VOBJ:     return RF_VOBJ;
  case RK_STRBUF:
    return r.strbuf_src == RS_ELEM ? RF_STRBUF_ELEM
         : r.strbuf_src == RS_FRESH ? RF_STRBUF_FRESH : RF_STRBUF_HANDLE;
  case RK_SCALAR:
    switch (t) {
    case TY_INT:    return RF_INT;
    case TY_FLOAT:  return RF_FLT;
    case TY_BOOL:   return RF_BOOL;
    case TY_SYMBOL: return RF_SYM;
    default:        return RF_NIL_EFFECT;   /* nil */
    }
  case RK_PTR:
  default:
    break;
  }
  (void)c;
  if (t == TY_STRING) return RF_STR;
  if (r.big) return RF_BIGINT;
  /* an Array of pointers (objects, nested Arrays) is stamped with what its
     elements are */
  if (ty_is_object(r.elem) || ty_is_array(r.elem)) return RF_PTR_ARRAY;
  if (ty_is_object(t)) return r.dyn_cls ? RF_NULLABLE_DYN : RF_NULLABLE;
  return RF_NULLABLE;
}

const char *repr_form_name(int form) {
  static const char *const names[RF__COUNT] = {
    "PASS", "NIL_EFFECT", "INT", "INT_NIL", "FLT", "FLT_NIL", "BIGINT", "STR",
    "BOOL", "SYM", "STRUCT", "NULLABLE", "NULLABLE_DYN", "VOBJ",
    "STRBUF_HANDLE", "STRBUF_FRESH", "STRBUF_ELEM", "PTR_ARRAY", "YIELD", "SPECIAL",
  };
  return form >= 0 && form < RF__COUNT ? names[form] : "?";
}

/* The C value class of a kind: what C allows between two of them. */
int repr_store_class(const Compiler *c, TyKind t) {
  switch (t) {
    case TY_INT: case TY_FLOAT: case TY_BOOL: case TY_SYMBOL: return SC_ARITH;
    case TY_POLY: return SC_BOXED;
    case TY_UNKNOWN: case TY_VOID: case TY_NIL: return SC_NONE;
    default: break;
  }
  if (ty_is_object(t)) return comp_ty_value_obj(c, t) ? SC_STRUCT : SC_PTR;
  if (ty_is_struct_valued(t)) return SC_STRUCT;
  return c_type_name(t) ? SC_PTR : SC_NONE;
}

/* Does a value of kind `from`, written as it is, keep its value in a slot of
   kind `to`? The same C type does; so does an exact arithmetic widening
   (an Integer into a Float slot, a boolean into an Integer one), a nil
   literal's 0 in a pointer slot, which is NULL, and a subclass instance in
   its ancestor's pointer slot. A nil fits as it is only where it is a
   literal (repr_store_nil_fits). An untyped value's C type is whatever its
   emitter chose (a boxed result, the gate's token, a super call's String),
   which the kind does not say, so it is not checked. A void one fits
   nothing. */
/* A nil literal renders as 0, which is a pointer slot's NULL and a boolean's
   false: it is written as it is there, and into an operand a builtin
   converts itself (CO_CONVERT), whose nilable forms read the 0 as they
   always have. Any other nil value -- a call that answers nil, kept for its
   effect -- and a nil into a variable whose nil is a sentinel (an Integer,
   a Float, a Symbol) takes the slot's nil. */
int repr_store_nil_fits(Compiler *c, int node, TyKind slot, int how) {
  return node >= 0 && nt_kind(c->nt, node) == NK_NilNode &&
         (repr_store_class(c, slot) == SC_PTR || slot == TY_BOOL ||
          (how == CO_CONVERT && repr_store_class(c, slot) == SC_ARITH));
}

int repr_store_fits(Compiler *c, TyKind from, TyKind to) {
  if (from == to || to == TY_UNKNOWN || to == TY_VOID || from == TY_UNKNOWN) return 1;
  int fc = repr_store_class(c, from), tc = repr_store_class(c, to);
  if (from == TY_NIL) return 0;   /* see store_nil_fits */
  if (fc == SC_NONE) return 0;
  if (fc == SC_ARITH && tc == SC_ARITH) return from != TY_FLOAT || to == TY_FLOAT;
  if (ty_is_object(from) && ty_is_object(to) && fc == SC_PTR && tc == SC_PTR)
    return is_descendant(c, ty_object_class(from), ty_object_class(to));
  Buf fb, tb;
  memset(&fb, 0, sizeof fb); memset(&tb, 0, sizeof tb);
  emit_ctype(c, from, &fb); emit_ctype(c, to, &tb);
  int same = fb.p && tb.p && sp_streq(fb.p, tb.p);
  free(fb.p); free(tb.p);
  return same;
}

/* Would emit_empty_literal_as build `v` at the slot's kind? An empty
   literal, a bare Array.new or Hash.new, for an Array or Hash slot it has
   a constructor for. */
static int repr_empty_lit_as(Compiler *c, int v, TyKind slot) {
  const NodeTable *nt = c->nt;
  const char *vty = v >= 0 ? nt_type(nt, v) : NULL;
  if (!vty) return 0;
  int n = 0;
  if (sp_streq(vty, "ArrayNode")) {
    nt_arr(nt, v, "elements", &n);
    return !n && (ty_is_ptr_array(slot) || slot == TY_POLY_ARRAY || array_kind(slot));
  }
  if (sp_streq(vty, "HashNode") || sp_streq(vty, "KeywordHashNode")) {
    nt_arr(nt, v, "elements", &n);
    return !n && ty_is_hash(slot) && ty_hash_cname(slot);
  }
  if (sp_streq(vty, "CallNode") && node_is_empty_container(nt, v)) {
    const char *rn = nt_str(nt, nt_ref(nt, v, "receiver"), "name");
    if (rn && sp_streq(rn, "Hash") && ty_is_hash(slot) && ty_hash_cname(slot)) return 1;
    if (rn && sp_streq(rn, "Array"))
      return ty_is_ptr_array(slot) || slot == TY_POLY_ARRAY || array_kind(slot);
  }
  return 0;
}

/* Does emit_poly_rhs_coerced take a boxed value into a `slot` slot? An
   object through the checked unbox, a scalar or a String through its
   conversion. */
static int repr_poly_rhs_ok(TyKind slot) {
  return ty_is_object(slot) || slot == TY_INT || slot == TY_BOOL || slot == TY_FLOAT ||
         slot == TY_SYMBOL || slot == TY_STRING;
}

int repr_coerce_text_form(Compiler *c, int node, TyKind from, TyKind slot, int how) {
  if (repr_store_fits(c, from, slot) || (from == TY_NIL && repr_store_nil_fits(c, node, slot, how)))
    return CF_FIT;
  if (slot == TY_POLY) return CF_BOX;
  if (from == TY_VOID || from == TY_NIL) return CF_NIL_SENT;
  if (slot == TY_BIGINT && from == TY_INT) return CF_INT2BIG;
  if (how == CO_CONVERT && slot == TY_FLOAT && (from == TY_BIGINT || from == TY_RATIONAL))
    return CF_CONVERT;
  return CF_REFUSE;
}

int repr_coerce_plan(Compiler *c, int node, TyKind slot, int how, TyKind *from_out) {
  if (from_out) *from_out = TY_UNKNOWN;
  if (how == CO_CONVERT && slot == TY_BOOL) return CF_CONVERT;
  TyKind from = store_value_kind(c, node);
  if (from_out) *from_out = from;
  int container = ty_is_array(slot) || ty_is_hash(slot);
  if (from == TY_UNKNOWN && container && repr_empty_lit_as(c, node, slot)) return CF_EMPTY_LIT;
  if (repr_store_fits(c, from, slot) || (from == TY_NIL && repr_store_nil_fits(c, node, slot, how)))
    return CF_FIT;
  if (slot == TY_POLY) return CF_BOX;
  if (container && repr_empty_lit_as(c, node, slot)) return CF_EMPTY_LIT;
  if (from == TY_NIL && nt_kind(c->nt, node) == NK_NilNode) return CF_NIL_SENT;
  if (slot == TY_BIGINT && from == TY_INT) return CF_INT2BIG;
  if (from == TY_POLY && how == CO_HOLD) {
    if (repr_poly_rhs_ok(slot)) return CF_POLY_RHS;
    if (ty_is_array(slot) || ty_is_ptr_array(slot) || ty_is_hash(slot) || slot == TY_BIGINT ||
        slot == TY_STRBUF || slot == TY_CLASS || (ty_is_object(slot) && !repr_value_obj(c, slot)))
      return CF_CHECKED_UNBOX;
  }
  return repr_coerce_text_form(c, node, from, slot, how);
}

int repr_coerce_form(Compiler *c, int node, TyKind slot, int how) {
  return repr_coerce_plan(c, node, slot, how, NULL);
}

const char *repr_coerce_form_name(int form) {
  static const char *const names[CF__COUNT] = {
    "FIT", "BOX", "EMPTY_LIT", "NIL_SENT", "INT2BIG", "POLY_RHS", "CHECKED_UNBOX", "CONVERT", "REFUSE",
  };
  return form >= 0 && form < CF__COUNT ? names[form] : "?";
}

int g_repr_check = 0;

/* repr_of is a pure read: asked anywhere, it changes nothing. Under
   --repr-check codegen asks it of every node it is about to emit, which an
   ordinary compile does not, and repr_check.sh fails when the C then
   differs from the C without the flag: a type recorded while a view was
   open re-materialized a Range from its own temp. */
void repr_check_ask(const Compiler *c, int node) {
  if (node >= 0 && node < c->nt->count) (void)repr_of(c, node);
}

ReprKind repr_slot_kind(const Compiler *c, const LocalVar *lv) {
  if (!lv) return RK_NONE;
  /* an Integer or Float slot some write leaves nil in: its sentinel */
  if ((lv->type == TY_INT || lv->type == TY_FLOAT) &&
      (lv->nullable_int || lv->box_nullable || lv->maybe_unset))
    return RK_SENTINEL;
  return repr_kind_of_type(c, lv->type);
}
Repr repr_of_slot(const Compiler *c, const LocalVar *lv) {
  Repr r;
  memset(&r, 0, sizeof r);
  r.ty = r.as_ty = r.narrowed = r.elem = r.key = r.val = TY_UNKNOWN;
  r.kind = RK_NONE;
  if (!lv) return r;
  r.ty = r.as_ty = lv->type;
  repr_layout(&r, lv->type);
  ReprKind k = repr_slot_kind(c, lv);
  if (k == RK_SENTINEL) r.may_nil = 1;
  /* a `||=` can read the slot before any write: nil until then */
  if (lv->or_written) r.may_nil = 1;
  /* an object slot, or a builtin pointer's, the nil fact says may hold nil */
  if (nil_fact_tracked(lv->type) && lv->obj_may_nil) r.may_nil = 1;
  /* str_shared refines TY_STRBUF; it can outlive that storage type */
  if (lv->type == TY_STRBUF && lv->str_shared) r.handle = 1;
  /* under the rule, that handle is the one it assigned */
  r.share = r.handle && c->share_strings;
  r.elems_handle = lv->elems_shared && lv->type == TY_POLY_ARRAY;
  r.kind = (unsigned char)k;
  r.dyn_cls = repr_dyn_cls(c, lv->type);
  return r;
}

static void repr_share_seal(Compiler *c);

/* Method and constructor signatures pass a kept &block as sp_Proc *.
   Check the slot as well as expression boxing: a read can infer Proc even
   when a copied parameter's local was left untyped and widened to POLY. */
static void repr_check_block_params(Compiler *c) {
  for (int si = 1; si < c->nscopes; si++) {
    Scope *sc = &c->scopes[si];
    if (!sc->blk_param || !sc->blk_param[0] || sc->yields) continue;
    LocalVar *lv = scope_local(sc, sc->blk_param);
    Repr r = repr_of_slot(c, lv);
    if (!lv || !lv->is_param || r.ty != TY_PROC || r.kind != RK_PTR)
      fprintf(stderr, "repr-check: conflict: method %s block parameter %s: "
              "slot %s, signature sp_Proc *\n", sc->name ? sc->name : "?",
              sc->blk_param, ty_name(r.ty));
  }
}

void repr_seal(Compiler *c) {
  if (g_repr_check) repr_check_block_params(c);
  if (c->share_strings) repr_share_seal(c);
  repr_sealed_flag = 1;
}

int repr_sealed(void) { return repr_sealed_flag; }

/* ---- --share-strings (#6765) ---- */

int repr_static_read_kind(NodeKind k) {
  return k == NK_GlobalVariableReadNode || k == NK_ConstantReadNode || k == NK_ConstantPathNode ||
         k == NK_ClassVariableReadNode;
}
/* repr_of's `share` for a read or write node of a global, a constant or a
   class variable: its slot's (only the rule makes one the handle) */
int repr_static_share(const Compiler *c, int node) {
  HolderRef h;
  if (node < 0 || !c->share_strings || !holder_static_node(nt_kind(c->nt, node))) return 0;
  return holder_of_node(c, node, &h) && h.r.share;
}

int repr_str_class_shares(unsigned flags, int holders) {
  if (!(flags & SHF_MUT)) return 0;
  return holders >= 2 || (flags & (SHF_UNKNOWN | SHF_INDIRECT | SHF_MULTI)) != 0;
}

int repr_str_shares(const Compiler *c, int holder) {
  if (!c->share_strings || !c->share || holder < 0) return 0;
  return repr_str_class_shares(share_class_flags(c, holder), share_class_holders(c, holder));
}

int repr_str_elems_share(const Compiler *c, int holder) {
  if (!c->share_strings || !c->share || holder < 0) return 0;
  int e = share_elem_holder(c, holder);
  return e >= 0 && repr_str_class_shares(share_elem_flags(c, e), share_elem_holders(c, e));
}

/* The representation of share holder h's slot, now that the analysis is
   final: a box (RK_BOXED) holds whatever is stored, the handle included;
   `share` says the slot is the handle. A byref-out local is not (its slot
   is the caller's), and a class variable is every class's of the name (the
   facts key it by name alone): boxed if one is, and the handle only if
   every String one is. ty is TY_UNKNOWN for a holder with no slot. */
static Repr repr_of_share_holder(Compiler *c, const ShareHolder *h) {
  Repr r;
  memset(&r, 0, sizeof r);
  r.ty = r.as_ty = TY_UNKNOWN;
  switch (h->kind) {
  case SHK_LOCAL: {
    LocalVar *lv = &c->scopes[h->scope].locals[h->local];
    r = repr_of_slot(c, lv);
    if (lv->byref_out) r.share = 0;
    break;
  }
  case SHK_IVAR: {
    int iv = comp_ivar_index(&c->classes[h->cid], h->name);
    if (iv >= 0) r = repr_of_ivar(c, h->cid, iv);
    break;
  }
  case SHK_GVAR: {
    LocalVar *gv = comp_gvar(c, h->name[0] == '$' ? h->name + 1 : h->name);
    if (gv) r = repr_of_slot(c, gv);
    break;
  }
  case SHK_CONST: {
    LocalVar *cv = h->name ? comp_const(c, h->name) : NULL;
    if (cv) r = repr_of_slot(c, cv);
    break;
  }
  case SHK_CVAR:
    for (int k = 0; k < c->nclasses; k++) {
      int i = h->name ? comp_cvar_index(&c->classes[k], h->name) : -1;
      if (i < 0) continue;
      Repr ck = repr_of_cvar(c, k, i);
      if (ck.ty == TY_POLY) { ck.kind = RK_BOXED; return ck; }
      if (ck.share) r = ck;
      else if (ck.ty == TY_STRING || ck.ty == TY_STRBUF) return ck;
    }
    break;
  default:
    break;
  }
  if (r.ty == TY_POLY) r.kind = RK_BOXED;
  return r;
}

/* A container holder whose elements share: are they boxed (a box holds the
   handle), or typed Strings (`const char *` elements)? 1, 0, or -1 for a
   holder that is no container. */
static int repr_share_elems_carried(Compiler *c, const ShareHolder *h) {
  TyKind t = TY_UNKNOWN;
  if (h->kind == SHK_LOCAL) t = c->scopes[h->scope].locals[h->local].type;
  else if (h->kind == SHK_IVAR) {
    int iv = comp_ivar_index(&c->classes[h->cid], h->name);
    if (iv < 0) return -1;
    t = c->classes[h->cid].ivar_types[iv];
  }
  if (!ty_is_array(t) && !ty_is_hash(t)) return -1;
  return t == TY_STR_ARRAY || t == TY_STR_STR_HASH || t == TY_INT_STR_HASH ? 0 : 1;
}

static const char *repr_share_kind_name(int kind) {
  switch (kind) {
  case SHK_LOCAL: return "variable";
  case SHK_IVAR:  return "instance variable";
  case SHK_GVAR:  return "global variable";
  case SHK_CVAR:  return "class variable";
  case SHK_CONST: return "constant";
  default:        return "value";
  }
}

/* The analysis is final: every holder the rule shares has to hold the
   handle now. One whose kind cannot carry it yet is refused, naming it,
   rather than compiled holding a copy. SPINEL_SHARE_STATS=1 reports what
   the rule decided. */
static void repr_share_seal(Compiler *c) {
  share_facts_build(c);
  int nh = share_holder_count(c);
  int bad = -1, bad_elems = 0;
  int n_str = 0, n_shared = 0, n_kind[SHK_UNKNOWN + 1] = {0}, n_param = 0, n_elems = 0;
  int n_route_only = 0, n_unknown = 0;
  const char *stats = getenv("SPINEL_SHARE_STATS");
  struct ShareFacts *closed = stats ? share_facts_build_closed(c) : NULL;
  for (int h = 0; h < nh; h++) {
    const ShareHolder *sh = share_holder(c, h);
    int ec = repr_share_elems_carried(c, sh);
    if (ec >= 0 && repr_str_elems_share(c, h)) {
      n_elems++;
      if (!ec && bad < 0) { bad = h; bad_elems = 1; }
    }
    /* does the holder hold the shared handle (a box holds what is stored,
       the handle included)? -1 for one that holds no String */
    Repr hr = repr_of_share_holder(c, sh);
    int carried = hr.kind == RK_BOXED || hr.share ? 1 : hr.ty == TY_STRING || hr.ty == TY_STRBUF ? 0 : -1;
    if (carried < 0) continue;
    n_str++;
    int shares = repr_str_shares(c, h);
    if (!shares) {
      /* a handle a route rule made that the rule does not ask for */
      if (carried && sh->kind != SHK_CVAR && sh->kind != SHK_CONST &&
          !(sh->kind == SHK_LOCAL && c->scopes[sh->scope].locals[sh->local].type == TY_POLY) &&
          !(sh->kind == SHK_IVAR && c->classes[sh->cid].ivar_types[comp_ivar_index(&c->classes[sh->cid], sh->name)] == TY_POLY) &&
          !(sh->kind == SHK_GVAR && carried == 1 && comp_gvar(c, sh->name[0] == '$' ? sh->name + 1 : sh->name)->type == TY_POLY))
        n_route_only++;
      continue;
    }
    n_shared++;
    n_kind[sh->kind]++;
    if (sh->kind == SHK_LOCAL && c->scopes[sh->scope].locals[sh->local].is_param) n_param++;
    if (closed && !share_closed_shares(closed, sh)) n_unknown++;
    if (!carried && bad < 0) bad = h;
  }
  /* a container literal no holder names, whose elements the rule shares
     only once the facts settle after the fixpoint, kept a typed String
     form: its elements would be copies */
  int bad_lit = -1;
  for (int n = 0; n < c->nt->count && bad_lit < 0; n++) {
    NodeKind k = nt_kind(c->nt, n);
    if (k != NK_ArrayNode && k != NK_HashNode) continue;
    TyKind t = c->ntype[n];
    int ne = 0;
    nt_arr(c->nt, n, "elements", &ne);
    /* an empty one holds no String yet: what is stored later goes through
       the holder that keeps it; one nothing can reach again once its
       expression is done (`p [a, b]`) keeps no name for its copies */
    if (ne > 0 && (t == TY_STR_ARRAY || t == TY_STR_STR_HASH || t == TY_INT_STR_HASH) && share_node_elems_share(c, n) &&
        share_node_anchored(c, n))
      bad_lit = n;
  }
  if (stats && stats[0] == '3') share_dump_unknown_mutations(c);
  if (stats && stats[0] == '2')
    for (int h = 0; h < nh; h++) {
      const ShareHolder *sh = share_holder(c, h);
      const char *nm = sh->kind == SHK_LOCAL ? c->scopes[sh->scope].locals[sh->local].name : sh->name;
      fprintf(stderr, "share-holder: %s %s%s%s flags=%u holders=%d shares=%d elems-share=%d\n",
              repr_share_kind_name(sh->kind), nm ? nm : "?",
              sh->kind == SHK_LOCAL ? " in " : "",
              sh->kind == SHK_LOCAL ? (c->scopes[sh->scope].name ? c->scopes[sh->scope].name : "<top>") : "",
              share_class_flags(c, h), share_class_holders(c, h), repr_str_shares(c, h),
              repr_str_elems_share(c, h));
    }
  if (stats) {
    fprintf(stderr, "share-stats: string-holders=%d shared=%d local=%d (param=%d) ivar=%d gvar=%d "
            "cvar=%d const=%d containers=%d via-unknown=%d route-only=%d refused=%d borrows=%d\n",
            n_str, n_shared, n_kind[SHK_LOCAL], n_param, n_kind[SHK_IVAR], n_kind[SHK_GVAR],
            n_kind[SHK_CVAR], n_kind[SHK_CONST], n_elems, n_unknown, n_route_only, bad >= 0,
            c->share_borrows);
    share_facts_drop(closed);
  }
  /* a route master refuses, left to the rule: refused as master does
     unless the final facts share its String */
  share_routes_check(c);
  if (bad < 0 && bad_lit >= 0)
    unsupported_feature(c, bad_lit, "under --share-strings, the Strings this literal holds are shared with "
                        "another name and changed in place, and a typed String container cannot hold the "
                        "shared handle yet (#6765)");
  if (bad >= 0) {
    const ShareHolder *sh = share_holder(c, bad);
    char nm[160];
    if (sh->kind == SHK_LOCAL) snprintf(nm, sizeof nm, "`%s`", c->scopes[sh->scope].locals[sh->local].name);
    else snprintf(nm, sizeof nm, "`%s`", sh->name ? sh->name : "?");
    const char *kind = sh->kind == SHK_LOCAL && c->scopes[sh->scope].locals[sh->local].is_block_param
                       ? "block parameter" : repr_share_kind_name(sh->kind);
    char msg[512];
    if (bad_elems)
      snprintf(msg, sizeof msg, "under --share-strings, the Strings %s %s holds are shared with another "
               "name and changed in place, and a typed String container cannot hold the shared handle "
               "yet (#6765)", kind, nm);
    else
      snprintf(msg, sizeof msg, "under --share-strings, the String %s %s holds is shared with another "
               "name and changed in place, and a %s cannot hold the shared handle yet (#6765)",
               kind, nm, kind);
    unsupported_feature(c, sh->node, msg);
  }
}

/* ---- --dump-repr (#7501) ----
   One line per slot with the representation chosen for it, sorted, so the
   dumps two compilers give for one program can be diffed. A slot that
   became a shared handle or a box, or left a by-value layout, costs at run
   time without changing any output (#7482), and this is where it shows.
   Locals, parameters, globals and constants are LocalVars and read through
   repr_of_slot. An ivar and a method's value are not: they read their own
   flags by the same rules. The dump only reads. It is taken once the
   analysis is final and printed once the compile has passed, so a program
   codegen refuses fails as a compile does; no C is written. */
int g_dump_repr = 0;

static const char *repr_kind_name(int k) {
  static const char *const names[] = {
    "none", "scalar", "sentinel", "struct", "vobj", "ptr", "strbuf", "boxed",
  };
  return k >= 0 && k <= RK_BOXED ? names[k] : "?";
}

/* an ivar's slot: every Integer ivar reads nil until written, as
   repr_nil_scalar answers for its reads; a Float one when some write can
   leave the sentinel */
Repr repr_of_ivar(const Compiler *c, int cid, int iv) {
  const ClassInfo *ci = &c->classes[cid];
  Repr r;
  memset(&r, 0, sizeof r);
  r.ty = r.as_ty = ci->ivar_types[iv];
  r.narrowed = TY_UNKNOWN;
  r.kind = (unsigned char)repr_kind_of_type(c, r.ty);
  if (r.ty == TY_INT || (r.ty == TY_FLOAT && ci->ivar_nullable_int[iv])) {
    r.kind = RK_SENTINEL;
    r.may_nil = 1;
  }
  if (ty_is_object(r.ty) && nil_fact_ivar(c, cid, ci->ivars[iv])) r.may_nil = 1;
  if (r.ty == TY_STRBUF && ci->ivar_str_shared[iv]) r.handle = 1;
  r.share = r.handle && c->share_strings;
  r.dyn_cls = repr_dyn_cls(c, r.ty);
  return r;
}

/* a class variable's slot, as an ivar's: an Integer or Float one some
   write leaves nil in holds the sentinel */
ReprKind repr_cvar_kind(const Compiler *c, int cid, int idx) {
  const ClassInfo *ci = &c->classes[cid];
  TyKind t = ci->cvar_types[idx];
  if ((t == TY_INT || t == TY_FLOAT) && ci->cvar_nullable_int[idx]) return RK_SENTINEL;
  return repr_kind_of_type(c, t);
}
/* Only the rule makes a class variable the shared handle
   (cvar_str_shared). An object one has no nil fact (analyze_nil.c keeps
   one per ivar): it may be nil, as nil_fact_ivar answers for an ivar it
   has none for. */
Repr repr_of_cvar(const Compiler *c, int cid, int idx) {
  const ClassInfo *ci = &c->classes[cid];
  Repr r;
  memset(&r, 0, sizeof r);
  r.ty = r.as_ty = ci->cvar_types[idx];
  r.narrowed = r.elem = r.key = r.val = TY_UNKNOWN;
  repr_layout(&r, r.ty);
  r.kind = (unsigned char)repr_cvar_kind(c, cid, idx);
  if (r.kind == RK_SENTINEL || ty_is_object(r.ty)) r.may_nil = 1;
  if (r.ty == TY_STRBUF && ci->cvar_str_shared[idx]) r.handle = 1;
  r.share = r.handle && c->share_strings;
  r.dyn_cls = repr_dyn_cls(c, r.ty);
  return r;
}

/* a method's value: its nilable scalar is the sentinel */
static Repr repr_of_ret(const Compiler *c, const Scope *sc) {
  Repr r;
  memset(&r, 0, sizeof r);
  r.ty = r.as_ty = sc->ret;
  r.narrowed = TY_UNKNOWN;
  r.kind = (unsigned char)repr_kind_of_type(c, r.ty);
  if ((r.ty == TY_INT || r.ty == TY_FLOAT) && (sc->ret_nullable_int || sc->ret_rbs_nilable)) {
    r.kind = RK_SENTINEL;
    r.may_nil = 1;
  }
  if (ty_is_object(r.ty) && sc->ret_obj_may_nil) r.may_nil = 1;
  r.dyn_cls = repr_dyn_cls(c, r.ty);
  return r;
}

/* a type's name, with the class of a user object or of an object array */
static void repr_dump_ty(const Compiler *c, TyKind t, char *out, size_t n) {
  TyKind e = ty_is_obj_array(t) ? ty_array_elem(t) : t;
  if (ty_is_object(e) && ty_object_class(e) < c->nclasses)
    snprintf(out, n, "%s%s", ty_is_obj_array(t) ? "obj_array:" : "obj:",
             c->classes[ty_object_class(e)].name);
  else snprintf(out, n, "%s", ty_name(t));
}

typedef struct { char **v; int n, cap; } ReprLines;

static void repr_dump_line(const Compiler *c, ReprLines *ls, const char *where, Repr r) {
  char ty[256], line[1024];
  repr_dump_ty(c, r.ty, ty, sizeof ty);
  snprintf(line, sizeof line, "%s: %s ty=%s%s%s%s", where, repr_kind_name(r.kind), ty,
           r.handle ? " handle" : "", r.may_nil ? " may_nil" : "", r.dyn_cls ? " dyn_cls" : "");
  if (ls->n == ls->cap) {
    ls->cap = ls->cap ? ls->cap * 2 : 64;
    ls->v = realloc(ls->v, (size_t)ls->cap * sizeof *ls->v);
  }
  ls->v[ls->n++] = strdup(line);
}

static int repr_line_cmp(const void *a, const void *b) {
  return strcmp(*(char *const *)a, *(char *const *)b);
}

/* A method's name as the dump prints it: Class#m, Class.m for a class
   method, <main> for the top level, and a mark for each copy of a method
   another scope also emits. */
static void repr_scope_label(const Compiler *c, const Scope *sc, char *out, size_t n) {
  const char *cls = sc->class_id >= 0 && sc->class_id < c->nclasses ? c->classes[sc->class_id].name : NULL;
  snprintf(out, n, "%s%s%s%s%s%s", cls ? cls : "", cls ? (sc->is_cmethod ? "." : "#") : "",
           sc->name ? sc->name : "<main>", sc->is_proc_form ? "(proc)" : "",
           sc->is_include_copy ? "(include)" : "", sc->is_extend_copy ? "(extend)" : "");
}

char *repr_dump(const Compiler *c) {
  ReprLines ls = {0};
  char where[1024], label[512];
  for (int si = 0; si < c->nscopes; si++) {
    const Scope *sc = &c->scopes[si];
    /* a method nothing calls is not run */
    if (sc->def_node >= 0 && !sc->reachable) continue;
    repr_scope_label(c, sc, label, sizeof label);
    for (int k = 0; k < sc->nlocals; k++) {
      const LocalVar *lv = &sc->locals[k];
      if (!lv->name) continue;
      snprintf(where, sizeof where, "%s %s %s", lv->is_param ? "param" : "local", label, lv->name);
      repr_dump_line(c, &ls, where, repr_of_slot(c, lv));
    }
    if (sc->def_node >= 0) {
      snprintf(where, sizeof where, "ret %s", label);
      repr_dump_line(c, &ls, where, repr_of_ret(c, sc));
    }
  }
  for (int cid = 0; cid < c->nclasses; cid++)
    for (int iv = 0; iv < c->classes[cid].nivars; iv++) {
      snprintf(where, sizeof where, "ivar %s %s", c->classes[cid].name, c->classes[cid].ivars[iv]);
      repr_dump_line(c, &ls, where, repr_of_ivar(c, cid, iv));
    }
  for (int k = 0; k < c->ngvars; k++) {
    snprintf(where, sizeof where, "gvar $%s", c->gvars[k].name);
    repr_dump_line(c, &ls, where, repr_of_slot(c, &c->gvars[k]));
  }
  for (int k = 0; k < c->nconsts; k++) {
    snprintf(where, sizeof where, "const %s", c->consts[k].name);
    repr_dump_line(c, &ls, where, repr_of_slot(c, &c->consts[k]));
  }
  qsort(ls.v, (size_t)ls.n, sizeof *ls.v, repr_line_cmp);
  size_t len = 1;
  for (int k = 0; k < ls.n; k++) len += strlen(ls.v[k]) + 1;
  char *out = malloc(len), *o = out;
  for (int k = 0; k < ls.n; k++) {
    size_t n = strlen(ls.v[k]);
    memcpy(o, ls.v[k], n);
    o[n] = '\n';
    o += n + 1;
    free(ls.v[k]);
  }
  *o = 0;
  free(ls.v);
  return out;
}

int repr_share_rule(const Compiler *c) { return c->share_strings; }
