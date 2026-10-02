/* builtin_ops.h -- builtin methods as data, read by inference and codegen.

   A row says what a builtin call on a receiver of one TyKind answers and
   how codegen emits it. Inference reads the result kind; codegen reads the
   emitter id and runs the emitter codegen_ops.c keeps for it. One row
   replaces the matching rule in infer_call_inner and the matching arm in
   emit_call_body, which today each decide the same call separately (#7100).

   A family's lookup sits where that family's legacy branch sat in each
   chain, so everything an earlier branch claims still goes there; it moves
   up only once nothing earlier can match the same call. */
#ifndef SPINEL_BUILTIN_OPS_H
#define SPINEL_BUILTIN_OPS_H

#include "types.h"

/* What a row asks of the call's block. BF_ANY: the legacy rule ignored the
   block, so the row does too. */
typedef enum { BF_ANY, BF_NONE, BF_REQUIRED } BopBlock;

/* The emitter codegen runs for a row (codegen_ops.c). BOPE_NONE: the row
   only types the call; codegen leaves it to the legacy chain. */
typedef enum {
  BOPE_NONE,
  BOPE_TEMPLATE,          /* arg, its placeholders filled (codegen_ops.c) */
  BOPE_PSTATUS_SUCCESS,   /* Process::Status#success?: true, false or nil */
  BOPE_PSTATUS_EQ,        /* Process::Status#== / #eql? with no operand */
  /* the concurrency handles (codegen_call_concurrency.c) */
  BOPE_THREAD_SET_REPORT, /* Thread#report_on_exception= */
  BOPE_THREAD_RAISE,      /* Thread#raise */
  BOPE_THREAD_TLS,        /* Thread#[] / []= / key? / thread_variable_*, any key */
  BOPE_MUTEX_SLEEP,       /* Mutex#sleep */
  BOPE_CONDVAR_WAIT,      /* ConditionVariable#wait */
  BOPE_QUEUE_PUSH,        /* Queue#push / << / enq, with non_block and timeout: */
  BOPE_QUEUE_POP,         /* Queue#pop / shift / deq, likewise */
  BOPE_FIBER_RESUME,      /* Fiber#resume */
  BOPE_FIBER_TRANSFER,    /* Fiber#transfer */
  BOPE_FIBER_RAISE,       /* Fiber#raise */
  /* Complex and Rational (codegen_call_numeric.c) */
  BOPE_RATIONAL_ROUND,    /* Rational#round/floor/ceil/truncate with digits or half: */
  /* String (codegen_call_recv.c) */
  BOPE_STR_SET_N,         /* String#squeeze / #delete / #count over several sets */
  BOPE_STR_AFFIX_ANY,     /* String#start_with? / #end_with? over several candidates */
  /* Hash (codegen_call_hash.c) */
  BOPE_HASH_PATTERN,      /* any?/none?/one?/count with a pattern, no block */
  BOPE_HASH_PATTERN_ALL,  /* all? with a pattern, no block */
  BOPE_HASH_DEFAULT_PROC, /* Hash#default_proc */
  BOPE_HASH_TO_PROC,      /* Hash#to_proc */
  BOPE_HASH_AREF,         /* Hash#[] */
  BOPE_HASH_HAS_KEY,      /* has_key?/key?/include?/member? */
  BOPE_HASH_KEY,          /* Hash#key */
  BOPE_HASH_DEFAULT,      /* Hash#default, #default(key) */
  BOPE_HASH_KEYS,         /* Hash#keys */
  BOPE_HASH_FETCH,        /* fetch(key), no default, no block */
  BOPE_HASH_TO_S,         /* Hash#to_s */
  BOPE_HASH_COMPACT_BANG, /* compact! on a poly-valued variant */
  BOPE_HASH_REHASH,       /* Hash#rehash */
  BOPE_HASH_REPLACE,      /* replace(hash) of the same variant, or into PolyPoly */
  BOPE_HASH_SET_DEFAULT,  /* Hash#default= */
  BOPE_HASH_MERGE_BANG_MANY, /* merge!/update(h1, h2, ...) of the same variant */
  BOPE_HASH_SHIFT,        /* Hash#shift, no block */
  BOPE_HASH_DELETE,       /* delete(key) without a block literal */
  BOPE_HASH_INVERT,       /* Hash#invert */
  BOPE_HASH_FLATTEN,      /* Hash#flatten, #flatten(depth) */
  BOPE_HASH_TO_A,         /* to_a / entries */
  BOPE_HASH_SORT,         /* sort, no block */
  BOPE_HASH_FIRST,        /* first, no block */
  BOPE_HASH_TAKE,         /* first(n) / take(n), no block */
  BOPE_HASH_DROP,         /* drop(n), no block */
  BOPE_HASH_ASSOC,        /* assoc / rassoc */
  BOPE_HASH_COMPACT,      /* Hash#compact */
  BOPE__COUNT
} BopEmit;

/* A set of argument kinds, one bit per TyKind: BOP_K(TY_INT) | BOP_K(TY_FLOAT) */
typedef unsigned long long BopKinds;
#define BOP_K(k) (1ULL << (k))
_Static_assert(TY_FLOAT_ARRAY_ARRAY < 64, "a BopKinds set holds a bit per TyKind");

typedef struct BuiltinOp {
  TyKind recv;            /* receiver kind the row applies to */
  const char *name;
  signed char argc_min, argc_max;
  BopBlock block;
  TyKind result;          /* what the call answers; TY_UNKNOWN: inference
                             leaves the call to the rules after it */
  BopEmit emit;
  const char *arg;        /* BOPE_TEMPLATE's C text */
  BopKinds arg0, arg1;    /* the kinds the first and second argument may
                             have (BOP_K), or 0 for any */
  unsigned char flags;    /* BOPF_* */
} BuiltinOp;

/* The row answers for a boxed (poly) receiver too, behind a run-time class
   check: emit_poly_builtin_method emits these names unboxed, so inference
   types the call with the row's result (bop_find_boxed). */
#define BOPF_BOXED 1

/* A row's recv may name a family of kinds rather than one; a caller looks
   the family up with the family's value. Not a TyKind any value has. */
#define BOP_ANY_HASH  ((TyKind)-2)   /* every Hash kind (ty_is_hash) */
#define BOP_ANY_ARRAY ((TyKind)-3)   /* every Array kind (ty_is_array) */

/* A row's result may be derived from the receiver's kind (bop_result). */
#define BOPR_SELF       ((TyKind)-10)   /* the receiver's own kind */
#define BOPR_HASH_VAL   ((TyKind)-11)   /* a Hash's value kind */
#define BOPR_HASH_KEYS  ((TyKind)-12)   /* an Array of a Hash's keys */
#define BOPR_HASH_VALS  ((TyKind)-13)   /* an Array of a Hash's values */
#define BOPR_ELEM       ((TyKind)-14)   /* an Array's element kind */

/* argc_max of a row that takes any number of arguments */
#define BOP_ARGC_ANY 127

/* The row for `name` called with `argc` arguments (and a block when
   has_block) on a receiver of kind rt, or NULL. Pure: it reads no node and
   no Compiler state.

   Rows of one name are tried narrowest arity first, and among rows of the
   same arity in the order they are written. So a codegen row for one arity
   comes before the wider row that only types the call for every arity, and
   a row with an argument guard before the unguarded row of its arity. A
   row with an argument guard never fits here: bop_find_arg checks the
   guard. */
const BuiltinOp *bop_find(TyKind rt, const char *name, int argc, int has_block);

/* bop_find, with arg_of(ud, i) answering argument i's kind for the rows
   that guard it. It is called at most once per argument, and only when
   such a row is a candidate, so a lookup that needs no argument's kind
   computes none. */
typedef TyKind (*BopArgKind)(const void *ud, int i);
const BuiltinOp *bop_find_arg(TyKind rt, const char *name, int argc, int has_block,
                              BopArgKind arg_of, const void *ud);

/* Whether any row applies to receivers of kind rt: a caller checks this
   before reading the call's arguments, so receivers no row covers cost
   nothing. */
int bop_covers(TyKind rt);

/* What the call answers on a receiver of kind rt: the row's result, with a
   derived result (BOPR_*) worked out from rt. */
TyKind bop_result(const BuiltinOp *op, TyKind rt);

/* The BOPF_BOXED row of kind rt for `name`, or NULL. */
const BuiltinOp *bop_find_boxed(TyKind rt, const char *name, int argc, int has_block);

#endif
