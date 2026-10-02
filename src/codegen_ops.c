/* codegen_ops.c -- the emitters behind builtin_ops rows.

   emit_builtin_op looks the call up in the builtin-op table and runs the
   row's emitter. It sits where the receiver families it covers sat in
   emit_call_body, so the chain above it still claims what it claimed. */

#include "codegen_internal.h"
#include "builtin_ops.h"

/* (recv).name: a field of a receiver held as a by-value C struct, the way
   Process::Tms keeps its four times. */
static int emit_op_struct_field(Compiler *c, const BopCtx *x, Buf *b) {
  buf_puts(b, "("); emit_expr(c, x->recv, b); buf_printf(b, ").%s", x->name);
  return 1;
}

static int (*const bop_emitters[BOPE__COUNT])(Compiler *, const BopCtx *, Buf *) = {
  [BOPE_NONE] = NULL,
  [BOPE_STRUCT_FIELD] = emit_op_struct_field,
};

int emit_builtin_op(Compiler *c, int id, int recv, TyKind rt, const char *name, Buf *b) {
  if (recv < 0 || !bop_covers(rt)) return 0;
  int argc;
  call_args(c->nt, id, &argc);
  const BuiltinOp *op = bop_find(rt, name, argc, nt_ref(c->nt, id, "block") >= 0);
  if (!op || op->emit == BOPE_NONE || !bop_emitters[op->emit]) return 0;
  BopCtx x = { id, recv, argc, rt, name, op };
  return bop_emitters[op->emit](c, &x, b);
}
