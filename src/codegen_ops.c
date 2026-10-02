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

/* The receiver's C text, emitted once: an emitter that names it twice
   prints the same text twice, as the arms it replaces did. */
static char *op_recv_text(Compiler *c, const BopCtx *x) {
  Buf r; memset(&r, 0, sizeof r);
  emit_expr(c, x->recv, &r);
  if (!r.p) return strdup("NULL");
  return r.p;
}

/* (recv)->arg: a field of a receiver held behind a pointer */
static int emit_op_ptr_field(Compiler *c, const BopCtx *x, Buf *b) {
  char *r = op_recv_text(c, x);
  buf_printf(b, "(%s)->%s", r, x->op->arg);
  free(r);
  return 1;
}

static int emit_op_ptr_nonzero(Compiler *c, const BopCtx *x, Buf *b) {
  char *r = op_recv_text(c, x);
  buf_printf(b, "((%s)->%s != 0)", r, x->op->arg);
  free(r);
  return 1;
}

/* arg(recv): a runtime function of the receiver alone */
static int emit_op_call_recv(Compiler *c, const BopCtx *x, Buf *b) {
  char *r = op_recv_text(c, x);
  buf_printf(b, "%s(%s)", x->op->arg, r);
  free(r);
  return 1;
}

/* An Addrinfo's family name compared with arg. strcmp, not sp_str_eq:
   sp_str_eq confirms a hit by comparing byte lengths, and reading the
   length of a bare C literal reads its s[-1] marker, out of bounds;
   afname is NUL-free, so plain strcmp is both correct and what
   sp_addrinfo_inspect already uses. */
static int emit_op_afname_is(Compiler *c, const BopCtx *x, Buf *b) {
  char *r = op_recv_text(c, x);
  buf_printf(b, "((%s)->afname && strcmp((%s)->afname, \"%s\") == 0)", r, r, x->op->arg);
  free(r);
  return 1;
}

static int emit_op_afname_is_not(Compiler *c, const BopCtx *x, Buf *b) {
  char *r = op_recv_text(c, x);
  buf_printf(b, "(!((%s)->afname && strcmp((%s)->afname, \"%s\") == 0))", r, r, x->op->arg);
  free(r);
  return 1;
}

static int (*const bop_emitters[BOPE__COUNT])(Compiler *, const BopCtx *, Buf *) = {
  [BOPE_NONE] = NULL,
  [BOPE_STRUCT_FIELD] = emit_op_struct_field,
  [BOPE_PTR_FIELD] = emit_op_ptr_field,
  [BOPE_PTR_NONZERO] = emit_op_ptr_nonzero,
  [BOPE_CALL_RECV] = emit_op_call_recv,
  [BOPE_AFNAME_IS] = emit_op_afname_is,
  [BOPE_AFNAME_IS_NOT] = emit_op_afname_is_not,
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
