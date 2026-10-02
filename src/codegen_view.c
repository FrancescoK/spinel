/* codegen_view.c -- a node seen as another kind for one nested emission.

   Codegen re-enters an emitter with a node's cached type overridden: a
   Range receiver materialized to an IntArray temp, a poly receiver inside
   one dispatch arm, a call typed boxed for the arm that asks so. The
   override holds for that emission only and the node's own type comes
   back after it.

   view_push / view_pop make each such episode one bracketed pair on one
   stack, so the overrides are visible in one place (#7100). While the
   stack is not empty, what codegen reads for those nodes is a view, not
   the analysis's answer: anything that caches a decision per node must
   cache only at view depth 0, or key it on view_epoch().

   view_push_repr does the same for one of the representation flags beside
   the type (repr.h): a String-handle mark or demand, a poly-to-handle lift,
   a read's nil narrowing. The emitters that re-enter with a flag lifted or
   forced push it as a view, so a refusal's view_unwind puts it back with
   the rest. repr_of reads the flags live and memoizes nothing. */

#include "codegen_internal.h"

#define VIEW_MAX 256

/* what an entry overrides: the node's type, or one representation flag */
enum { VK_TYPE = -1 };
static struct { Compiler *c; int id; int kind; int saved; } view_stack[VIEW_MAX];
static int view_sp;
static unsigned view_epoch_n;

unsigned view_epoch(void) { return view_epoch_n; }

/* the slot an entry of `kind` names for node `id` */
static int view_read(Compiler *c, int kind, int id) {
  switch (kind) {
  case VK_TYPE:          return (int)c->ntype[id];
  case VR_STRBUF_BOX:    return c->strbuf_box[id];
  case VR_HANDLE_DEMAND: return c->strbuf_handle_demand[id];
  case VR_POLY_LIFT:     return c->poly_strbuf_lift[id];
  default:               return (int)c->nilnarrow[id];
  }
}
static void view_write(Compiler *c, int kind, int id, int v) {
  switch (kind) {
  case VK_TYPE:          c->ntype[id] = (TyKind)v; break;
  case VR_STRBUF_BOX:    c->strbuf_box[id] = (unsigned char)v; break;
  case VR_HANDLE_DEMAND: c->strbuf_handle_demand[id] = (unsigned char)v; break;
  case VR_POLY_LIFT:     c->poly_strbuf_lift[id] = (unsigned char)v; break;
  default:               c->nilnarrow[id] = (TyKind)v; break;
  }
}

static int view_open(Compiler *c, int id, int kind, int v) {
  if (view_sp >= VIEW_MAX) {
    fprintf(stderr, "spinel: internal error: codegen views nested too deep\n");
    exit(1);
  }
  int tok = view_sp++;
  view_stack[tok].c = c;
  view_stack[tok].id = id;
  view_stack[tok].kind = kind;
  view_stack[tok].saved = view_read(c, kind, id);
  view_write(c, kind, id, v);
  view_epoch_n++;
  return tok;
}

int view_push(Compiler *c, int id, TyKind t) { return view_open(c, id, VK_TYPE, (int)t); }

int view_push_repr(Compiler *c, int id, int flag, int v) { return view_open(c, id, flag, v); }

void view_pop(Compiler *c, int tok) {
  if (tok != view_sp - 1) {
    fprintf(stderr, "spinel: internal error: codegen view popped out of order\n");
    exit(1);
  }
  view_sp--;
  view_write(c, view_stack[tok].kind, view_stack[tok].id, view_stack[tok].saved);
  view_epoch_n++;
}

int view_depth(void) { return view_sp; }

/* A refusal longjmps out of an emission past its view_pop. The recovery
   point saved the depth before it and puts back every view opened since,
   the latest first, so a dropped arm leaves no node seen as another kind. */
void view_unwind(int depth) {
  while (view_sp > depth) {
    view_sp--;
    view_write(view_stack[view_sp].c, view_stack[view_sp].kind, view_stack[view_sp].id,
               view_stack[view_sp].saved);
    view_epoch_n++;
  }
}
