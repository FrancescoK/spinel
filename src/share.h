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
  SHF_INDIRECT = 4,   /* mutated through a receiver that is no holder */
  SHF_MULTI    = 16   /* an ivar of the class is written a String it did not
                         make (a call's answer, a member read): the holder is
                         one per class but a slot per object, so it can be
                         several names at once (sh_ivar_store) */
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

/* Under --share-strings, once the analysis is final: mark each String-keyed
   Hash call's key that reads a shared handle, with nothing run between the
   read and the call, as strbuf_read_raw, so it hands over the live buffer
   instead of a copy. Answers how many it marked. */
int share_mark_borrows(Compiler *c);

/* A master route refusal: a String handed along a route that would copy
   it. Under --share-strings the route is the rule's, as share_route_defer
   says. */
typedef struct ShareRoute {
  int site;            /* the node the refusal names */
  int value, elems;    /* the String handed along (elems: the Strings the
                          container `value` names holds) */
  int to, to_elems;    /* the holder it reaches: node `to`'s value (to_elems:
                          its elements), or with to_name, that local in the
                          scope of node `to`; -1 none */
  const char *to_name;
  int carry;           /* the node that hands the String along, or -1 */
  char *msg;           /* (a kept route's message) */
} ShareRoute;
ShareRoute share_route(int site, int value, int elems);
/* Does the rule share the elements of node n's value (a container)? */
int share_node_elems_share(const Compiler *c, int n);
/* Can node n's value (a container) be reached again once its expression
   is done: a holder keeps it, it leaves a call to be read after, or it
   meets what the walk does not follow? */
int share_node_anchored(const Compiler *c, int n);

/* A master route-refusal site asks this first. With the flag off it answers
   0 and the site refuses as before. With it on, the route is the rule's,
   and it passes when the facts see it (the String and the holder it
   reaches in one class) and either the rule does not share that class (no
   other name can see the copy) or it does and `carry` hands over the
   handle; every other holder of a shared class holds the handle or is
   refused by name at seal. Asked while the analysis runs, the facts are not
   final yet: the route is kept, and repr_seal refuses it with `msg` unless
   the final facts pass (share_routes_check). Asked from codegen, it answers
   from the final facts. */
int share_route_defer(Compiler *c, const ShareRoute *q, const char *msg);
void share_routes_check(Compiler *c);
void share_routes_free(Compiler *c);

/* SPINEL_SHARE_STATS=3: name the mutations that reach UNKNOWN's class */
void share_dump_unknown_mutations(Compiler *c);

/* The stats' second build, with every union with UNKNOWN dropped: would
   the holder with h's key share without what the walk does not follow? */
struct ShareFacts *share_facts_build_closed(Compiler *c);
void share_facts_drop(struct ShareFacts *F);
int share_closed_shares(const struct ShareFacts *F, const ShareHolder *h);

#endif
