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

/* ---- codegen_call.c's helpers the arms call ---- */

#endif
