/* share.h -- the share classes --share-strings decides by (#6765).

   A union-find over the places a String object can be held (holders: a
   local or parameter, an ivar, a global, a class variable, a constant, the
   elements of a container) and the values flowing between them, built by
   one walk over the node table (analyze_share.c). Two holders in one class
   may hold the same String object. A class records whether an in-place
   String mutation reaches it (SHF_MUT), whether it meets anything the walk
   does not follow (SHF_UNKNOWN), and whether a mutation reaches it through a
   receiver that is no holder of its own, so no slot can take the new
   pointer back (SHF_INDIRECT).

   The facts only describe; repr_str_shares (repr.c) is the rule that reads
   them. They are built only under --share-strings. */
#ifndef SPINEL_SHARE_H
#define SPINEL_SHARE_H

#include "compiler.h"

typedef enum {
  SHK_VALUE,    /* an expression's value: a container literal, a join */
  SHK_LOCAL,    /* a local or a parameter: scope, local */
  SHK_IVAR,     /* cid, name */
  SHK_GVAR,     /* name */
  SHK_CVAR,     /* name */
  SHK_CONST,    /* name */
  SHK_ELEM,     /* the elements of the containers of one class */
  SHK_RET,      /* a method's value: scope */
  SHK_YIELD,    /* what a method yields: scope */
  SHK_BLKRET,   /* what the blocks a method yields to answer: scope */
  SHK_UNKNOWN   /* anything the walk does not follow */
} ShareKind;

enum {
  SHF_MUT      = 1,   /* an in-place String mutation reaches the class */
  SHF_UNKNOWN  = 2,   /* the class meets UNKNOWN */
  SHF_INDIRECT = 4    /* mutated through a receiver that is no holder */
};

typedef struct {
  unsigned char kind;   /* ShareKind */
  int scope, local;     /* SHK_LOCAL: the scope and its local's index;
                           SHK_RET/YIELD/BLKRET: the method scope */
  int cid;              /* SHK_IVAR: the owning class */
  const char *name;     /* SHK_IVAR/GVAR/CVAR/CONST */
  int node;             /* a node that names the holder, for a message */
} ShareHolder;

/* (Re)build c->share from the current types and tables. */
void share_facts_build(Compiler *c);
void share_facts_free(Compiler *c);

/* The holders, by index 0..share_holder_count-1. */
int share_holder_count(const Compiler *c);
const ShareHolder *share_holder(const Compiler *c, int h);
/* The holder of a local / an ivar, or -1 when the walk made none. */
int share_local_holder(const Compiler *c, int scope, int local);
int share_ivar_holder(const Compiler *c, int cid, const char *name);
/* The element of holder h's containers' elements, or -1 (not a holder:
   read it with share_elem_flags / share_elem_holders). */
int share_elem_holder(const Compiler *c, int h);

/* The facts of holder h's class. */
unsigned share_class_flags(const Compiler *c, int h);
/* the number of holders in it that store a String (not a method's value) */
int share_class_holders(const Compiler *c, int h);
/* the facts of an element (share_elem_holder's answer) */
unsigned share_elem_flags(const Compiler *c, int e);
int share_elem_holders(const Compiler *c, int e);

/* The stats' second build, with every union with UNKNOWN dropped: would
   the holder with h's key share without what the walk does not follow? */
struct ShareFacts *share_facts_build_closed(Compiler *c);
void share_facts_drop(struct ShareFacts *F);
int share_closed_shares(const struct ShareFacts *F, const ShareHolder *h);

#endif
