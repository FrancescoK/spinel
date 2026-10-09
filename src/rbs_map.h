/* rbs_map.h -- RBS types to Spinel's seed type tags.
 *
 * One mapping for both producers of seeds: spinel_rbs_extract (the .rbs
 * files of --rbs) and the compiler's own reading of inline RBS comments
 * (src/inline_rbs.c, built when vendor/rbs is present). The tags are the
 * seed-file vocabulary docs/rbs-extract.md lists: int, string?,
 * obj_<QualifiedName>, int_array, str_int_hash, poly, ... */
#ifndef SPINEL_RBS_MAP_H
#define SPINEL_RBS_MAP_H

#include <stdbool.h>
#include <stddef.h>

#include "rbs/parser.h"
#include "rbs/ast.h"

typedef struct {
    char *buf;
    size_t len;
    size_t cap;
} sbuf_t;

void sbuf_init(sbuf_t *s);
void sbuf_free(sbuf_t *s);
void sbuf_grow(sbuf_t *s, size_t need);
void sbuf_append(sbuf_t *s, const char *src, size_t n);
void sbuf_append_cstr(sbuf_t *s, const char *src);
void sbuf_set(sbuf_t *s, const char *src, size_t n);

/* The qualified names ("_"-joined) of the classes and modules declared,
 * against which an unqualified type name is resolved (#656). */
void known_names_add(const char *name, size_t n);
bool known_names_has(const char *name);

/* The qualified name of the declaration whose members are being mapped;
 * an unqualified type name resolves against it first. */
extern const char *g_self_scope;

void name_of_symbol(rbs_parser_t *p, rbs_ast_symbol_t *sym, sbuf_t *out);
void name_of_type_name(rbs_parser_t *p, rbs_type_name_t *tn, sbuf_t *out);

/* Write the seed tag of `node` into `out`; false when the type is outside
 * the subset Spinel can pin. `enclosing_scope` is the parent namespace of
 * the declaration (may be NULL or ""). */
bool map_type(rbs_parser_t *p, rbs_node_t *node,
              const char *enclosing_scope, sbuf_t *out);

#endif
