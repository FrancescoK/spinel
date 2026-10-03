/* codegen_call_arms.h -- emit_call_body's arms, by family, in the
   codegen_call_<family>.c files. emit_call_body (codegen_call.c) calls each
   at the position its arms held, in the same order; each answers 1 when it
   emitted the call, 0 to leave it to the arms after it. The helpers of
   codegen_call.c those arms call are declared here too. */
#ifndef SPINEL_CODEGEN_CALL_ARMS_H
#define SPINEL_CODEGEN_CALL_ARMS_H

#include "codegen_internal.h"
#include "codegen_poly.h"
#include "builtin_ops.h"
#include "call_plan.h"

/* ---- the arms ---- */
int emit_call_synchronize_arms(Compiler *c, int id, Buf *b, const NodeTable *nt, const char *name, int recv);
int emit_call_bigint_arms(Compiler *c, int id, Buf *b, const NodeTable *nt, const char *name, int recv, int argc, const int *argv, TyKind rt);
int emit_call_identity_arms(Compiler *c, int id, Buf *b, const NodeTable *nt, const char *name, int recv, int argc, const int *argv, TyKind rt);
int emit_call_instance_eval_arms(Compiler *c, int id, Buf *b, const NodeTable *nt, const char *name, int recv, int argc);
int emit_call_freeze_dup_arms(Compiler *c, int id, Buf *b, const NodeTable *nt, const char *name, int recv, int argc);
int emit_call_safe_nav_arms(Compiler *c, int id, Buf *b, const NodeTable *nt, const char *name, int recv);
int emit_call_object_override_arms(Compiler *c, int id, Buf *b, const NodeTable *nt);
int emit_call_print_arms(Compiler *c, Buf *b, const NodeTable *nt, const char *name, int recv, int argc, const int *argv, TyKind rt);
int emit_call_compare_arms(Compiler *c, int id, Buf *b, const NodeTable *nt, const char *name, int recv, int argc, const int *argv, TyKind rt);
int emit_call_operator_arms(Compiler *c, int id, Buf *b, const NodeTable *nt, const char *name, int recv, int argc, const int *argv, TyKind rt, TyKind a0);

/* ---- codegen_call.c's helpers the arms call ---- */
void emit_bigint_operand(Compiler *c, int node, Buf *b);
int cmp_operand_may_be_nil(Compiler *c, int id);
int emit_poly_isa_test(Compiler *c, const char *cn, const char *v, int exact, Buf *b);
void emit_pre_root(Compiler *c, TyKind t, int tmp);
int emit_scalar_class_test(Compiler *c, int node, TyKind t, const char *cn, int exact, Buf *b);
int hoist_boxed_rooted(Compiler *c, int node);
TyKind user_cmp_invalid_ret(Compiler *c, int cid);
int user_cmp_needs_check(Compiler *c, int cid);
void emit_ie_param_default(Compiler *c, TyKind t, Buf *b);
int emit_ie_poly(Compiler *c, int id, Buf *b);
int emit_ie_proc(Compiler *c, int id, int recv, int self_cls, int blk, int tramp, Buf *b);
extern int g_ie_poly_node;
int ie_body_has_break_next(Compiler *c, int node);
int ie_body_ivar_write(const NodeTable *nt, int node);
TyKind ie_splice_value_ty(Compiler *c, int node);
int basicobject_own_method(const char *n);
void emit_poly_cmp_ordered(Compiler *c, const char *fn, int recv, int arg, Buf *b);
void emit_handle_inspect(Compiler *c, int recv, TyKind rt, Buf *b);
int bigint_cmp_operand_ok(TyKind t);
Buf emit_cmp_self(Compiler *c, int recv, TyKind rt);
int emit_float_bigint_cmp(Compiler *c, int recv, int arg, const char *op, Buf *b);
int emit_int_operand_fail(Compiler *c, int id, int recv, int arg, int is_shift, Buf *b);
int exc_subclass_defines_cmp(Compiler *c);
int obj_cmp_by_identity(TyKind t);
int object_defines_cmp(Compiler *c);
void scalar_nil_test(TyKind t, const char *v, char *out, size_t n);

#endif
