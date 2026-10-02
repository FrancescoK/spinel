#ifndef SPINEL_CODEGEN_H
#define SPINEL_CODEGEN_H

#include "node_table.h"

/* Generate the full C translation unit for the program in `nt`.
   Returns a malloc'd NUL-terminated buffer (caller frees). Aborts the
   process with a diagnostic on an unsupported construct. */
char *codegen_program(const NodeTable *nt);

/* --check-traits / --dump-traits (ty_traits_check.c): compare the ty_traits
   table with the functions it summarizes, or print it from them, after the
   program's analysis, then stop */
extern int g_check_traits, g_dump_traits;

#endif
