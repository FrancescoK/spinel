/* spinel_rbs_extract -- walk a directory for .rbs files and emit a
 * seed file for spinel_analyze's --rbs path.
 *
 * Reads RBS source through the vendored rbs C parser (vendor/rbs/) and
 * emits a tiny line-oriented seed format consumed by load_rbs_seeds /
 * apply_rbs_seeds in spinel_analyze.rb. Per the design conversation,
 * this is *advisory* seeding: only a subset of RBS maps to spinel's
 * type vocabulary, and anything outside the subset is silently
 * skipped. The analyzer's existing inference still runs on top.
 *
 * Subset supported (everything else dropped without warning):
 *   - Primitives: Integer, Float, String, Symbol, TrueClass,
 *     FalseClass, NilClass, bool, nil, void (→ nil for returns)
 *   - Nominal class instances → obj_<QualifiedName>
 *   - Array[T] where T is in subset → str_array / int_array /
 *     float_array / sym_array / obj_X_ptr_array / poly_array
 *   - Array[Array[Integer]] / Array[Array[Float]] → int_array_array /
 *     float_array_array (a request the narrowing pass answers, not a pin)
 *   - Hash[K, V] → str_int_hash / sym_str_hash / str_poly_hash etc.
 *   - Optional T (T?) → <subset>?    (recursive)
 *   - Union T | nil → T?    (any other union → skip)
 *
 * Dropped: generics with variables, overloads beyond #1, blocks,
 * proc types, intersections, records, tuples, interfaces, literal
 * types, type aliases, self / instance / class / top / bottom /
 * any types.
 *
 * Usage:
 *   spinel_rbs_extract DIR [DIR ...]
 *
 * Walks each DIR recursively for *.rbs files, writes seed lines to
 * stdout. The `spinel` wrapper captures stdout to a tmpfile and
 * passes it as ARGV[2] to spinel_analyze. */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>

#include "rbs/parser.h"
#include "rbs/ast.h"
#include "rbs/util/rbs_encoding.h"
#include "rbs/util/rbs_constant_pool.h"

/* ---- small string buffer ----------------------------------- */

typedef struct {
    char *buf;
    size_t len;
    size_t cap;
} sbuf_t;

static void sbuf_init(sbuf_t *s) { s->buf = NULL; s->len = 0; s->cap = 0; }
static void sbuf_free(sbuf_t *s) { free(s->buf); s->buf = NULL; s->len = 0; s->cap = 0; }

static void sbuf_grow(sbuf_t *s, size_t need) {
    if (s->cap >= need) return;
    size_t ncap = s->cap == 0 ? 64 : s->cap;
    while (ncap < need) ncap *= 2;
    char *nbuf = (char *) realloc(s->buf, ncap);
    if (nbuf == NULL) {
        fprintf(stderr, "spinel_rbs_extract: out of memory\n");
        exit(1);
    }
    s->buf = nbuf;
    s->cap = ncap;
}

static void sbuf_append(sbuf_t *s, const char *src, size_t n) {
    sbuf_grow(s, s->len + n + 1);
    memcpy(s->buf + s->len, src, n);
    s->len += n;
    s->buf[s->len] = '\0';
}

static void sbuf_append_cstr(sbuf_t *s, const char *src) {
    sbuf_append(s, src, strlen(src));
}

static void sbuf_set(sbuf_t *s, const char *src, size_t n) {
    s->len = 0;
    sbuf_append(s, src, n);
}

/* ---- known-name set (issue #656) ---------------------------- */

/* Set of qualified class/module names defined across all .rbs files
 * traversed. Populated by collect_decl_names in a pre-pass before
 * the emit pass; consulted by resolve_unqualified_name so a bare
 * `Article` written inside `module Views; module Articles` walks
 * the lexical chain (Views_Articles_Article, Views_Article,
 * Article) and picks the first match. Without the set we either
 * always prepend the enclosing scope (wrong when the referent is
 * top-level) or never prepend (wrong for the sibling-in-module
 * case). Issue #656. */
static char **known_names = NULL;
static size_t known_names_len = 0;
static size_t known_names_cap = 0;
/* The qualified name of the declaration whose members are being emitted
 * (`Rails` for the members of `module Rails`). An unqualified type name
 * resolves against it first: RBS, like Ruby, looks a constant up in the
 * innermost enclosing namespace, so `Application` inside `module Rails`
 * is `Rails::Application` when that is declared. */
static const char *g_self_scope = NULL;

static void known_names_add(const char *name, size_t n) {
    /* dedupe (linear; n is small in practice) */
    for (size_t i = 0; i < known_names_len; i++) {
        if (strlen(known_names[i]) == n && memcmp(known_names[i], name, n) == 0) return;
    }
    if (known_names_len >= known_names_cap) {
        size_t ncap = known_names_cap == 0 ? 32 : known_names_cap * 2;
        char **nbuf = (char **) realloc(known_names, ncap * sizeof(char *));
        if (nbuf == NULL) {
            fprintf(stderr, "spinel_rbs_extract: out of memory\n");
            exit(1);
        }
        known_names = nbuf;
        known_names_cap = ncap;
    }
    char *copy = (char *) malloc(n + 1);
    if (copy == NULL) {
        fprintf(stderr, "spinel_rbs_extract: out of memory\n");
        exit(1);
    }
    memcpy(copy, name, n);
    copy[n] = '\0';
    known_names[known_names_len++] = copy;
}

static bool known_names_has(const char *name) {
    for (size_t i = 0; i < known_names_len; i++) {
        if (strcmp(known_names[i], name) == 0) return true;
    }
    return false;
}

/* ---- name lookup via rbs constant pool --------------------- */

/* Read the bytes for a constant_id out of the parser's pool into a sbuf.
 * Resets the buffer first. Result is NUL-terminated. */
static void name_of_symbol(rbs_parser_t *p, rbs_ast_symbol_t *sym, sbuf_t *out) {
    out->len = 0;
    if (sym == NULL) { sbuf_append(out, "", 0); return; }
    rbs_constant_t *c = rbs_constant_pool_id_to_constant(&p->constant_pool, sym->constant_id);
    if (c == NULL) { sbuf_append(out, "", 0); return; }
    sbuf_set(out, (const char *) c->start, c->length);
}

/* Qualified name from a type_name: namespace path joined with "_"
 * plus the leaf symbol. Spinel registers nested classes with "_"
 * separators (e.g. `module Tep; class Json` → `Tep_Json` in
 * @cls_names; `Tep::Security::Cors` → `Tep_Security_Cors`). RBS
 * spells them with `::`, so we translate here. */
static void name_of_type_name(rbs_parser_t *p, rbs_type_name_t *tn, sbuf_t *out) {
    out->len = 0;
    if (tn == NULL) return;
    if (tn->rbs_namespace != NULL && tn->rbs_namespace->path != NULL) {
        rbs_node_list_node_t *cur = tn->rbs_namespace->path->head;
        while (cur != NULL) {
            if (cur->node->type == RBS_AST_SYMBOL) {
                rbs_ast_symbol_t *seg = (rbs_ast_symbol_t *) cur->node;
                rbs_constant_t *c = rbs_constant_pool_id_to_constant(&p->constant_pool, seg->constant_id);
                if (c != NULL) {
                    sbuf_append(out, (const char *) c->start, c->length);
                    sbuf_append_cstr(out, "_");
                }
            }
            cur = cur->next;
        }
    }
    rbs_constant_t *c = rbs_constant_pool_id_to_constant(&p->constant_pool, tn->name->constant_id);
    if (c != NULL) {
        sbuf_append(out, (const char *) c->start, c->length);
    }
}

/* ---- subset type mapping ----------------------------------- */

/* Categorize a primitive name to a spinel scalar tag. NULL on
 * non-primitive (caller treats as nominal `obj_<Name>`). */
static const char *primitive_tag(const char *name, size_t len) {
    if (len == 7 && memcmp(name, "Integer", 7) == 0) return "int";
    if (len == 5 && memcmp(name, "Float", 5) == 0)   return "float";
    if (len == 6 && memcmp(name, "String", 6) == 0)  return "string";
    if (len == 6 && memcmp(name, "Symbol", 6) == 0)  return "symbol";
    if (len == 9 && memcmp(name, "TrueClass", 9) == 0)  return "bool";
    if (len == 10 && memcmp(name, "FalseClass", 10) == 0) return "bool";
    if (len == 8 && memcmp(name, "NilClass", 8) == 0)   return "nil";
    return NULL;
}

/* Map a typed element (already mapped to a spinel scalar/obj tag) into
 * the array variant name spinel uses. NULL if unsupported. */
static const char *array_tag_for_elem(const char *elem) {
    if (strcmp(elem, "int") == 0)    return "int_array";
    if (strcmp(elem, "float") == 0)  return "float_array";
    if (strcmp(elem, "string") == 0) return "str_array";
    if (strcmp(elem, "symbol") == 0) return "sym_array";
    /* Array[Array[Integer]] / Array[Array[Float]]: map_type has already
     * reduced the element, so the nested case is the element tag being an
     * array tag itself. Without these two the pair fell to poly_array, and
     * because a poly_array seed PINS the ivar it stopped the very pass that
     * produces the unboxed table -- so writing the accurate signature made
     * the program slower, with nothing said. Only these two nest: the other
     * array kinds have no table form to ask for. */
    if (strcmp(elem, "int_array") == 0)   return "int_array_array";
    if (strcmp(elem, "float_array") == 0) return "float_array_array";
    {
        size_t l = strlen(elem);
        int is_obj_arr = l >= 10 && strcmp(elem + l - 10, "_ptr_array") == 0;
        if (strncmp(elem, "obj_", 4) == 0 && !is_obj_arr) {
            /* obj_Foo → obj_Foo_ptr_array (heuristic, mirrors spinel's
             * array-of-objects shape). Caller must append _ptr_array. */
            return NULL;
        }
        /* an array OF object arrays has no table form, so it is an
         * `Array[<other>]` like any other: poly_array, per the documented
         * rule, rather than a dropped signature */
    }
    return "poly_array";
}

/* Map (K, V) of a Hash[K, V] to spinel's hash variant name. NULL on
 * unsupported combinations. */
static const char *hash_tag_for_kv(const char *k, const char *v) {
    if (strcmp(k, "string") == 0) {
        if (strcmp(v, "int") == 0)    return "str_int_hash";
        if (strcmp(v, "string") == 0) return "str_str_hash";
        return "str_poly_hash";
    }
    if (strcmp(k, "symbol") == 0) {
        if (strcmp(v, "int") == 0)    return "sym_int_hash";
        if (strcmp(v, "string") == 0) return "sym_str_hash";
        return "sym_poly_hash";
    }
    if (strcmp(k, "int") == 0) {
        if (strcmp(v, "string") == 0) return "int_str_hash";
    }
    /* `Hash[untyped, untyped]` (and any leftover combination where
     * one side is untyped without a matching concrete variant
     * above) -- map to bare "poly" rather than poly_poly_hash. The
     * analyzer treats this slot as sp_RbVal (tagged union), which
     * matches how a top-level `def f(h)` with no caller signal
     * settles. Picking poly_poly_hash here forced a specific tagged
     * struct pointer (sp_PolyPolyHash *) that doesn't accept the
     * sp_RbVal arguments callers actually pass through poly
     * narrowing branches (e.g. `v.is_a?(Hash) ? f(v) : v`). Issue
     * #613. */
    if (strcmp(k, "poly") == 0 || strcmp(v, "poly") == 0) {
        return "poly";
    }
    return NULL;
}

/* Forward decl. Write a spinel type tag into out; return true on
 * success, false to signal "out of subset, caller should skip".
 *
 * `enclosing_scope` (may be NULL/"") is the qualified name of the
 * declaration we're currently inside, e.g. `ActiveRecord` while
 * traversing members of `module ActiveRecord; class RecordInvalid`.
 * Used to resolve unqualified nominal type references: `Base` inside
 * `ActiveRecord` becomes `obj_ActiveRecord_Base`. Without this, the
 * extractor emits `obj_Base` and the seed misses any class actually
 * stored at the qualified name in spinel's tables. */
static bool map_type(rbs_parser_t *p, rbs_node_t *node,
                     const char *enclosing_scope, sbuf_t *out);

/* True if the type_name was written unqualified in source (no `::`
 * separators, no leading `::`). RBS exposes this as an empty
 * namespace path. */
static bool type_name_is_unqualified(rbs_type_name_t *tn) {
    if (tn == NULL || tn->rbs_namespace == NULL) return true;
    if (tn->rbs_namespace->path == NULL) return true;
    return tn->rbs_namespace->path->length == 0;
}

/* Map a ClassInstance node. Handles Array[T], Hash[K,V], primitives,
 * and nominal classes. */
static bool map_class_instance(rbs_parser_t *p, rbs_types_class_instance_t *ci,
                                const char *enclosing_scope, sbuf_t *out) {
    sbuf_t name;
    sbuf_init(&name);
    name_of_type_name(p, ci->name, &name);

    /* Primitive lookup uses the leaf name only. After name_of_type_name
     * the separator is "_" (translated from RBS's "::"), so the leaf
     * is the substring after the last "_". Conservative: only treat
     * the trailing segment as the primitive name; a class actually
     * named `Foo_Integer` would shadow the primitive, but that's
     * extremely unlikely in practice. */
    const char *primitive = NULL;
    {
        const char *leaf = name.buf;
        size_t leaf_len = name.len;
        for (size_t i = 0; i < name.len; i++) {
            if (name.buf[i] == '_') {
                leaf = name.buf + i + 1;
                leaf_len = name.len - (i + 1);
            }
        }
        primitive = primitive_tag(leaf, leaf_len);
    }

    size_t argc = ci->args != NULL ? ci->args->length : 0;

    if (primitive != NULL && argc == 0) {
        sbuf_set(out, primitive, strlen(primitive));
        sbuf_free(&name);
        return true;
    }

    /* Array[T] */
    if (name.len >= 5 && strcmp(name.buf + name.len - 5, "Array") == 0 && argc == 1) {
        sbuf_t elem;
        sbuf_init(&elem);
        if (!map_type(p, ci->args->head->node, enclosing_scope, &elem)) {
            sbuf_free(&elem);
            sbuf_free(&name);
            return false;
        }
        /* `Array[Foo]` is obj_Foo_ptr_array. `Array[Array[Foo]]` is NOT
         * obj_Foo_ptr_array_ptr_array -- there is no table of object arrays,
         * and that tag named nothing any consumer accepts, so it was a seed
         * that could only ever be dropped. Nest only where a table exists. */
        if (strncmp(elem.buf, "obj_", 4) == 0
            && !(elem.len >= 10 && strcmp(elem.buf + elem.len - 10, "_ptr_array") == 0)) {
            sbuf_set(out, elem.buf, elem.len);
            sbuf_append_cstr(out, "_ptr_array");
        }
else {
            const char *tag = array_tag_for_elem(elem.buf);
            if (tag == NULL) {
                sbuf_free(&elem);
                sbuf_free(&name);
                return false;
            }
            sbuf_set(out, tag, strlen(tag));
        }
        sbuf_free(&elem);
        sbuf_free(&name);
        return true;
    }

    /* Hash[K, V] */
    if (name.len >= 4 && strcmp(name.buf + name.len - 4, "Hash") == 0 && argc == 2) {
        sbuf_t k, v;
        sbuf_init(&k); sbuf_init(&v);
        if (!map_type(p, ci->args->head->node, enclosing_scope, &k)
            || !map_type(p, ci->args->head->next->node, enclosing_scope, &v)) {
            sbuf_free(&k); sbuf_free(&v); sbuf_free(&name); return false;
        }
        const char *tag = hash_tag_for_kv(k.buf, v.buf);
        sbuf_free(&k); sbuf_free(&v);
        if (tag == NULL) { sbuf_free(&name); return false; }
        sbuf_set(out, tag, strlen(tag));
        sbuf_free(&name);
        return true;
    }

    /* Generic with arity > 0 of an unrecognized container → skip. */
    if (argc > 0) {
        sbuf_free(&name);
        return false;
    }

    /* Nominal class instance: emit obj_<QualifiedName>. Three cases:
     *
     * 1. Source wrote `::Const` (absolute): use the bare name as-is,
     *    never prepend the enclosing scope (issue #656).
     * 2. Source wrote unqualified `Const` and we're inside a class/
     *    module scope: walk the lexical chain from innermost outward
     *    and pick the first qualified name present in known_names.
     *    Fall back to bare when no candidate matches (matches Ruby's
     *    `::Const` resolution at top-level).
     * 3. Source wrote qualified `A::B::C`: use as-is (name already
     *    contains the full path via name_of_type_name).
     */
    sbuf_set(out, "obj_", 4);
    bool absolute = (ci->name != NULL && ci->name->rbs_namespace != NULL
                     && ci->name->rbs_namespace->absolute);
    /* The declaration's own namespace first: `Application` inside
     * `module Rails` is `Rails_Application` when that is declared, even
     * with a top-level `Application` in scope. */
    bool self_resolved = false;
    if (!absolute && g_self_scope != NULL && g_self_scope[0] != '\0'
        && type_name_is_unqualified(ci->name)) {
        sbuf_t own;
        sbuf_init(&own);
        sbuf_append_cstr(&own, g_self_scope);
        sbuf_append_cstr(&own, "_");
        sbuf_append(&own, name.buf, name.len);
        if (known_names_has(own.buf)) {
            sbuf_append(out, own.buf, own.len);
            self_resolved = true;
        }
        sbuf_free(&own);
    }
    if (self_resolved) {
        /* resolved against the declaration's own namespace */
    }
else if (!absolute && enclosing_scope != NULL && enclosing_scope[0] != '\0'
        && type_name_is_unqualified(ci->name)) {
        /* Walk the lexical chain: try `<chain>_<name>` for each suffix
         * of enclosing_scope (innermost outward), then top-level. */
        sbuf_t candidate;
        sbuf_init(&candidate);
        const char *scope_end = enclosing_scope + strlen(enclosing_scope);
        const char *cur = enclosing_scope;
        bool resolved = false;
        while (cur != NULL && cur < scope_end) {
            candidate.len = 0;
            sbuf_append(&candidate, cur, scope_end - cur);
            sbuf_append_cstr(&candidate, "_");
            sbuf_append(&candidate, name.buf, name.len);
            if (known_names_has(candidate.buf)) {
                sbuf_append(out, candidate.buf, candidate.len);
                resolved = true;
                break;
            }
            /* Step to the next inner namespace by skipping past the
             * next "_". `Views_Articles_Helpers` -> `Articles_Helpers`
             * -> `Helpers` -> done. */
            const char *next = (const char *) memchr(cur, '_', scope_end - cur);
            if (next == NULL) break;
            cur = next + 1;
        }
        if (!resolved) {
            /* Top-level fallback: emit bare name. */
            sbuf_append(out, name.buf, name.len);
        }
        sbuf_free(&candidate);
    }
else {
        sbuf_append(out, name.buf, name.len);
    }
    sbuf_free(&name);
    return true;
}

static bool map_type(rbs_parser_t *p, rbs_node_t *node,
                     const char *enclosing_scope, sbuf_t *out) {
    if (node == NULL) return false;
    switch (node->type) {
        case RBS_TYPES_BASES_BOOL:
            sbuf_set(out, "bool", 4);
            return true;
        case RBS_TYPES_BASES_NIL:
            sbuf_set(out, "nil", 3);
            return true;
        case RBS_TYPES_BASES_VOID:
            /* void only appears as a return type; spinel uses "nil"
             * (which void-returning methods discard). */
            sbuf_set(out, "nil", 3);
            return true;
        case RBS_TYPES_BASES_ANY:
            /* `untyped` in RBS == anything. Spinel's nearest is poly
             * (sp_RbVal -- tagged union). Hash[untyped, untyped] uses
             * this in hash_tag_for_kv to land on poly_poly_hash. */
            sbuf_set(out, "poly", 4);
            return true;
        case RBS_TYPES_CLASS_INSTANCE:
            return map_class_instance(p, (rbs_types_class_instance_t *) node, enclosing_scope, out);
        case RBS_TYPES_OPTIONAL: {
            rbs_types_optional_t *opt = (rbs_types_optional_t *) node;
            sbuf_t inner;
            sbuf_init(&inner);
            if (!map_type(p, opt->type, enclosing_scope, &inner)) { sbuf_free(&inner); return false; }
            /* Avoid double-?: nil? → just nil; obj_Foo?? → obj_Foo? */
            if (inner.len > 0 && inner.buf[inner.len - 1] == '?') {
                sbuf_set(out, inner.buf, inner.len);
            }
else if (inner.len == 3 && memcmp(inner.buf, "nil", 3) == 0) {
                sbuf_set(out, "nil", 3);
            }
else {
                sbuf_set(out, inner.buf, inner.len);
                sbuf_append_cstr(out, "?");
            }
            sbuf_free(&inner);
            return true;
        }
        case RBS_TYPES_UNION: {
            /* `T | nil` (the nilable shape) maps to `T?`. Every other
             * union has no single concrete C representation, so it
             * maps to poly (sp_RbVal, the tagged union) -- the same
             * target `untyped` uses. This boxes the value correctly.
             *
             * Previously any non-`T | nil` union returned false, which
             * dropped the *entire* method seed (the caller bails on a
             * false return type), letting inference collapse e.g.
             * {int, string} to a single C type and mis-compile
             * heterogeneous returns (matz/spinel#1255). Mapping to poly
             * is the faithful choice: spinel's only representation for
             * "one of several incompatible types" is the tagged union.
             *
             * This touches only the RBS-seed layer. The self-host build
             * ships no `.rbs`, so the inference-level unify_return_type
             * heuristic (load-bearing for stage-2) is unaffected. */
            rbs_types_union_t *u = (rbs_types_union_t *) node;
            /* a union of singleton(...) types is a Class value whatever the
             * member: the `class` token, not poly -- which reads as a union
             * of instances (matz/spinel#5036) */
            if (u->types != NULL && u->types->length > 0) {
                bool all_cls = true;
                for (rbs_node_list_node_t *e = u->types->head; e; e = e->next)
                    if (e->node->type != RBS_TYPES_CLASS_SINGLETON) { all_cls = false; break; }
                if (all_cls) { sbuf_set(out, "class", 5); return true; }
            }
            if (u->types != NULL && u->types->length == 2) {
                rbs_node_t *a = u->types->head->node;
                rbs_node_t *b = u->types->head->next->node;
                rbs_node_t *t = NULL;
                if (a->type == RBS_TYPES_BASES_NIL) t = b;
                else if (b->type == RBS_TYPES_BASES_NIL) t = a;
                if (t != NULL) {
                    sbuf_t inner;
                    sbuf_init(&inner);
                    if (map_type(p, t, enclosing_scope, &inner)) {
                        sbuf_set(out, inner.buf, inner.len);
                        if (inner.len == 0 || inner.buf[inner.len - 1] != '?') {
                            sbuf_append_cstr(out, "?");
                        }
                        sbuf_free(&inner);
                        return true;
                    }
                    /* `T | nil` where T is itself out-of-subset →
                     * fall through to poly below. */
                    sbuf_free(&inner);
                }
            }
            sbuf_set(out, "poly", 4);
            return true;
        }
        case RBS_TYPES_CLASS_SINGLETON:
            /* `singleton(X)`: the class itself, a Class value. It used to
             * fall out of the subset, which dropped the whole method's seed,
             * parameters included (matz/spinel#5036). */
            sbuf_set(out, "class", 5);
            return true;
        default:
            /* Out of subset: Self / Top / Bottom / Any / Instance /
             * Class / Block / Function / Interface / Intersection /
             * Literal / Proc / Record / RecordFieldType / Tuple /
             * UntypedFunction / Variable / Alias. */
            return false;
    }
}

/* ---- emit one method signature ----------------------------- */

/* Pick the seed-line keyword from rbs's method-definition kind.
 * `meth` lands in the instance table (@cls_meth_*), `cmeth` in the
 * class table (@cls_cmeth_*). SINGLETON_INSTANCE (def self?.foo)
 * emits both so seed_class_method on the analyzer side hits whichever
 * the source actually defined. */
static void emit_method(rbs_parser_t *p, rbs_ast_members_method_definition_t *m,
                        const char *enclosing_scope, FILE *out) {
    if (m->overloads == NULL || m->overloads->head == NULL) return;
    /* Only the first overload; multiple overloads are out of subset
     * (spinel can't pick between them deterministically). */
    rbs_node_t *first = m->overloads->head->node;
    if (first->type != RBS_AST_MEMBERS_METHOD_DEFINITION_OVERLOAD) return;
    rbs_ast_members_method_definition_overload_t *ov =
        (rbs_ast_members_method_definition_overload_t *) first;

    if (ov->method_type == NULL || ov->method_type->type != RBS_METHOD_TYPE) return;
    rbs_method_type_t *mt = (rbs_method_type_t *) ov->method_type;
    /* type_params on the method (generics) → can't be represented;
     * skip the signature rather than emit a misleading one. */
    if (mt->type_params != NULL && mt->type_params->length > 0) return;
    if (mt->type == NULL || mt->type->type != RBS_TYPES_FUNCTION) {
        /* untyped_function or proc → out of subset. */
        return;
    }
    rbs_types_function_t *fn = (rbs_types_function_t *) mt->type;

    /* Out-of-subset shapes: rest-positional / rest-keyword / optional
     * or trailing positionals. These break the fixed-arity contract
     * the seed format expects (one ptype slot per Ruby def param).
     * Required + optional keywords ARE handled -- we walk them in
     * insertion order (head/next linked list; rbs_hash_set appends
     * to tail, matching RBS source order) and append the value types
     * to the ptype list after the required positionals. The arity
     * lines up with the Ruby def order spinel's collect_all sees.
     *
     * NOTE: rbs_hash_t.length is not incremented by rbs_hash_set
     * (upstream rbs/ast.c#rbs_hash_set inserts into head/tail without
     * updating length). Detect emptiness via `head == NULL`, not via
     * `length`. Same applies in the walking code below.
     *
     * Positional rbs_node_list_t.length IS maintained by rbs_node_list_
     * append -- so the optional/trailing positional checks below use
     * `head == NULL` as the safer cross-cutting "is empty" predicate. */
    if ((fn->optional_positionals != NULL && fn->optional_positionals->head != NULL)
        || fn->rest_positionals != NULL
        || (fn->trailing_positionals != NULL && fn->trailing_positionals->head != NULL)
        || fn->rest_keywords != NULL) {
        return;
    }

    /* Map every required positional. If any maps as out-of-subset,
     * skip the whole signature -- the analyzer can't act on a
     * partially-typed method (would need a sentinel for "leave
     * alone" per-param, which the seed format doesn't have today). */
    sbuf_t ptypes;
    sbuf_init(&ptypes);
    bool first_p = true;
    if (fn->required_positionals != NULL) {
        rbs_node_list_node_t *cur = fn->required_positionals->head;
        while (cur != NULL) {
            if (cur->node->type != RBS_TYPES_FUNCTION_PARAM) { sbuf_free(&ptypes); return; }
            rbs_types_function_param_t *pp = (rbs_types_function_param_t *) cur->node;
            sbuf_t t;
            sbuf_init(&t);
            if (!map_type(p, pp->type, enclosing_scope, &t)) { sbuf_free(&t); sbuf_free(&ptypes); return; }
            if (!first_p) sbuf_append_cstr(&ptypes, ",");
            sbuf_append(&ptypes, t.buf, t.len);
            first_p = false;
            sbuf_free(&t);
            cur = cur->next;
        }
    }

    /* Required + optional keywords. Both are stored as rbs_hash
     * mapping name-Symbol → function_param. The hash is insertion-
     * ordered (head/tail linked list); RBS's parser inserts kwargs in
     * source order. We walk required then optional, mapping each
     * param's value type. The arity adds up to (positionals +
     * required_kwargs + optional_kwargs), matching Ruby's def in
     * source-order -- same shape collect_all sees. Optionality is an
     * arity-affecting source property and doesn't change the type
     * slot the seed targets. */
    const rbs_hash_t *kw_hashes[] = { fn->required_keywords, fn->optional_keywords };
    for (size_t ki = 0; ki < sizeof(kw_hashes)/sizeof(kw_hashes[0]); ki++) {
        const rbs_hash_t *hash = kw_hashes[ki];
        if (hash == NULL) continue;
        rbs_hash_node_t *cur = hash->head;
        while (cur != NULL) {
            /* Defensive: an upstream rbs change adding a different
             * value-node type would land here. Skipping the whole
             * signature (rather than producing a partial seed) keeps
             * the analyzer consistent -- apply_rbs_seeds overwrites a
             * method's ptype list wholesale, so a half-populated entry
             * is worse than no entry. Same policy as the positional
             * loop above and the existing out-of-subset early-return. */
            if (cur->value == NULL || cur->value->type != RBS_TYPES_FUNCTION_PARAM) {
                sbuf_free(&ptypes); return;
            }
            rbs_types_function_param_t *pp = (rbs_types_function_param_t *) cur->value;
            sbuf_t t;
            sbuf_init(&t);
            if (!map_type(p, pp->type, enclosing_scope, &t)) { sbuf_free(&t); sbuf_free(&ptypes); return; }
            if (!first_p) sbuf_append_cstr(&ptypes, ",");
            sbuf_append(&ptypes, t.buf, t.len);
            first_p = false;
            sbuf_free(&t);
            cur = cur->next;
        }
    }

    if (ptypes.len == 0) sbuf_append_cstr(&ptypes, "-");

    sbuf_t ret;
    sbuf_init(&ret);
    if (!map_type(p, fn->return_type, enclosing_scope, &ret)) { sbuf_free(&ret); sbuf_free(&ptypes); return; }

    sbuf_t mname;
    sbuf_init(&mname);
    name_of_symbol(p, m->name, &mname);

    bool emit_inst = (m->kind == RBS_METHOD_DEFINITION_KIND_INSTANCE)
                  || (m->kind == RBS_METHOD_DEFINITION_KIND_SINGLETON_INSTANCE);
    bool emit_cls  = (m->kind == RBS_METHOD_DEFINITION_KIND_SINGLETON)
                  || (m->kind == RBS_METHOD_DEFINITION_KIND_SINGLETON_INSTANCE);

    if (emit_inst) fprintf(out, "meth %s %s %s\n",  mname.buf, ret.buf, ptypes.buf);
    if (emit_cls)  fprintf(out, "cmeth %s %s %s\n", mname.buf, ret.buf, ptypes.buf);

    sbuf_free(&mname);
    sbuf_free(&ret);
    sbuf_free(&ptypes);
}

/* ---- emit attr_accessor / reader / writer ------------------ */

static void emit_attr(rbs_parser_t *p, rbs_ast_symbol_t *name, rbs_node_t *type,
                      const char *enclosing_scope, FILE *out) {
    sbuf_t t;
    sbuf_init(&t);
    if (!map_type(p, type, enclosing_scope, &t)) { sbuf_free(&t); return; }
    sbuf_t n;
    sbuf_init(&n);
    name_of_symbol(p, name, &n);
    fprintf(out, "ivar %s %s\n", n.buf, t.buf);
    sbuf_free(&n);
    sbuf_free(&t);
}

/* ---- traverse class/module body ---------------------------- */

/* `qualified_scope` is this declaration's full path (used as the
 * `class X` line). `lookup_scope` is the *parent* path (used to
 * resolve unqualified type references inside the members). For
 * `module ActiveRecord; class RecordInvalid; def record: () -> Base`:
 * qualified_scope = "ActiveRecord_RecordInvalid",
 * lookup_scope    = "ActiveRecord".
 * That makes `Base` resolve to `obj_ActiveRecord_Base` -- the sibling-
 * in-module pattern, which dominates real RBS in practice. Ruby's
 * actual constant lookup walks every enclosing scope outward; this
 * single-level fallback covers the common case without a symbol
 * table. */
static void traverse_members(rbs_parser_t *p, rbs_node_list_t *members,
                             const char *qualified_scope,
                             const char *lookup_scope, FILE *out) {
    if (members == NULL || members->length == 0) return;
    fprintf(out, "class %s\n", qualified_scope);
    const char *sv_self_scope = g_self_scope;
    g_self_scope = qualified_scope;
    rbs_node_list_node_t *cur = members->head;
    while (cur != NULL) {
        rbs_node_t *n = cur->node;
        switch (n->type) {
            case RBS_AST_MEMBERS_METHOD_DEFINITION:
                emit_method(p, (rbs_ast_members_method_definition_t *) n, lookup_scope, out);
                break;
            case RBS_AST_MEMBERS_ATTR_ACCESSOR: {
                rbs_ast_members_attr_accessor_t *a = (rbs_ast_members_attr_accessor_t *) n;
                emit_attr(p, a->name, a->type, lookup_scope, out);
                break;
            }
            case RBS_AST_MEMBERS_ATTR_READER: {
                rbs_ast_members_attr_reader_t *a = (rbs_ast_members_attr_reader_t *) n;
                emit_attr(p, a->name, a->type, lookup_scope, out);
                break;
            }
            case RBS_AST_MEMBERS_ATTR_WRITER: {
                rbs_ast_members_attr_writer_t *a = (rbs_ast_members_attr_writer_t *) n;
                emit_attr(p, a->name, a->type, lookup_scope, out);
                break;
            }
            case RBS_AST_MEMBERS_INSTANCE_VARIABLE: {
                /* `@name: Type` declarations. seed_class_ivar in
                 * analyze prepends "@" if missing; emit_attr writes
                 * the name as-is (which in RBS includes the leading
                 * @), so the seed line ends up with "@@name" if we
                 * don't strip first. The seed_class_ivar handles
                 * either form, but normalize here so the seed file
                 * matches the attr_* shape (single `@`). */
                rbs_ast_members_instance_variable_t *iv = (rbs_ast_members_instance_variable_t *) n;
                emit_attr(p, iv->name, iv->type, lookup_scope, out);
                break;
            }
            default:
                /* Skip: include / extend / prepend / public / private
                 * / alias / class_variable. */
                break;
        }
        cur = cur->next;
    }
    g_self_scope = sv_self_scope;
}

/* Pre-pass: collect every Class/Module declaration's qualified name
 * (with "_" separators) into known_names. Recurses through members so
 * `module A; module B; class C` registers all of A, A_B, A_B_C. The
 * later emit pass uses the set to disambiguate unqualified type
 * references (issue #656). */
static void collect_decl_names(rbs_parser_t *p, rbs_node_t *node,
                                const char *parent_scope) {
    sbuf_t leaf;
    sbuf_init(&leaf);
    rbs_node_list_t *members = NULL;

    if (node->type == RBS_AST_DECLARATIONS_CLASS) {
        rbs_ast_declarations_class_t *c = (rbs_ast_declarations_class_t *) node;
        name_of_type_name(p, c->name, &leaf);
        members = c->members;
    }
else if (node->type == RBS_AST_DECLARATIONS_MODULE) {
        rbs_ast_declarations_module_t *m = (rbs_ast_declarations_module_t *) node;
        name_of_type_name(p, m->name, &leaf);
        members = m->members;
    }
else {
        sbuf_free(&leaf);
        return;
    }

    sbuf_t qualified;
    sbuf_init(&qualified);
    if (parent_scope != NULL && parent_scope[0] != '\0') {
        sbuf_append_cstr(&qualified, parent_scope);
        sbuf_append_cstr(&qualified, "_");
    }
    sbuf_append(&qualified, leaf.buf, leaf.len);
    known_names_add(qualified.buf, qualified.len);

    if (members != NULL) {
        rbs_node_list_node_t *cur = members->head;
        while (cur != NULL) {
            if (cur->node->type == RBS_AST_DECLARATIONS_CLASS
                || cur->node->type == RBS_AST_DECLARATIONS_MODULE) {
                collect_decl_names(p, cur->node, qualified.buf);
            }
            cur = cur->next;
        }
    }

    sbuf_free(&qualified);
    sbuf_free(&leaf);
}

/* Recurse into a declaration. For Class/Module: extend the scope path
 * with the declaration's leaf name, emit members, then recurse into
 * any nested Class/Module members so e.g. `module Foo; class Bar; end;
 * end` produces a `class Foo::Bar` block. */
static void traverse_decl(rbs_parser_t *p, rbs_node_t *node,
                          const char *parent_scope, FILE *out) {
    sbuf_t leaf;
    sbuf_init(&leaf);
    rbs_node_list_t *members = NULL;

    if (node->type == RBS_AST_DECLARATIONS_CLASS) {
        rbs_ast_declarations_class_t *c = (rbs_ast_declarations_class_t *) node;
        name_of_type_name(p, c->name, &leaf);
        members = c->members;
    }
else if (node->type == RBS_AST_DECLARATIONS_MODULE) {
        rbs_ast_declarations_module_t *m = (rbs_ast_declarations_module_t *) node;
        name_of_type_name(p, m->name, &leaf);
        members = m->members;
    }
else {
        /* Skip Interface, Constant, Global, TypeAlias, ClassAlias,
         * ModuleAlias, Directives. */
        sbuf_free(&leaf);
        return;
    }

    /* qualified = parent_scope (if any) "_" + leaf -- spinel's
     * nested-class storage uses underscore as separator. */
    sbuf_t qualified;
    sbuf_init(&qualified);
    if (parent_scope != NULL && parent_scope[0] != '\0') {
        sbuf_append_cstr(&qualified, parent_scope);
        sbuf_append_cstr(&qualified, "_");
    }
    sbuf_append(&qualified, leaf.buf, leaf.len);

    traverse_members(p, members, qualified.buf, parent_scope, out);

    /* Recurse into nested declarations. */
    if (members != NULL) {
        rbs_node_list_node_t *cur = members->head;
        while (cur != NULL) {
            if (cur->node->type == RBS_AST_DECLARATIONS_CLASS
                || cur->node->type == RBS_AST_DECLARATIONS_MODULE) {
                traverse_decl(p, cur->node, qualified.buf, out);
            }
            cur = cur->next;
        }
    }

    sbuf_free(&qualified);
    sbuf_free(&leaf);
}

/* ---- per-file processing ----------------------------------- */

/* Read a file fully into a malloc'd buffer. Returns NULL on failure;
 * sets *len_out to the byte count on success. */
static char *slurp(const char *path, size_t *len_out) {
    FILE *fp = fopen(path, "rb");
    if (fp == NULL) return NULL;
    if (fseek(fp, 0, SEEK_END) != 0) { fclose(fp); return NULL; }
    long sz = ftell(fp);
    if (sz < 0) { fclose(fp); return NULL; }
    if (fseek(fp, 0, SEEK_SET) != 0) { fclose(fp); return NULL; }
    char *buf = (char *) malloc((size_t) sz + 1);
    if (buf == NULL) { fclose(fp); return NULL; }
    size_t got = fread(buf, 1, (size_t) sz, fp);
    fclose(fp);
    buf[got] = '\0';
    *len_out = got;
    return buf;
}

/* Per-pass selector for process_file. Splitting the per-file work
 * into two phases (collect names; emit decls) lets walk() run twice
 * over the directory tree so cross-file module reopens have every
 * class registered before any unqualified-Const reference is
 * resolved. Issue #658. */
typedef enum {
    PHASE_COLLECT_NAMES = 0,
    PHASE_EMIT = 1
} process_phase_t;

static void process_file_phase(const char *path, FILE *out, process_phase_t phase) {
    size_t len = 0;
    char *src = slurp(path, &len);
    if (src == NULL) {
        fprintf(stderr, "spinel_rbs_extract: cannot read %s\n", path);
        return;
    }
    rbs_string_t str = rbs_string_new(src, src + len);
    rbs_parser_t *p = rbs_parser_new(str, RBS_ENCODING_UTF_8_ENTRY, 0, (int) len);
    if (p == NULL) { free(src); return; }
    rbs_signature_t *sig = NULL;
    bool ok = rbs_parse_signature(p, &sig);
    if (!ok || sig == NULL) {
        if (phase == PHASE_EMIT) {
            fprintf(stderr, "spinel_rbs_extract: parse failed in %s\n", path);
            if (p->error != NULL && p->error->message != NULL) {
                fprintf(stderr, "  %s\n", p->error->message);
            }
        }
        rbs_parser_free(p);
        free(src);
        return;
    }
    if (phase == PHASE_COLLECT_NAMES) {
        rbs_node_list_node_t *pre = sig->declarations->head;
        while (pre != NULL) {
            collect_decl_names(p, pre->node, "");
            pre = pre->next;
        }
    }
else {
        rbs_node_list_node_t *cur = sig->declarations->head;
        while (cur != NULL) {
            traverse_decl(p, cur->node, "", out);
            cur = cur->next;
        }
    }
    rbs_parser_free(p);
    free(src);
}

static void process_file(const char *path, FILE *out) {
    process_file_phase(path, out, PHASE_EMIT);
}

/* ---- directory walk ---------------------------------------- */

static bool ends_with(const char *s, const char *suffix) {
    size_t sl = strlen(s), su = strlen(suffix);
    if (su > sl) return false;
    return strcmp(s + sl - su, suffix) == 0;
}

/* The directories on the current path, by identity. stat() follows symlinks,
 * so a link that points at an ancestor resolves to that ancestor's dev/ino and
 * the descent stops there instead of running down the cycle until the path
 * buffer or the kernel's symlink limit ends it -- which is what printed a
 * thirty-levels-deep path and called it `not found` (#4159). Only ANCESTORS
 * are compared, as find -L does: a directory legitimately reachable by two
 * different paths is still visited under each, since neither is inside the
 * other. The chain lives on the C stack, so the walk allocates nothing. */
typedef struct dir_chain_s {
    dev_t dev;
    ino_t ino;
    const struct dir_chain_s *up;
} dir_chain;

static void walk_phase_in(const char *path, FILE *out, process_phase_t phase,
                          const dir_chain *up) {
    struct stat st;
    if (stat(path, &st) != 0) {
        if (phase == PHASE_EMIT) {
            /* say what the filesystem answered: `not found` was printed for
               every reason stat can fail, including the cycle above */
            fprintf(stderr, "spinel_rbs_extract: %s: %s\n", path, strerror(errno));
        }
        return;
    }
    if (S_ISREG(st.st_mode)) {
        if (ends_with(path, ".rbs")) process_file_phase(path, out, phase);
        return;
    }
    if (!S_ISDIR(st.st_mode)) return;
    for (const dir_chain *p = up; p != NULL; p = p->up) {
        /* already on the way in: a symlink closed a loop. Not an error --
           publishing a tree with such a link is ordinary (tree-sitter ships
           lib/src/unicode/unicode -> .) -- so stop quietly. */
        if (p->dev == st.st_dev && p->ino == st.st_ino) return;
    }
    dir_chain here = { st.st_dev, st.st_ino, up };
    DIR *d = opendir(path);
    if (d == NULL) return;
    struct dirent *ent;
    while ((ent = readdir(d)) != NULL) {
        if (ent->d_name[0] == '.') continue;
        char full[4096];
        int n = snprintf(full, sizeof(full), "%s/%s", path, ent->d_name);
        if (n < 0 || (size_t) n >= sizeof(full)) {
            if (phase == PHASE_EMIT) {
                fprintf(stderr, "spinel_rbs_extract: path too long, skipping: %s/%s\n",
                        path, ent->d_name);
            }
            continue;
        }
        walk_phase_in(full, out, phase, &here);
    }
    closedir(d);
}

static void walk_phase(const char *path, FILE *out, process_phase_t phase) {
    walk_phase_in(path, out, phase, NULL);
}

static void walk(const char *path, FILE *out) { walk_phase(path, out, PHASE_EMIT); }

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Usage: spinel_rbs_extract DIR [DIR ...]\n");
        return 1;
    }
    /* Two-pass walk: first phase collects every Class / Module's
     * qualified name across all .rbs files into known_names; second
     * phase emits decls. Splitting the pre-pass from the emit pass
     * lets a bare `Bar` inside `baz.rbs`'s reopen of `module Foo`
     * see `Foo::Bar` from a sibling `bar.rbs` regardless of which
     * file readdir visited first. Issue #658 (followup to #656). */
    for (int i = 1; i < argc; i++) {
        walk_phase(argv[i], stdout, PHASE_COLLECT_NAMES);
    }
    for (int i = 1; i < argc; i++) {
        walk_phase(argv[i], stdout, PHASE_EMIT);
    }
    return 0;
}
