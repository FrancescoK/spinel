/* The recorder's literal declaration contract becomes ordinary Ruby AST
 * before scope registration. Method lookup, reachability and call plans then
 * see the same definitions as Ruby-written methods. */
#include "analyze_internal.h"
#include "codegen_internal.h"
#include "cext_bridge.h"
#include <ctype.h>
NodeTable *sp_parse_snippet(const char *src);

static const char *text(Compiler *c, int site, int n) {
  if (nt_kind(c->nt, n) != NK_StringNode)
    unsupported_feature(c, site, "C extension declarations require literal strings");
  return nt_str(c->nt, n, "content");
}
static long long integer(Compiler *c, int site, int n) {
  if (nt_kind(c->nt, n) == NK_IntegerNode) return nt_int(c->nt, n, "value", 0);
  if (nt_kind(c->nt, n) == NK_CallNode && nt_str(c->nt, n, "name") &&
      sp_streq(nt_str(c->nt, n, "name"), "-@"))
    return -integer(c, site, nt_ref(c->nt, n, "receiver"));
  unsupported_feature(c, site, "C extension declarations require literal integers");
}
static int boolean(Compiler *c, int site, int n) {
  if (nt_kind(c->nt, n) == NK_TrueNode) return 1;
  if (nt_kind(c->nt, n) == NK_FalseNode) return 0;
  unsupported_feature(c, site, "C extension declarations require literal booleans");
}
static void need(Compiler *c, int site, int actual, int expected) {
  if (actual != expected) unsupported_feature(c, site, "invalid C extension declaration argument count");
}
static void path(Compiler *c, int site, const char *s) {
  const char *p = s;
  for (;;) {
    if (!p || !isupper((unsigned char)*p))
      unsupported_feature(c, site, "invalid C extension constant path");
    while (isalnum((unsigned char)*p) || *p == '_') p++;
    if (!*p) return;
    if (p[0] != ':' || p[1] != ':')
      unsupported_feature(c, site, "invalid C extension constant path");
    p += 2;
  }
}
static void symbol(Buf *b, const char *s) {
  buf_puts(b, ":'");
  for (const char *p = s; *p; p++) {
    if (*p == '\'' || *p == '\\') buf_puts(b, "\\");
    buf_putn(b, p, 1);
  }
  buf_puts(b, "'");
}
static void graft(Compiler *c, int site, Buf *b, int ext, int slot, int arity) {
  NodeTable *nt = (NodeTable *)c->nt;
  NodeTable *tmp = sp_parse_snippet(b->p ? b->p : "nil");
  if (!tmp) unsupported_feature(c, site, "invalid recorder declaration");
  int st = nt_ref(tmp, tmp->root_id, "statements");
  int ns = 0; const int *nodes = nt_arr(tmp, st, "body", &ns);
  if (ns != 1) unsupported_feature(c, site, "recorder declaration must produce one statement");
  int root = nt_import_subtree(nt, tmp, nodes[0]);
  nt_free(tmp);
  if (root < 0) unsupported_feature(c, site, "cannot import recorder declaration");
  int line = nt_int(nt, site, "node_line", 1), file = nt_int(nt, site, "node_file", -1);
  for (int i = root; i < nt->count; i++) {
    nt_node_set_int(nt, i, "node_line", line);
    if (file >= 0) nt_node_set_int(nt, i, "node_file", file);
    if (nt_kind(nt, i) == NK_CallNode) {
      const char *name = nt_str(nt, i, "name");
      if (name && !strncmp(name, "__cext_", 7)) nt_node_set_int(nt, i, "cext_synthetic", 1);
    }
    if (slot >= 0 && nt_kind(nt, i) == NK_ParametersNode) nt_node_set_int(nt, i, "cext_arity", arity);
    if (slot >= 0 && nt_kind(nt, i) == NK_ArrayNode) nt_node_set_int(nt, i, "cext_args", 1);
    if (slot >= 0 && nt_kind(nt, i) == NK_DefNode) {
      nt_node_set_int(nt, i, "cext_extension", ext + 1);
      nt_node_set_int(nt, i, "cext_function", slot);
      nt_node_set_int(nt, i, "cext_arity", arity);
    }
  }
  nt_swap_nodes(nt, site, root);
  nt_node_reset(nt, root, "NilNode");
  free(b->p);
  memset(b, 0, sizeof(*b));
}
static int owner_module(const Compiler *c, const char *name) {
  for (int i = c->n_cext_classes - 1; i >= 0; i--)
    if (sp_streq(c->cext_classes[i].path, name)) return c->cext_classes[i].module;
  return is_builtin_module_const_name(name);
}
static void owner_open(Compiler *c, int site, Buf *b, const char *name) {
  path(c, site, name);
  buf_printf(b, "%s %s\n", owner_module(c, name) ? "module" : "class", name);
}
void desugar_cext_decls(Compiler *c) {
  if (!c->nt->has_cext_decls) return;
  NodeTable *nt = (NodeTable *)c->nt;
  int n0 = nt->count, ext = -1;
  for (int site = 0; site < n0; site++) {
    if (nt_kind(nt, site) != NK_CallNode || nt_ref(nt, site, "receiver") >= 0) continue;
    const char *name0 = nt_str(nt, site, "name");
    if (!name0 || strncmp(name0, "__cext_", 7)) continue;
    char *name = strdup(name0);
    int an = nt_ref(nt, site, "arguments"), ac = 0;
    const int *av0 = an >= 0 ? nt_arr(nt, an, "arguments", &ac) : NULL;
    int *av = malloc(sizeof(int) * (size_t)(ac + 1));
    if (ac) memcpy(av, av0, sizeof(int) * (size_t)ac);
    Buf b = {0}; int slot = -1, arity = 0;
    if (sp_streq(name, "__cext_extension")) {
      need(c, site, ac, 3);
      const char *en = text(c, site, av[0]), *init = text(c, site, av[1]);
      if (integer(c, site, av[2]) != 1) unsupported_feature(c, site, "unsupported C extension manifest version");
      if (strncmp(init, "Init_", 5)) unsupported_feature(c, site, "invalid C extension initializer");
      for (const char *p = init; *p; p++)
        if (!isalnum((unsigned char)*p) && *p != '_') unsupported_feature(c, site, "invalid C extension initializer");
      for (int q = 0; q < c->n_cext_extensions; q++)
        if (sp_streq(c->cext_extensions[q].name, en)) unsupported_feature(c, site, "duplicate C extension manifest");
      ext = c->n_cext_extensions++;
      c->cext_extensions = realloc(c->cext_extensions, sizeof(CextExtension) * (size_t)c->n_cext_extensions);
      c->cext_extensions[ext] = (CextExtension){strdup(en), strdup(init), 0, 0};
      buf_printf(&b, "__cext_init(%d)", ext);
    } else {
      if (ext < 0) unsupported_feature(c, site, "C extension declaration precedes its manifest header");
      if (sp_streq(name, "__cext_class") || sp_streq(name, "__cext_module")) {
        int mod = sp_streq(name, "__cext_module"); need(c, site, ac, mod ? 1 : 2);
        const char *cn = text(c, site, av[0]); path(c, site, cn);
        const char *parent = mod ? NULL : text(c, site, av[1]); if (parent) path(c, site, parent);
        int q = c->n_cext_classes++;
        c->cext_classes = realloc(c->cext_classes, sizeof(CextClass) * (size_t)c->n_cext_classes);
        c->cext_classes[q] = (CextClass){strdup(cn), mod, ext, -1};
        buf_printf(&b, "%s %s", mod ? "module" : "class", cn);
        if (parent) buf_printf(&b, " < %s", parent);
        buf_puts(&b, "\nend\n");
      } else if (sp_streq(name, "__cext_method")) {
        need(c, site, ac, 6);
        const char *cn = text(c, site, av[0]), *mn = text(c, site, av[1]);
        const char *scope = text(c, site, av[2]), *vis = text(c, site, av[3]);
        arity = (int)integer(c, site, av[4]); slot = (int)integer(c, site, av[5]);
        if (arity < -2 || arity > 15 || slot != c->cext_extensions[ext].slots++)
          unsupported_feature(c, site, "unsupported C extension arity or registration order");
        if (!sp_streq(scope, "instance") && !sp_streq(scope, "singleton")) unsupported_feature(c, site, "invalid C extension method scope");
        if (!sp_streq(vis, "private") && !sp_streq(vis, "public")) unsupported_feature(c, site, "invalid C extension visibility");
        if (sp_streq(vis, "private") && sp_streq(scope, "singleton"))
          unsupported_feature(c, site, "private C extension singleton methods are unsupported");
        owner_open(c, site, &b, cn);
        if (sp_streq(vis, "private") && sp_streq(scope, "instance")) buf_puts(&b, "private ");
        buf_printf(&b, "def %s__cext_method(", sp_streq(scope, "singleton") ? "self." : "");
        /* Fixed arguments must use ordinary arity validation; the double-underscore
         * convention exempts compiler forwarding slots from those checks. */
        if (arity < 0) buf_puts(&b, "*__cext_args");
        else for (int j = 0; j < arity; j++) buf_printf(&b, "%s_cext_a%d", j ? ", " : "", j);
        buf_puts(&b, arity == 0 ? "&__cext_block)\n" : ", &__cext_block)\n");
        buf_printf(&b, "__cext_invoke(%d, %d, self, ", ext, slot);
        if (arity < 0) buf_puts(&b, "__cext_args");
        else {
          buf_puts(&b, "[");
          for (int j = 0; j < arity; j++) buf_printf(&b, "%s_cext_a%d", j ? ", " : "", j);
          buf_puts(&b, "]");
        }
        buf_puts(&b, ", __cext_block)\nend\nend\n");
      } else if (sp_streq(name, "__cext_allocator")) {
        need(c, site, ac, 2); const char *cn = text(c, site, av[0]);
        int alloc = (int)integer(c, site, av[1]);
        if (alloc != c->cext_extensions[ext].slots++) unsupported_feature(c, site, "invalid C extension allocator registration order");
        int found = 0;
        for (int q = 0; q < c->n_cext_classes; q++) if (sp_streq(c->cext_classes[q].path, cn)) {
          c->cext_classes[q].allocator = alloc; found = 1;
        }
        if (!found) unsupported_feature(c, site, "C extension allocator needs a manifest class");
        buf_puts(&b, "nil");
      } else if (sp_streq(name, "__cext_alias")) {
        need(c, site, ac, 3); owner_open(c, site, &b, text(c, site, av[0]));
        buf_puts(&b, "alias_method "); symbol(&b, text(c, site, av[1])); buf_puts(&b, ", "); symbol(&b, text(c, site, av[2])); buf_puts(&b, "\nend\n");
      } else if (sp_streq(name, "__cext_attribute")) {
        need(c, site, ac, 4); owner_open(c, site, &b, text(c, site, av[0]));
        int r = boolean(c, site, av[2]), w = boolean(c, site, av[3]);
        if (r || w) { buf_printf(&b, "attr_%s ", r && w ? "accessor" : r ? "reader" : "writer"); symbol(&b, text(c, site, av[1])); }
        buf_puts(&b, "\nend\n");
      } else if (sp_streq(name, "__cext_include") || sp_streq(name, "__cext_extend")) {
        need(c, site, ac, 2); owner_open(c, site, &b, text(c, site, av[0]));
        const char *mod = text(c, site, av[1]); path(c, site, mod);
        buf_printf(&b, "%s %s\nend\n", name + 7, mod);
      } else if (sp_streq(name, "__cext_literal_id")) {
        need(c, site, ac, 1); symbol(&b, text(c, site, av[0]));
      } else if (sp_streq(name, "__cext_funcall_arity")) {
        need(c, site, ac, 1); (void)integer(c, site, av[0]); buf_puts(&b, "nil");
      } else if (sp_streq(name, "__cext_constant")) {
        need(c, site, ac, 6);
        const char *cn = text(c, site, av[0]), *key = text(c, site, av[1]);
        path(c, site, cn); path(c, site, key);
        int idx = c->cext_extensions[ext].constants++;
        if (!sp_streq(cn, "Object")) owner_open(c, site, &b, cn);
        buf_printf(&b, "%s = __cext_constant_value(%d, %d)\n", key, ext, idx);
        if (!sp_streq(cn, "Object")) buf_puts(&b, "end\n");
      } else unsupported_feature(c, site, "unknown C extension declaration");
    }
    int imported = nt->count;
    graft(c, site, &b, ext, slot, arity);
    if (slot >= 0) {
      const char *mn = text(c, site, av[1]);
      for (int j = imported; j < nt->count; j++)
        if (nt_kind(nt, j) == NK_DefNode) nt_node_set_str(nt, j, "name", mn);
    }
    free(av); free(name);
  }
  if (c->n_cext_extensions) comp_grow_node_arrays(c);
}
int cext_scope(const Compiler *c, int mi) {
  return c->n_cext_extensions && mi >= 0 && mi < c->nscopes && c->scopes[mi].def_node >= 0 &&
    nt_int(c->nt, c->scopes[mi].def_node, "cext_extension", 0) != 0;
}
void register_cext_layouts(Compiler *c) {
  if (!c->n_cext_extensions) return;
  for (int mi = 0; mi < c->nscopes; mi++) if (cext_scope(c, mi)) {
    Scope *s = &c->scopes[mi];
    for (int p = 0; p < s->nparams; p++) {
      LocalVar *lv = scope_local(s, s->pnames[p]);
      if (lv) lv->type = p == s->rest_idx ? TY_POLY_ARRAY : TY_POLY;
    }
  }
  for (int q = 0; q < c->n_cext_classes; q++) {
    CextClass *cc = &c->cext_classes[q];
    int cid = -1;
    for (int k = 0; k < c->nclasses; k++) {
      const char *ruby_name = class_ruby_name(c, k);
      if (ruby_name && sp_streq(ruby_name, cc->path)) { cid = k; break; }
    }
    if (cid < 0) unsupported_feature(c, c->nt->root_id, "C extension class was not registered");
    if (cc->allocator >= 0) {
      c->classes[cid].cext_layout = 1;
      c->classes[cid].instantiated = 1;
      c->classes[cid].cext_extension = cc->extension + 1;
      c->classes[cid].cext_allocator = cc->allocator;
    }
  }
}

void inherit_cext_layouts(Compiler *c) {
  for (int round = 0; round < c->nclasses; round++) {
    int changed = 0;
    for (int k = 0; k < c->nclasses; k++) {
      ClassInfo *ci = &c->classes[k];
      if (ci->cext_extension || ci->parent < 0) continue;
      ClassInfo *parent = &c->classes[ci->parent];
      if (!parent->cext_extension) continue;
      ci->cext_extension = parent->cext_extension;
      ci->cext_allocator = parent->cext_allocator;
      changed = 1;
    }
    if (!changed) break;
  }
  for (int k = 0; k < c->nclasses; k++) if (c->classes[k].cext_extension) {
    if (c->classes[k].ary_root > 0 || class_is_exc_subclass(c, k))
      unsupported_feature(c, c->classes[k].def_node, "TypedData cannot use an embedded builtin layout");
    int top = k;
    while (c->classes[top].parent >= 0) top = c->classes[top].parent;
    for (int q = 0; q < c->nclasses; q++)
      for (int a = q; a >= 0; a = c->classes[a].parent)
        if (a == top) { c->classes[q].cext_layout = 1; break; }
  }
}
