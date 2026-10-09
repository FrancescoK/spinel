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
 *   spinel_rbs_extract [--positions] DIR [DIR ...]
 *
 * Walks each DIR recursively for *.rbs files, writes seed lines to
 * stdout (with --positions, each preceded by `src FILE:LINE`). The `spinel` wrapper captures stdout to a tmpfile and
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
#include "rbs_map.h"

/* --positions: each seed line is preceded by `src FILE:LINE`, its place in
 * the .rbs file, so the analyzer can name it when an inline RBS annotation
 * in the program says something else (docs/inline-rbs.md). */
static int g_positions = 0;
static const char *g_cur_path = NULL;
static size_t *g_cur_newlines = NULL;
static size_t g_cur_newlines_len = 0;

/* Source locations are byte offsets. Index once per file: parent members
 * are emitted before nested declarations, so lookups can move backwards. */
static void index_positions(const char *src, size_t len) {
    size_t count = 0;
    for (size_t i = 0; i < len && src[i]; i++) if (src[i] == '\n') count++;
    if (count == 0) return;
    g_cur_newlines = (size_t *) malloc(count * sizeof(size_t));
    if (g_cur_newlines == NULL) {
        fprintf(stderr, "spinel_rbs_extract: out of memory\n");
        exit(1);
    }
    for (size_t i = 0; i < len && src[i]; i++) {
        if (src[i] == '\n') g_cur_newlines[g_cur_newlines_len++] = i;
    }
}

static void emit_position(FILE *out, int byte_pos) {
    if (!g_positions || g_cur_path == NULL) return;
    size_t lo = 0, hi = g_cur_newlines_len;
    if (byte_pos > 0) {
        while (lo < hi) {
            size_t mid = lo + (hi - lo) / 2;
            if (g_cur_newlines[mid] < (size_t) byte_pos) lo = mid + 1;
            else hi = mid;
        }
    }
    fprintf(out, "src %s:%zu\n", g_cur_path, lo + 1);
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

    emit_position(out, m->base.location.start_byte);
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
    emit_position(out, name ? name->base.location.start_byte : 0);
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
    g_cur_path = path;
    if (g_positions && phase == PHASE_EMIT) index_positions(src, len);
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
    g_cur_path = NULL;
    free(g_cur_newlines);
    g_cur_newlines = NULL;
    g_cur_newlines_len = 0;
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
    if (argc > 1 && strcmp(argv[1], "--positions") == 0) {
        g_positions = 1;
        argv++;
        argc--;
    }
    if (argc < 2) {
        fprintf(stderr, "Usage: spinel_rbs_extract [--positions] DIR [DIR ...]\n");
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
