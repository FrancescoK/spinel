/* Compile-time evaluation over the node table.
 *
 * Code a class body runs once, when its file loads, often computes only
 * from what the program spells (a constant table, literal arguments):
 *
 *   StatusMessage.each { |code, message|
 *     const_set(message.gsub(/ /, ''), Class.new(code < 400 ? Success : Error))
 *   }
 *
 * This evaluator runs such code ahead of time. It is pure: given a node
 * and an environment (the block's locals, the classes the evaluation has
 * made so far) it answers a compile-time value (ct_value.h), or 0 where the
 * answer is not known for certain -- it writes nothing to the node table
 * and registers nothing. What the code does to the program (a constant it
 * sets, a class it makes, an instance variable it sets on one, an element
 * it stores into a constant's Hash) is reported as a list of effects, in
 * the order the code performs them, for the caller to apply; and every
 * core method it ran is listed, so the caller can ask whether the program
 * changes it. Today the table-loop desugar (analyze_ct.c) turns the
 * effects into class-body statements; the load-phase elaborator will
 * apply them to its class and constant model directly.
 *
 * It follows: nil, true, false, Integer, String, Symbol and Array literals,
 * interpolation, the block's locals, `if` / ternary / `unless` / `case`
 * over Integer, String and Symbol values and Integer ranges, the methods
 * ct_value.c runs (mv_call, mv_sub), constants (as references), and
 * `Class.new(Constant)`. As statements: a write of a block local, those
 * conditionals, `const_set(name, value)`, `klass.instance_variable_set(:@x,
 * value)`, `Const[key] = value` and `value.freeze`. Anything else answers
 * 0. */
#ifndef SPINEL_CT_EVAL_H
#define SPINEL_CT_EVAL_H

#include "ct_value.h"
#include "node_table.h"

typedef enum {
  CT_VALUE = 0,  /* mv */
  CT_CONST,      /* the constant the node `node` reads (ConstantRead / ConstantPath) */
  CT_CLASS       /* the class `cls` the evaluation made (CtEnv.cls) */
} CtKind;

/* A String value's object -- frozen or not, a literal's or the
   evaluation's own -- is the value's (Mv.frozen, Mv.lit). */
typedef struct { CtKind k; Mv mv; int node; int cls; } CtVal;

/* a class `Class.new(parent)` made: `parent` is the constant node; `name`
   is NULL until a const_set names it */
typedef struct { int parent; char *name; } CtClass;

typedef enum {
  CT_FX_CLASS_NEW,   /* cls: a class made, with its parent */
  CT_FX_CONST_SET,   /* name = val in the module whose body runs; names: val is the class it names */
  CT_FX_IVAR_SET,    /* class cls's instance variable name = val */
  CT_FX_INDEX_SET    /* recv[key] = val, recv a constant */
} CtFxKind;
typedef struct { CtFxKind k; int site; char *name; int cls, names; CtVal recv, key, val; } CtFx;

/* a core method the evaluation ran: on an instance of `cls`, or (a class
   method) on the class itself */
typedef struct { const char *cls; const char *meth; } CtRan;

typedef struct {
  struct { char *name; CtVal v; } loc[64]; int nloc;
  CtClass *cls; int ncls, ccls;
  CtFx *fx; int nfx, cfx;
  CtRan *ran; int nran, cran;
} CtEnv;

/* the value of expression `node`, 1 when it is known */
int ct_eval(const NodeTable *nt, CtEnv *e, int node, CtVal *out);
/* run statements node `stmts` (a StatementsNode, or -1 for none), 1 when
   every statement was followed */
int ct_exec(const NodeTable *nt, CtEnv *e, int stmts);
/* bind local `name` (the block's parameters); 0 when the table is full */
int ct_env_set(CtEnv *e, const char *name, CtVal v);
/* forget the locals (a new block call), keeping the classes and effects */
void ct_env_new_call(CtEnv *e);
/* note that core method cls#meth ran */
void ct_env_ran(CtEnv *e, const char *cls, const char *meth);
void ct_env_free(CtEnv *e);

#endif
