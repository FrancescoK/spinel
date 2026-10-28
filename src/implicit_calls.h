/* implicit_calls.h -- the methods CRuby calls that the program does not name.

   Two tables say which: src/implied_calls.inc (what a node's syntax calls: the
   to_s of an interpolation, the each of a `for`, the inherited of a class
   header; nt_implied_calls) and src/builtin_callbacks.inc (what a builtin
   calls back on the values it is handed: sort asks its elements for <=>;
   bop_name_callbacks). This module reads both for the passes that ask "may
   this method run?" (reachability, which keeps a method CRuby calls back once
   a node that makes the call can run).

   A call has the name CRuby sends, the operand that receives it, the side
   (an object's class or a class object) and, for a builtin's callback, the
   role the operand is handed over in (BCR_*). Nothing here decides what a
   pass does with a call. */
#ifndef SPINEL_IMPLICIT_CALLS_H
#define SPINEL_IMPLICIT_CALLS_H

#include <stdio.h>
#include "compiler.h"
#include "analyze_internal.h"
#include "value_pos.h"
#include "builtin_ops.h"

/* the sides of a call, as nt_implied_calls has them */
enum { IC_INST = NTS_INST, IC_CLASS = NTS_CLASS };

/* ic_node_calls's answer for a call of a core name the builtin table does not
   cover: it may call anything */
#define IC_ANY (-1)

typedef struct {
  const char *name;
  int operand;         /* a syntax row: the node whose value receives the call,
                          or an NTI_ code. A builtin's callback: the call node,
                          whose receiver, arguments and block `role` picks */
  unsigned char side;  /* IC_INST | IC_CLASS */
  unsigned char role;  /* 0 for a syntax row, else one BCR_ bit */
  unsigned char recv;  /* 1: `operand` is the receiver itself (the callbacks of an
                          implied call), not a call node */
} IcCall;

/* What node `id` makes CRuby call without naming it: its kind's rows, and for a
   call the callbacks of the builtin of its name (an implied call of a core
   name takes the callbacks of its operand's elements and its own as well). Out
   to out[0..max), their number answered (more than max when it was short);
   IC_ANY for a call of a core name the table does not cover. Pure over the node
   table and the tables. */
int ic_node_calls(Compiler *c, int id, IcCall *out, int max);

/* Whether the operand that receives the call may hold an object of the
   program's. Before inference, or when the types do not settle it, yes. */
int ic_operand_may_hold(Compiler *c, const IcCall *k);

/* Does call node `id` run a method of the program's (typed runs only), so that
   no builtin of its name runs? */
int ic_runs_program_method(Compiler *c, int id);

/* the text --dump-implicit gives for a call of node `id` */
void ic_cause(Compiler *c, int node, const IcCall *k, char *buf, size_t n);

/* ---- the answer reachability keeps (Compiler.ic) ---- */

typedef struct { char *name, *cause; int scope; unsigned char side; } IcMark;
typedef struct { char *name, *cause; unsigned char side; } IcLive;
struct IcState {
  int typed;           /* the run's types are settled (1 or 2), else 0 */
  int scope;           /* the scope being collected */
  int any;             /* a reachable node called a core name the table does not cover */
  ANameHash class_only;/* the names only plain classes' methods hold (cr_class_only_names) */
  ANameHash defined;   /* the names some scope or alias defines */
  ANameHash toplevel;  /* the names of the program's top-level defs */
  IcMark *marks;       /* what each scope's nodes call, until ic_end */
  int nmarks, capmarks;
  IcLive *live;        /* the marks of the reachable scopes, one per name and side */
  int nlive, caplive;
  ANameHash live_set[2];   /* by side: inst, class */
};

/* start a reachability run: forget the last one's, with the types settled or not */
void ic_begin(Compiler *c, int typed);
/* the scope whose nodes the walk is collecting the calls of */
void ic_scope(Compiler *c, int scope);
/* Is `name` defined by some scope or alias? A call of a name nothing defines
   keeps nothing alive. */
int ic_defined(const Compiler *c, const char *name);
/* The current scope has a node that calls `name` on `side`; `cause` is a short
   text for --dump-implicit. A name of "*" is a call the builtin table does not
   cover. */
void ic_record(Compiler *c, const char *name, unsigned side, const char *cause);
/* the walk is over: the names of the scopes it reached are live */
void ic_end(Compiler *c);
/* Is `name` called, on `side`, by some node of a reachable scope? */
int ic_live(const Compiler *c, const char *name, unsigned side);
/* a call of a core name the builtin table does not cover, in a reachable scope */
int ic_any_seen(const Compiler *c);
void ic_free(Compiler *c);

/* --dump-implicit: each live implicit name with a cause, and each reachable def
   of the program's own file */
void ic_dump(Compiler *c, FILE *out);
extern int g_dump_implicit;

#endif
