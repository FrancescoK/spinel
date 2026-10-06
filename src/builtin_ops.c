/* builtin_ops.c -- the builtin method rows (see builtin_ops.h). */

#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include "builtin_ops.h"

/* The names a boxed builtin surface serves and the storage sites at which
   a String mutator is supported. Filter the rows before comparing names:
   each surface retains its previous comparison order and work count. */
static const struct {
  const char *name;
  unsigned readers, mutators;
} bop_name_traits[] = {
#include "builtin_name_traits.inc"
};

int bop_name_has_reader(const char *name, unsigned surface) {
  if (!name) return 0;
  for (unsigned i = 0; i < sizeof bop_name_traits / sizeof bop_name_traits[0]; i++) {
    if (!(bop_name_traits[i].readers & surface)) continue;
    if (sp_streq(name, bop_name_traits[i].name)) return 1;
  }
  return 0;
}

int bop_name_mutates(const char *name, unsigned sites) {
  if (!name) return 0;
  for (unsigned i = 0; i < sizeof bop_name_traits / sizeof bop_name_traits[0]; i++) {
    if (!bop_name_traits[i].mutators) continue;
    if (sp_streq(name, bop_name_traits[i].name))
      return (bop_name_traits[i].mutators & sites) == sites;
  }
  return 0;
}
