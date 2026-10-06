/* holder.c -- the variable a node names, and its C slot (see holder.h). */

#include <string.h>
#include "holder.h"
#include "codegen_internal.h"
#include "share.h"

HolderKind holder_kind_of(NodeKind k) {
  switch (k) {
  case NK_LocalVariableReadNode: case NK_LocalVariableWriteNode: case NK_LocalVariableOrWriteNode:
  case NK_LocalVariableAndWriteNode: case NK_LocalVariableOperatorWriteNode: case NK_LocalVariableTargetNode:
    return HK_LOCAL;
  case NK_InstanceVariableReadNode: case NK_InstanceVariableWriteNode: case NK_InstanceVariableOrWriteNode:
  case NK_InstanceVariableAndWriteNode: case NK_InstanceVariableOperatorWriteNode:
  case NK_InstanceVariableTargetNode:
    return HK_IVAR;
  case NK_GlobalVariableReadNode: case NK_GlobalVariableWriteNode: case NK_GlobalVariableOrWriteNode:
  case NK_GlobalVariableAndWriteNode: case NK_GlobalVariableOperatorWriteNode: case NK_GlobalVariableTargetNode:
    return HK_GVAR;
  case NK_ClassVariableReadNode: case NK_ClassVariableWriteNode: case NK_ClassVariableOrWriteNode:
  case NK_ClassVariableAndWriteNode: case NK_ClassVariableOperatorWriteNode: case NK_ClassVariableTargetNode:
    return HK_CVAR;
  case NK_ConstantReadNode: case NK_ConstantPathNode: case NK_ConstantWriteNode: case NK_ConstantOrWriteNode:
  case NK_ConstantAndWriteNode: case NK_ConstantOperatorWriteNode: case NK_ConstantTargetNode:
  case NK_ConstantPathTargetNode:
    return HK_CONST;
  default:
    return HK_NONE;
  }
}

int holder_static_node(NodeKind k) {
  HolderKind hk = holder_kind_of(k);
  return (hk == HK_GVAR || hk == HK_CVAR || hk == HK_CONST) && k != NK_GlobalVariableTargetNode &&
         k != NK_ClassVariableTargetNode && k != NK_ConstantTargetNode && k != NK_ConstantPathTargetNode;
}

int holder_scope_class(const Compiler *c, int node, int body) {
  Scope *s = comp_scope_of((Compiler *)c, node);
  if (!s) return -1;
  int k = s->class_id >= 0 ? s->class_id : body;
  if (k < 0) k = comp_class_index((Compiler *)c, "Toplevel");
  return k;
}

int holder_cbody(const Compiler *c, int node) {
  return c->node_cbody && node >= 0 && node < c->node_cap ? c->node_cbody[node] : -1;
}

int holder_cvar_owner(const Compiler *c, int node, const char *nm, int body) {
  int k = nm ? holder_scope_class(c, node, body) : -1;
  return k >= 0 ? comp_cvar_owner(c, k, nm) : -1;
}

void holder_ivar(const Compiler *c, int node, int cid, int cls_slot, HolderRef *out) {
  memset(out, 0, sizeof *out);
  out->kind = HK_IVAR;
  out->node = node;
  out->name = nt_str(c->nt, node, "name");
  out->cid = cid;
  out->cls_slot = (unsigned char)(cls_slot != 0);
  out->idx = cid >= 0 && out->name ? comp_ivar_index(&c->classes[cid], out->name) : -1;
  out->share_h = cid >= 0 ? share_ivar_holder(c, cid, out->name) : -1;
  out->r = repr_of_holder(c, out);
}

int holder_of_node(const Compiler *c, int node, HolderRef *out) {
  return holder_of_node_in(c, node, holder_cbody(c, node), out);
}

int holder_of_node_in(const Compiler *c, int node, int body, HolderRef *out) {
  Compiler *mc = (Compiler *)c;
  HolderKind hk = node >= 0 ? holder_kind_of(nt_kind(c->nt, node)) : HK_NONE;
  const char *nm = hk != HK_NONE ? nt_str(c->nt, node, "name") : NULL;
  /* *out is defined on every answer: a caller may spell it whatever this
     answered */
  memset(out, 0, sizeof *out);
  out->cid = out->idx = out->share_h = -1;
  if (!nm) return 0;
  if (hk == HK_IVAR) {
    /* the read side's rule, which repr_of and the String-handle readers
       follow: a class method's ivar is its class's global, a top-level
       method's the Toplevel's */
    int cid = strbuf_ivar_owner(mc, node);
    if (cid < 0) return 0;
    Scope *s = comp_scope_of(mc, node);
    holder_ivar(c, node, cid, s->class_id < 0 || s->is_cmethod, out);
    return 1;
  }
  out->kind = (unsigned char)hk;
  out->node = node;
  out->name = nm;
  switch (hk) {
  case HK_LOCAL: {
    Scope *s = comp_scope_of(mc, node);
    out->lv = s ? scope_local(s, nm) : NULL;
    if (!out->lv) return 0;
    out->share_h = share_local_holder(c, (int)(s - c->scopes), (int)(out->lv - s->locals));
    break;
  }
  case HK_GVAR: {
    const char *rn = nm[0] == '$' ? comp_resolve_gvar(mc, nm + 1) : NULL;
    out->lv = rn ? comp_gvar(mc, rn) : NULL;
    if (!out->lv) return 0;
    break;
  }
  case HK_CONST:
    out->lv = comp_const(mc, nm);
    if (!out->lv) return 0;
    break;
  case HK_CVAR:
    out->cid = holder_cvar_owner(c, node, nm, body);
    if (out->cid < 0) return 0;
    out->idx = comp_cvar_index(&c->classes[out->cid], nm);
    break;
  default:
    return 0;
  }
  out->r = repr_of_holder(c, out);
  return 1;
}

Repr repr_of_holder(const Compiler *c, const HolderRef *h) {
  Repr r;
  switch (h->kind) {
  case HK_LOCAL: case HK_GVAR: case HK_CONST:
    if (h->lv) return repr_of_slot(c, h->lv);
    break;
  case HK_IVAR:
    if (h->idx >= 0) return repr_of_ivar(c, h->cid, h->idx);
    break;
  case HK_CVAR:
    if (h->idx >= 0) return repr_of_cvar(c, h->cid, h->idx);
    break;
  default:
    break;
  }
  memset(&r, 0, sizeof r);
  r.ty = r.as_ty = r.narrowed = r.elem = r.key = r.val = TY_UNKNOWN;
  return r;
}

int holder_slot_text(Compiler *c, const HolderRef *h, char *out, size_t cap) {
  switch (h->kind) {
  case HK_LOCAL: {
    /* via emit_local_ref: a celled or captured local derefs its cell */
    Buf rb; memset(&rb, 0, sizeof rb);
    emit_local_ref(c, h->node, h->name, &rb);
    snprintf(out, cap, "%s", rb.p ? rb.p : "");
    free(rb.p);
    return 1;
  }
  case HK_IVAR:
    if (h->cls_slot) snprintf(out, cap, "civ_%s_%s", c->classes[h->cid].name, iv_c(h->name + 1));
    else snprintf(out, cap, "%s%siv_%s", g_self, g_self_deref, iv_c(h->name + 1));
    return 1;
  case HK_GVAR:
    snprintf(out, cap, "gv_%s", h->lv->name);
    return 1;
  case HK_CONST:
    snprintf(out, cap, "cst_%s", h->lv->name);
    return 1;
  case HK_CVAR:
    snprintf(out, cap, "cvar_%s_%s", c->classes[h->cid].name, h->name + 2);
    return 1;
  default:
    return 0;
  }
}

int holder_static_handle_text(Compiler *c, int node, char *out, size_t cap) {
  HolderRef h;
  if (!c->share_strings || !holder_static_node(nt_kind(c->nt, node)) || !holder_of_node(c, node, &h) || !h.r.share)
    return 0;
  return holder_slot_text(c, &h, out, cap);
}
