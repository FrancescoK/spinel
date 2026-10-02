/* builtin_names.h -- the families of builtin method names the compiler asks
   about by name in many places: `[] () call`, `is_a? kind_of? instance_of?`,
   ... Each predicate answers whether a name is one of its family; the
   family's names are listed once, in builtin_names.c, where every site that
   spelled the chain out now asks. A predicate compares the name with each of
   its family in turn, as the chains did (sp_streq: the work counter counts
   the same compares). Near-families (a set one name larger or smaller) are
   different questions and keep their own spelling. */
#ifndef SPINEL_BUILTIN_NAMES_H
#define SPINEL_BUILTIN_NAMES_H

int is_call_alias(const char *n);     /* call () []: a Proc/Method's invocation */
int is_kind_query(const char *n);     /* is_a? kind_of? instance_of? */
int is_round_family(const char *n);   /* round ceil floor truncate */
int is_push_alias(const char *n);     /* push << append */
int is_bit_op(const char *n);         /* & | ^ */
int is_basic_arith(const char *n);    /* + - * / (is_arith_op adds % and **) */
int is_object_root(const char *n);    /* Object Kernel BasicObject: the classes every object has */
int is_send_family(const char *n);    /* send __send__ public_send */
int is_name_reader(const char *n);    /* name to_s inspect: a Class's or Module's name */

#endif
