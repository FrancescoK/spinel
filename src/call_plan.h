/* call_plan.h -- the user method a call binds, resolved from the tables.

   cplan_user(c, id) answers which user method the call node `id` reaches
   -- the method scope, the class whose chain was searched, the arm kind
   (UC_*, compiler.h) and whether the class tables already decide the
   dispatch (one method, or a switch over overrides) -- from the scope and
   class tables and the settled node types alone. It never runs inference
   and never emits, so asking it changes nothing (#7100, Phase B).

   A plan is memoized per node, but only where the node is read as itself:
   no view, no instance_exec scope move or class, no inline splice. Inside
   one of those it is computed afresh and not kept. Nothing reads it to
   emit yet; --plan-check compares it with inference's record and with the
   binding codegen made. */
#ifndef SPINEL_CALL_PLAN_H
#define SPINEL_CALL_PLAN_H

#include "compiler.h"

typedef enum {
  CP_NONE,      /* no user method */
  CP_DIRECT,    /* one method, whatever the receiver's runtime class */
  CP_SWITCH,    /* a switch on the runtime class: a descendant has its own
                   implementation, or a boxed receiver */
  CP_PER_ARM    /* a switch whose arms take the call's arguments differently,
                   so each arm lays them out for itself (an instance dispatch:
                   dispatch_arms_disagree) */
} CplanDispatch;

typedef struct {
  int mi;                  /* the method scope, or -1 */
  short owner_ci;          /* the class whose chain was searched, or -1 */
  unsigned char via;       /* UC_* */
  unsigned char dispatch;  /* CplanDispatch */
  unsigned char by_name;   /* a switch over every class with a class method of
                              the name (a class held in a variable) */
  unsigned char chain;     /* mi is the receiver class's own lookup of the
                              name (comp_method_in_chain(owner_ci, name)), not
                              a method reached another way (an operator's
                              stand-in, a subclass's override of a reader, a
                              reopen) */
} CallPlan;

const CallPlan *cplan_user(Compiler *c, int id);

/* The plan of the same call read in a context the node does not carry
   itself: its self, or its receiver, is an instance of self_ci. That is an
   instance_exec self (CPX_IE), a body emitted for an inheriting class
   (CPX_EMIT), or a poly arm's receiver class (CPX_ARM). The plan is that
   class's own lookup of the name (chain, UC_INST, a switch when a
   descendant overrides it); a miss is no plan, except under CPX_IE, where
   the call resolves as its own (the instance_exec receiver is asked first).
   It is computed afresh and never kept: only cplan_user memoizes. A
   self_ci < 0 is the node's own context, cplan_user. */
enum { CPX_IE = 1, CPX_EMIT = 2, CPX_ARM = 4 };
const CallPlan *cplan_user_in(Compiler *c, int id, int self_ci, int flags);
/* --plan-check: a codegen site that took its target from a plan counts it
   (site: a short constant name); cplan_served_report prints the counts */
void cplan_served(const char *site);
void cplan_served_report(void);

/* The form a dispatch of instance method `name` on class cid takes:
   CP_DIRECT for one implementation, CP_SWITCH when cid's subtree has more
   than one (or any, without a base method: has_base 0), CP_PER_ARM for a
   switch whose arms disagree on the argument layout; CP_NONE for neither
   a base method nor a descendant's. */
int cplan_dispatch_form(Compiler *c, int cid, const char *name, int has_base);

/* whether mi is the plan's method or, for a switch, one of its arms */
int cplan_virtual_member(Compiler *c, int id, const CallPlan *p, int mi);

/* ---- CP_POLY: the arms of a dispatch on a boxed (poly) receiver ----
   One arm per runtime class (or, later, builtin kind) the switch can take:
   what answers there, the arm's value type, and how that value reaches the
   call's own type. Nothing reads the list to emit yet; --plan-check holds
   it against the arms emit_poly_method_dispatch writes (pa_begin /
   pa_observe / pa_end, codegen_poly_plan.c). */
typedef enum {
  PA_USER,        /* the class's method */
  PA_PROC_FORM,   /* a yielding method, through its proc-form clone */
  PA_READER,      /* an attr reader's ivar load */
  PA_NATIVE,      /* a native class's C binding */
  PA_ARITY,       /* the call's count is refused: ArgumentError */
  PA_SYNTH_ENUM   /* a Struct's synthesized each/each_pair: an Enumerator */
} PolyArmKind;

typedef enum {
  PC_SAME,        /* the value as it is */
  PC_BOX,         /* boxed into a poly result */
  PC_UNBOX,       /* a poly value unboxed into a scalar result */
  PC_VOID,        /* no value (a void method, a raise) */
  PC_NUM,         /* a Bignum converted into an Integer or Float result */
  PC_COPY,        /* a shared-mutable String copied into a String result */
  PC_BOX_OR_NIL   /* an Integer ivar boxed with its nil sentinel */
} PolyConv;

typedef struct {
  unsigned char kind;   /* PolyArmKind */
  unsigned char conv;   /* PolyConv */
  unsigned char vty;    /* the arm's value TyKind */
  short key;            /* the runtime class id */
  int mi;               /* the user method scope, or -1 */
} PolyArm;

typedef struct {
  TyKind ret;           /* the call's type the arms answer into */
  int n;
  PolyArm *arm;
} PolyPlan;

/* The user-class arms of a blockless, zero-argument call on a poly
   receiver (the plan's first slice of emit_poly_method_dispatch). Pure;
   kept per node where the node is read as itself. */
const PolyPlan *cplan_poly(Compiler *c, int id);

/* --plan-check: the arms one emitted switch wrote, held against the plan */
int  pa_begin(int id);
void pa_observe(int kind, int key, int mi, TyKind vty, int conv);
void pa_end(Compiler *c, int frame, const PolyPlan *p);
void pa_report(void);

#endif
