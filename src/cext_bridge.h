#ifndef SPINEL_CEXT_BRIDGE_H
#define SPINEL_CEXT_BRIDGE_H
#include "compiler.h"
void desugar_cext_decls(Compiler *c);
void inherit_cext_layouts(Compiler *c);
void register_cext_layouts(Compiler *c);
void cext_resolve_constant(Compiler *c, int call);
int cext_demand_reader(Compiler *c, int call);
int cext_demand_string(Compiler *c, int value);
int cext_demand_container_strings(Compiler *c, int value);
int *cext_container_stores(Compiler *c, const char *name, Scope *scope, int *count);
int *cext_ivar_container_stores(Compiler *c, const char *name, int cls, int *count);
int cext_scope(const Compiler *c, int mi);
#endif
