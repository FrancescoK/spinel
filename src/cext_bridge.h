#ifndef SPINEL_CEXT_BRIDGE_H
#define SPINEL_CEXT_BRIDGE_H
#include "compiler.h"
void desugar_cext_decls(Compiler *c);
void inherit_cext_layouts(Compiler *c);
void register_cext_layouts(Compiler *c);
int cext_demand_container_strings(Compiler *c, int value);
int *cext_container_stores(Compiler *c, const char *name, Scope *scope, int *count);
int cext_scope(const Compiler *c, int mi);
#endif
