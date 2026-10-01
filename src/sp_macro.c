/* Class-body macro expansion (included into spinel_parse.c).
 *
 * Library code often builds its class bodies with "macro" methods: a module
 * the class extends defines methods that the class body calls with literal
 * arguments, and those methods compute names and generate code at load time:
 *
 *   module Sodium
 *     def sodium_function(name, function, arguments)
 *       module_eval <<-RUBY
 *       attach_function #{function.inspect}, #{arguments.inspect}, :int
 *       def self.#{name}(*args) = #{function}(*args) == 0
 *       RUBY
 *     end
 *   end
 *   class Box
 *     extend Sodium
 *     sodium_function :box, :crypto_box, %i[pointer pointer]
 *   end
 *
 * Every name here is known when the program is compiled; only the evaluation
 * is dynamic. This pass evaluates such a call over the Prism tree of the whole
 * program -- literals, string building and interpolation, arrays, locals, and
 * calls to the module's other macros -- and writes what remains (the
 * attach_function, the constant, the module_eval'd source) back into the class
 * body as ordinary Ruby in place of the call:
 *
 *   attach_function "crypto_box", [...], :int; def self.box(*args) = crypto_box(*args) == 0
 *
 * A call is replaced only when the program leaves no other way for the call to
 * be answered, and only when its macro does something the compiler cannot do
 * at run time (string module_eval/class_eval, const_set, define_method,
 * public_send/send, attach_function with a computed name):
 *
 *  - the macro's name is defined once in the whole program (by any module),
 *    and no class method, alias or define_singleton_method of that name exists
 *    -- which method a call reaches then does not depend on the order of the
 *    class's extends;
 *  - the class extended the macro's module at the top level of its body, before
 *    the call;
 *  - no `private`/`protected`/`public` without arguments came before it in the
 *    class (an inlined `def` would take that visibility, a module_eval'd one
 *    does not).
 *
 * The macro's ivars are not followed: a macro that reads or writes one is not
 * evaluated, and its call stays as written. So does anything else the
 * evaluator does not understand. A replacement keeps the call's line count. */
typedef enum { MV_UNDEF = 0, MV_NIL, MV_TRUE, MV_FALSE, MV_INT, MV_STR, MV_SYM, MV_ARR } MvKind;

typedef struct Mv { MvKind k; long long i; char *s; struct Mv *a; int n; } Mv;

typedef struct { char *name; Mv v; } MxVar;

typedef struct {
  char *module;           /* the path of the module that defines it */
  char *name;             /* the method's name */
  int next_same;          /* the next macro of this name, or -1 */
  pm_def_node_t *def;
  int dynamic;            /* -1 unknown, 0 no, 1 yes */
  int expanded;           /* call sites replaced by their expansion */
  const pm_node_t *sites[512]; /* (debug) the expanded calls */
} MxMacro;

typedef struct MxBuf { char *p; size_t len, cap; } MxBuf;

static MxMacro *g_mx_macros; static int g_mx_nmacros, g_mx_cmacros;

static void mxb_putn(MxBuf *b, const char *s, size_t n) {
  if (b->len + n + 1 > b->cap) {
    b->cap = (b->len + n + 1) * 2 + 64;
    b->p = realloc(b->p, b->cap);
  }
  memcpy(b->p + b->len, s, n);
  b->len += n;
  b->p[b->len] = 0;
}

static void mxb_puts(MxBuf *b, const char *s) { mxb_putn(b, s, strlen(s)); }

typedef struct {
  MxVar loc[64]; int nloc;
  MxBuf *out;             /* residual code, or NULL: evaluate only */
  int returned; Mv ret;
  int stopped;            /* an unconditional raise was emitted */
  int in_ffi_rescue;      /* inside the rescue of a begin that attaches a function */
  int depth;
  const char *modname;    /* the path of the module whose macro runs */
} MxCtx;

static Mv mv_nil(void) { Mv v; memset(&v, 0, sizeof v); v.k = MV_NIL; return v; }

static Mv mv_str(const char *s, size_t n, MvKind k) {
  Mv v; memset(&v, 0, sizeof v); v.k = k;
  v.s = malloc(n + 1); memcpy(v.s, s, n); v.s[n] = 0;
  return v;
}

static int mv_truthy(Mv v) { return v.k != MV_NIL && v.k != MV_FALSE && v.k != MV_UNDEF; }

static Mv mv_undef(void) { Mv v; memset(&v, 0, sizeof v); v.k = MV_UNDEF; return v; }

static char *mx_name(pm_constant_id_t id) { return cstr(id); }

static void mv_to_s(Mv v, MxBuf *b) {
  char tmp[32];
  switch (v.k) {
  case MV_NIL: break;
  case MV_TRUE: mxb_puts(b, "true"); break;
  case MV_FALSE: mxb_puts(b, "false"); break;
  case MV_INT: snprintf(tmp, sizeof tmp, "%lld", v.i); mxb_puts(b, tmp); break;
  case MV_STR: case MV_SYM: mxb_puts(b, v.s); break;
  default: break;
  }
}

static int mx_sym_plain(const char *s) {
  if (!*s) return 0;
  if (!(isalpha((unsigned char)s[0]) || s[0] == '_')) return 0;
  for (const char *p = s; *p; p++) {
    if (isalnum((unsigned char)*p) || *p == '_') continue;
    if ((*p == '?' || *p == '!' || *p == '=') && p[1] == 0) continue;
    return 0;
  }
  return 1;
}

/* ---- may a string module_eval / class_eval be read as the body's own code?
   Text that a class body evaluates is spliced into it (a macro's module_eval
   here, a literal class_eval by desugar_static_class_eval), but CRuby runs
   it in a scope of its own, so a splice answers differently when the text
   - reads or writes a local, or names one Prism cannot tell from a call
     (`x`, `private`): the eval sees the caller's locals and keeps its own;
   - says a bare `private` / `protected` / `public` / `module_function`:
     it ends with the eval and does not reach the statements after it;
   - says `__LINE__`, `__FILE__` or `__dir__`: they answer the eval's
     arguments, not the line the text was written on;
   - evaluates a string itself (eval, class_eval, instance_eval, ...).
   Inside a `def` only the last two matter: a method body has its own
   scope either way. Such text is left to run time, refused as before. */
typedef struct { int bad; int in_def; } SpSnipScan;
static bool sp_snippet_visit(const pm_node_t *n, void *data) {
  SpSnipScan *s = data;
  if (s->bad) return false;
  switch (PM_NODE_TYPE(n)) {
  case PM_SOURCE_LINE_NODE: case PM_SOURCE_FILE_NODE:
    s->bad = 1; return false;
  case PM_DEF_NODE:
    if (!s->in_def) {
      SpSnipScan in = { 0, 1 };
      pm_visit_node(n, sp_snippet_visit, &in);
      if (in.bad) s->bad = 1;
      return false;
    }
    return true;
  case PM_LOCAL_VARIABLE_READ_NODE: case PM_LOCAL_VARIABLE_WRITE_NODE:
  case PM_LOCAL_VARIABLE_TARGET_NODE: case PM_LOCAL_VARIABLE_AND_WRITE_NODE:
  case PM_LOCAL_VARIABLE_OR_WRITE_NODE: case PM_LOCAL_VARIABLE_OPERATOR_WRITE_NODE:
    if (!s->in_def) { s->bad = 1; return false; }
    return true;
  case PM_CALL_NODE: {
    const pm_call_node_t *cn = (const pm_call_node_t *)n;
    if (!s->in_def && PM_NODE_FLAG_P(n, PM_CALL_NODE_FLAGS_VARIABLE_CALL)) { s->bad = 1; return false; }
    char *nm = cstr(cn->name);
    int ev = strcmp(nm, "eval") == 0 || strcmp(nm, "class_eval") == 0 || strcmp(nm, "module_eval") == 0 ||
             strcmp(nm, "instance_eval") == 0 || strcmp(nm, "class_exec") == 0 || strcmp(nm, "module_exec") == 0 ||
             strcmp(nm, "instance_exec") == 0 || strcmp(nm, "binding") == 0 || strcmp(nm, "__dir__") == 0;
    int vis = !cn->receiver && !cn->arguments && !cn->block &&
              (strcmp(nm, "private") == 0 || strcmp(nm, "protected") == 0 || strcmp(nm, "public") == 0 ||
               strcmp(nm, "module_function") == 0);
    free(nm);
    if (ev || (vis && !s->in_def)) { s->bad = 1; return false; }
    return true;
  }
  default:
    return true;
  }
}
/* 1 when `src` parses and reads the same spliced into the body (above) */
static int sp_snippet_graftable(const char *src) {
  if (!src) return 0;
  pm_parser_t parser;
  pm_parser_init(&parser, (const uint8_t *)src, strlen(src), NULL);
  pm_node_t *root = pm_parse(&parser);
  int ok = parser.error_list.size == 0;
  if (ok) {
    const pm_parser_t *saved = g_parser;   /* cstr reads the names from it */
    g_parser = &parser;
    SpSnipScan s = { 0, 0 };
    pm_visit_node(root, sp_snippet_visit, &s);
    g_parser = saved;
    ok = !s.bad;
  }
  pm_node_destroy(&parser, root);
  pm_parser_free(&parser);
  return ok;
}

static void mx_quote(const char *s, MxBuf *b) {
  mxb_puts(b, "\"");
  for (const char *p = s; *p; p++) {
    char e[8];
    unsigned char ch = (unsigned char)*p;
    if (ch == '"' || ch == '\\' || ch == '#') { e[0] = '\\'; e[1] = (char)ch; e[2] = 0; }
    else if (ch == '\n') strcpy(e, "\\n");
    else if (ch == '\t') strcpy(e, "\\t");
    else if (ch < 0x20) snprintf(e, sizeof e, "\\x%02x", ch);
    else { e[0] = (char)ch; e[1] = 0; }
    mxb_puts(b, e);
  }
  mxb_puts(b, "\"");
}

static void mv_inspect(Mv v, MxBuf *b) {
  switch (v.k) {
  case MV_NIL: mxb_puts(b, "nil"); break;
  case MV_STR: mx_quote(v.s, b); break;
  case MV_SYM:
    mxb_puts(b, ":");
    if (mx_sym_plain(v.s)) mxb_puts(b, v.s); else mx_quote(v.s, b);
    break;
  case MV_ARR:
    mxb_puts(b, "[");
    for (int i = 0; i < v.n; i++) { if (i) mxb_puts(b, ", "); mv_inspect(v.a[i], b); }
    mxb_puts(b, "]");
    break;
  default: mv_to_s(v, b); break;
  }
}

/* Does mv_inspect spell v exactly as CRuby's inspect does? It quotes for Ruby
   source (`"\#"`, `"\x1b"`), which reads back as the same value but is not
   the text CRuby prints, and quotes every operator Symbol (`:"+"`), so a
   value whose inspect becomes program DATA (output, a constant) is followed
   only when it is plain: printable ASCII Strings with nothing to escape,
   Symbols spelled as identifiers, integers, nil, booleans and Arrays of them. */
static int mv_inspect_exact(Mv v) {
  switch (v.k) {
  case MV_NIL: case MV_TRUE: case MV_FALSE: case MV_INT: return 1;
  case MV_STR:
    for (const char *p = v.s; *p; p++) {
      unsigned char ch = (unsigned char)*p;
      if (ch < 0x20 || ch > 0x7e || ch == '"' || ch == '\\' || ch == '#') return 0;
    }
    return 1;
  case MV_SYM: return mx_sym_plain(v.s);
  case MV_ARR:
    for (int i = 0; i < v.n; i++) if (!mv_inspect_exact(v.a[i])) return 0;
    return 1;
  default: return 0;
  }
}

static int mv_eq(Mv a, Mv b) {
  if (a.k != b.k) return 0;
  switch (a.k) {
  case MV_INT: return a.i == b.i;
  case MV_STR: case MV_SYM: return strcmp(a.s, b.s) == 0;
  case MV_ARR:
    if (a.n != b.n) return 0;
    for (int i = 0; i < a.n; i++) if (!mv_eq(a.a[i], b.a[i])) return 0;
    return 1;
  default: return 1;
  }
}

static Mv *mx_lookup(MxVar *vars, int n, const char *name) {
  for (int i = n - 1; i >= 0; i--) if (strcmp(vars[i].name, name) == 0) return &vars[i].v;
  return NULL;
}

static int g_mx_full;   /* a table was full: the evaluation cannot be trusted */
static void mx_set(MxVar *vars, int *n, int cap, const char *name, Mv v) {
  Mv *p = mx_lookup(vars, *n, name);
  if (p) { *p = v; return; }
  if (*n >= cap) { g_mx_full = 1; return; }
  vars[*n].name = strdup(name); vars[*n].v = v; (*n)++;
}

/* A set of names (strdup'd), in the order added, with a table to find one. */
typedef struct { char **v; int n; int *tab; int cap; } MxNames;

/* what the program defines, by name (filled by the collection pass) */
static MxNames g_mx_paths;   /* every class and module, by its lexical path */
static MxNames g_mx_defs;    /* the instance methods the modules define ... */
static MxNames g_mx_dup;     /* ... those defined more than once */
static MxNames g_mx_hidden;  /* names a class method, alias or define_singleton_method gives */
static int g_mx_hide_all;    /* ... and one named at run time outside any macro */

static unsigned mx_hash(const char *s) {
  unsigned h = 5381;
  while (*s) h = h * 33 + (unsigned char)*s++;
  return h;
}

static int mx_names_slot(const MxNames *l, const char *name) {
  if (!l->cap) return -1;
  unsigned mask = (unsigned)l->cap - 1;
  for (unsigned i = mx_hash(name) & mask; l->tab[i] >= 0; i = (i + 1) & mask)
    if (strcmp(l->v[l->tab[i]], name) == 0) return l->tab[i];
  return -1;
}

static void mx_names_add(MxNames *l, const char *name) {
  if (mx_names_slot(l, name) >= 0) return;
  if ((l->n + 1) * 2 > l->cap) {
    int cap = l->cap ? l->cap * 2 : 64;
    free(l->tab);
    l->tab = malloc(sizeof(int) * (size_t)cap);
    for (int i = 0; i < cap; i++) l->tab[i] = -1;
    l->cap = cap;
    for (int k = 0; k < l->n; k++) {
      unsigned i = mx_hash(l->v[k]) & ((unsigned)cap - 1);
      while (l->tab[i] >= 0) i = (i + 1) & ((unsigned)cap - 1);
      l->tab[i] = k;
    }
  }
  l->v = realloc(l->v, sizeof(char *) * (size_t)(l->n + 1));
  l->v[l->n] = strdup(name);
  unsigned i = mx_hash(name) & ((unsigned)l->cap - 1);
  while (l->tab[i] >= 0) i = (i + 1) & ((unsigned)l->cap - 1);
  l->tab[i] = l->n++;
}

static int mx_names_has(const MxNames *l, const char *name) { return mx_names_slot(l, name) >= 0; }

static void mx_names_free(MxNames *l) {
  for (int i = 0; i < l->n; i++) free(l->v[i]);
  free(l->v); free(l->tab);
  memset(l, 0, sizeof *l);
}

static const char *mx_names_find(const MxNames *l, const char *name) {
  int k = mx_names_slot(l, name);
  return k >= 0 ? l->v[k] : NULL;
}

/* the macros by name: a table to the first of each, the others chained */
static int *g_mx_mtab; static int g_mx_mcap;

static void mx_index_macros(void) {
  g_mx_mcap = 64;
  while (g_mx_mcap < 2 * g_mx_nmacros) g_mx_mcap *= 2;
  g_mx_mtab = malloc(sizeof(int) * (size_t)g_mx_mcap);
  for (int i = 0; i < g_mx_mcap; i++) g_mx_mtab[i] = -1;
  unsigned mask = (unsigned)g_mx_mcap - 1;
  for (int i = 0; i < g_mx_nmacros; i++) {
    MxMacro *m = &g_mx_macros[i];
    unsigned h = mx_hash(m->name) & mask;
    while (g_mx_mtab[h] >= 0 && strcmp(g_mx_macros[g_mx_mtab[h]].name, m->name) != 0) h = (h + 1) & mask;
    m->next_same = g_mx_mtab[h];
    g_mx_mtab[h] = i;
  }
}

static MxMacro *mx_first_named(const char *name) {
  if (!g_mx_mcap) return NULL;
  unsigned mask = (unsigned)g_mx_mcap - 1;
  for (unsigned i = mx_hash(name) & mask; g_mx_mtab[i] >= 0; i = (i + 1) & mask)
    if (strcmp(g_mx_macros[g_mx_mtab[i]].name, name) == 0) return &g_mx_macros[g_mx_mtab[i]];
  return NULL;
}

static MxMacro *mx_next_named(const MxMacro *m) { return m->next_same >= 0 ? &g_mx_macros[m->next_same] : NULL; }

#define MX_EACH_NAMED(m, nm) for (MxMacro *m = mx_first_named(nm); m; m = mx_next_named(m))

/* a module method by its name, in the module at `mod` (NULL: in any) */
static MxMacro *mx_find_macro(const char *mod, const char *name) {
  MX_EACH_NAMED(m, name) if (!mod || strcmp(m->module, mod) == 0) return m;
  return NULL;
}

/* may a call of this name reach a macro and nothing else? */
static int mx_name_unique(const char *name) {
  return !g_mx_hide_all && !mx_names_has(&g_mx_dup, name) && !mx_names_has(&g_mx_hidden, name);
}

/* May a call of this reflective primitive (const_set, module_eval, public_send,
   ...) reach Module's own? Not when the program gives the name a method of its
   own anywhere: a class method, an alias, a module method a class extends.
   Such a call is left as written, and refused as before. */
static int mx_prim_builtin(const char *name) {
  return mx_name_unique(name) && !mx_first_named(name);
}

/* the macro a call on self inside a macro body reaches: its own module's */
static MxMacro *mx_nested_macro(const char *modpath, const char *name) {
  if (!modpath || !mx_name_unique(name)) return NULL;
  return mx_find_macro(modpath, name);
}

/* the macro a class-body call reaches, when the program leaves one way only */
static MxMacro *mx_class_macro(const char *name) {
  if (!mx_name_unique(name)) return NULL;
  return mx_first_named(name);
}

static int mx_eval(MxCtx *c, pm_node_t *n, Mv *out);

static int mx_exec_stmts(MxCtx *c, pm_statements_node_t *s);

static int mx_residual(MxCtx *c, pm_node_t *n, MxBuf *b);

static int mx_call_macro(MxCtx *c, MxMacro *m, pm_arguments_node_t *args, Mv *ret);

static int mx_eval_list(MxCtx *c, pm_node_list_t *l, Mv *out) {
  Mv v; memset(&v, 0, sizeof v); v.k = MV_ARR;
  v.a = calloc(l->size + 1, sizeof(Mv)); v.n = (int)l->size;
  for (size_t i = 0; i < l->size; i++) {
    if (PM_NODE_TYPE(l->nodes[i]) == PM_SPLAT_NODE) return 0;
    if (!mx_eval(c, l->nodes[i], &v.a[i])) return 0;
  }
  *out = v;
  return 1;
}

/* the value of a string-ish node's parts */
static int mx_eval_parts(MxCtx *c, pm_node_list_t *parts, MxBuf *b) {
  for (size_t i = 0; i < parts->size; i++) {
    pm_node_t *p = parts->nodes[i];
    if (PM_NODE_TYPE(p) == PM_STRING_NODE) {
      pm_string_node_t *s = (pm_string_node_t *)p;
      mxb_putn(b, (const char *)pm_string_source(&s->unescaped), pm_string_length(&s->unescaped));
    }
    else if (PM_NODE_TYPE(p) == PM_EMBEDDED_STATEMENTS_NODE) {
      pm_embedded_statements_node_t *e = (pm_embedded_statements_node_t *)p;
      if (!e->statements || e->statements->body.size != 1) return 0;
      Mv v;
      if (!mx_eval(c, e->statements->body.nodes[0], &v)) return 0;
      if (v.k == MV_ARR) { if (!mv_inspect_exact(v)) return 0; mv_inspect(v, b); }
      else mv_to_s(v, b);
    }
    else if (PM_NODE_TYPE(p) == PM_INTERPOLATED_STRING_NODE) {
      if (!mx_eval_parts(c, &((pm_interpolated_string_node_t *)p)->parts, b)) return 0;
    }
    else return 0;
  }
  return 1;
}

static int mx_ascii(const char *s) {
  for (; *s; s++) if ((unsigned char)*s >= 0x80) return 0;
  return 1;
}

static int mx_eval_call(MxCtx *c, pm_call_node_t *n, Mv *out) {
  char *name = mx_name(n->name);
  int ok = 0;
  pm_node_list_t *args = n->arguments ? &n->arguments->arguments : NULL;
  size_t argc = args ? args->size : 0;
  if (n->block) goto done;
  if (!n->receiver || PM_NODE_TYPE(n->receiver) == PM_SELF_NODE) {
    MxMacro *m = mx_nested_macro(c->modname, name);
    if (m && c->depth < 16) {
      /* a macro whose value is used: one that leaves residual code, or no
         value the evaluator made, has none here -- the call stays in the text */
      MxBuf scratch = {0};
      MxBuf *sv_out = c->out;
      c->out = &scratch;
      ok = mx_call_macro(c, m, n->arguments, out) && out->k != MV_UNDEF && scratch.len == 0;
      c->out = sv_out;
      free(scratch.p);
    }
    goto done;
  }
  Mv r;
  if (!mx_eval(c, n->receiver, &r)) goto done;
  Mv a0; memset(&a0, 0, sizeof a0);
  if (argc == 1 && !mx_eval(c, args->nodes[0], &a0)) goto done;
  if (argc > 1) goto done;
  if (argc == 0) {
    if (strcmp(name, "nil?") == 0) { *out = mv_nil(); out->k = r.k == MV_NIL ? MV_TRUE : MV_FALSE; ok = 1; }
    else if (strcmp(name, "!") == 0) { *out = mv_nil(); out->k = mv_truthy(r) ? MV_FALSE : MV_TRUE; ok = 1; }
    else if (strcmp(name, "to_s") == 0 && r.k != MV_ARR) {
      MxBuf b = {0}; mv_to_s(r, &b); *out = mv_str(b.p ? b.p : "", b.len, MV_STR); free(b.p); ok = 1;
    }
    else if (strcmp(name, "to_sym") == 0 && (r.k == MV_STR || r.k == MV_SYM)) { *out = r; out->k = MV_SYM; ok = 1; }
    else if (strcmp(name, "inspect") == 0 && mv_inspect_exact(r)) {
      MxBuf b = {0}; mv_inspect(r, &b); *out = mv_str(b.p ? b.p : "", b.len, MV_STR); free(b.p); ok = 1;
    }
    /* case mapping and length only over ASCII: CRuby's are by character,
       with Unicode case rules */
    else if ((strcmp(name, "downcase") == 0 || strcmp(name, "upcase") == 0 ||
              strcmp(name, "capitalize") == 0) && (r.k == MV_STR || r.k == MV_SYM) && mx_ascii(r.s)) {
      *out = mv_str(r.s, strlen(r.s), r.k);
      for (char *p = out->s; *p; p++) {
        if (name[0] == 'd') *p = (char)tolower((unsigned char)*p);
        else if (name[0] == 'u') *p = (char)toupper((unsigned char)*p);
        else *p = (char)(p == out->s ? toupper((unsigned char)*p) : tolower((unsigned char)*p));
      }
      ok = 1;
    }
    else if (strcmp(name, "compact") == 0 && r.k == MV_ARR) {
      Mv v = r; v.a = calloc(r.n + 1, sizeof(Mv)); v.n = 0;
      for (int i = 0; i < r.n; i++) if (r.a[i].k != MV_NIL) v.a[v.n++] = r.a[i];
      *out = v; ok = 1;
    }
    else if ((strcmp(name, "size") == 0 || strcmp(name, "length") == 0) && r.k != MV_NIL) {
      *out = mv_nil(); out->k = MV_INT;
      out->i = r.k == MV_ARR ? r.n : (r.k == MV_STR || r.k == MV_SYM) ? (long long)strlen(r.s) : 0;
      ok = r.k == MV_ARR || ((r.k == MV_STR || r.k == MV_SYM) && mx_ascii(r.s));
    }
    else if ((strcmp(name, "first") == 0 || strcmp(name, "last") == 0) && r.k == MV_ARR) {
      *out = r.n == 0 ? mv_nil() : r.a[name[0] == 'f' ? 0 : r.n - 1]; ok = 1;
    }
    else if (strcmp(name, "join") == 0 && r.k == MV_ARR) {
      /* a nested array is flattened by CRuby: not followed here */
      int flat = 1;
      for (int i = 0; i < r.n; i++) if (r.a[i].k == MV_ARR) flat = 0;
      if (flat) {
        MxBuf b = {0};
        for (int i = 0; i < r.n; i++) mv_to_s(r.a[i], &b);
        *out = mv_str(b.p ? b.p : "", b.len, MV_STR); free(b.p); ok = 1;
      }
    }
    goto done;
  }
  /* one argument */
  if (strcmp(name, "join") == 0 && r.k == MV_ARR && (a0.k == MV_STR || a0.k == MV_NIL)) {
    int flat = 1;
    for (int i = 0; i < r.n; i++) if (r.a[i].k == MV_ARR) flat = 0;
    if (!flat) goto done;
    MxBuf b = {0};
    for (int i = 0; i < r.n; i++) {
      if (i && a0.k == MV_STR) mxb_puts(&b, a0.s);
      mv_to_s(r.a[i], &b);
    }
    *out = mv_str(b.p ? b.p : "", b.len, MV_STR); free(b.p); ok = 1;
  }
  else if (strcmp(name, "==") == 0 || strcmp(name, "!=") == 0) {
    int eq = mv_eq(r, a0);
    *out = mv_nil(); out->k = (eq == (name[0] == '=')) ? MV_TRUE : MV_FALSE; ok = 1;
  }
  /* an Integer result past 64 bits is a Bignum in CRuby: not followed */
  else if (strcmp(name, "+") == 0 && r.k == MV_INT && a0.k == MV_INT) {
    *out = r; ok = !__builtin_add_overflow(r.i, a0.i, &out->i);
  }
  else if (strcmp(name, "*") == 0 && r.k == MV_INT && a0.k == MV_INT) {
    *out = r; ok = !__builtin_mul_overflow(r.i, a0.i, &out->i);
  }
  else if (strcmp(name, "**") == 0 && r.k == MV_INT && a0.k == MV_INT && a0.i >= 0 && a0.i < 64) {
    long long v = 1; int of = 0;
    for (long long q = 0; q < a0.i && !of; q++) of = __builtin_mul_overflow(v, r.i, &v);
    *out = r; out->i = v; ok = !of;
  }
  else if (strcmp(name, "-") == 0 && r.k == MV_INT && a0.k == MV_INT) {
    *out = r; ok = !__builtin_sub_overflow(r.i, a0.i, &out->i);
  }
  else if (strcmp(name, "+") == 0 && r.k == MV_STR && a0.k == MV_STR) {
    MxBuf b = {0}; mxb_puts(&b, r.s); mxb_puts(&b, a0.s);
    *out = mv_str(b.p, b.len, MV_STR); free(b.p); ok = 1;
  }
  else if (strcmp(name, "+") == 0 && r.k == MV_ARR && a0.k == MV_ARR) {
    Mv v = r; v.a = calloc(r.n + a0.n + 1, sizeof(Mv)); v.n = 0;
    for (int i = 0; i < r.n; i++) v.a[v.n++] = r.a[i];
    for (int i = 0; i < a0.n; i++) v.a[v.n++] = a0.a[i];
    *out = v; ok = 1;
  }
  else if (strcmp(name, "[]") == 0 && r.k == MV_ARR && a0.k == MV_INT) {
    long long ix = a0.i < 0 ? r.n + a0.i : a0.i;
    *out = (ix >= 0 && ix < r.n) ? r.a[ix] : mv_nil(); ok = 1;
  }
done:
  free(name);
  return ok;
}

static int mx_eval(MxCtx *c, pm_node_t *n, Mv *out) {
  if (!n) { *out = mv_nil(); return 1; }
  switch (PM_NODE_TYPE(n)) {
  case PM_NIL_NODE: *out = mv_nil(); return 1;
  case PM_TRUE_NODE: *out = mv_nil(); out->k = MV_TRUE; return 1;
  case PM_FALSE_NODE: *out = mv_nil(); out->k = MV_FALSE; return 1;
  case PM_INTEGER_NODE: {
    pm_integer_node_t *in = (pm_integer_node_t *)n;
    unsigned long long uv;
    if (in->value.values) {
      if (in->value.length > 2) return 0;
      uv = (unsigned long long)in->value.values[0] |
           (in->value.length > 1 ? (unsigned long long)in->value.values[1] << 32 : 0);
      if (uv > 0x7fffffffffffffffULL) return 0;
    }
    else uv = in->value.value;
    *out = mv_nil(); out->k = MV_INT;
    out->i = in->value.negative ? -(long long)uv : (long long)uv;
    return 1;
  }
  case PM_STRING_NODE: {
    pm_string_node_t *s = (pm_string_node_t *)n;
    *out = mv_str((const char *)pm_string_source(&s->unescaped), pm_string_length(&s->unescaped), MV_STR);
    return 1;
  }
  case PM_SYMBOL_NODE: {
    pm_symbol_node_t *s = (pm_symbol_node_t *)n;
    *out = mv_str((const char *)pm_string_source(&s->unescaped), pm_string_length(&s->unescaped), MV_SYM);
    return 1;
  }
  case PM_INTERPOLATED_STRING_NODE: case PM_INTERPOLATED_SYMBOL_NODE: {
    pm_node_list_t *parts = PM_NODE_TYPE(n) == PM_INTERPOLATED_STRING_NODE
      ? &((pm_interpolated_string_node_t *)n)->parts : &((pm_interpolated_symbol_node_t *)n)->parts;
    MxBuf b = {0};
    if (!mx_eval_parts(c, parts, &b)) { free(b.p); return 0; }
    *out = mv_str(b.p ? b.p : "", b.len, PM_NODE_TYPE(n) == PM_INTERPOLATED_STRING_NODE ? MV_STR : MV_SYM);
    free(b.p);
    return 1;
  }
  case PM_ARRAY_NODE: return mx_eval_list(c, &((pm_array_node_t *)n)->elements, out);
  case PM_LOCAL_VARIABLE_READ_NODE: {
    char *nm = mx_name(((pm_local_variable_read_node_t *)n)->name);
    Mv *v = mx_lookup(c->loc, c->nloc, nm);
    free(nm);
    if (!v) return 0;
    *out = *v; return 1;
  }
  case PM_PARENTHESES_NODE: {
    pm_node_t *b = ((pm_parentheses_node_t *)n)->body;
    if (b && PM_NODE_TYPE(b) == PM_STATEMENTS_NODE) {
      pm_statements_node_t *s = (pm_statements_node_t *)b;
      if (s->body.size != 1) return 0;
      b = s->body.nodes[0];
    }
    return mx_eval(c, b, out);
  }
  case PM_AND_NODE: case PM_OR_NODE: {
    pm_node_t *l = PM_NODE_TYPE(n) == PM_AND_NODE ? ((pm_and_node_t *)n)->left : ((pm_or_node_t *)n)->left;
    pm_node_t *r = PM_NODE_TYPE(n) == PM_AND_NODE ? ((pm_and_node_t *)n)->right : ((pm_or_node_t *)n)->right;
    Mv lv;
    if (!mx_eval(c, l, &lv)) return 0;
    if ((PM_NODE_TYPE(n) == PM_AND_NODE) != mv_truthy(lv)) { *out = lv; return 1; }
    return mx_eval(c, r, out);
  }
  /* __LINE__ / __FILE__ are the macro source's: kept as written */
  case PM_SOURCE_LINE_NODE: case PM_SOURCE_FILE_NODE: return 0;
  case PM_CALL_NODE: return mx_eval_call(c, (pm_call_node_t *)n, out);
  default: return 0;
  }
}

/* the node's source text with every macro local it reads replaced by its value */
/* `scope`: the blocks and lambdas entered since the macro body -- a read is
   the macro's local only at that depth (a block parameter of the same name
   is not). */

typedef struct { MxCtx *c; const uint8_t *from; MxBuf *b; int bad; uint32_t scope; } MxSubst;

static bool mx_subst_visit(const pm_node_t *n, void *data) {
  MxSubst *s = (MxSubst *)data;
  if (s->bad) return false;
  /* children visited out of source order (`x if c`) cannot be spliced */
  if (n->location.start < s->from) { s->bad = 1; return false; }
  if (PM_NODE_TYPE(n) == PM_BLOCK_NODE || PM_NODE_TYPE(n) == PM_LAMBDA_NODE) {
    s->scope++;
    pm_visit_child_nodes(n, mx_subst_visit, s);
    s->scope--;
    return false;
  }
  if (PM_NODE_TYPE(n) == PM_DEF_NODE) { s->bad = 1; return false; }   /* a scope of its own */
  Mv v; int is_var = 0; char *nm = NULL;
  pm_constant_id_t wn = 0; uint32_t wd = 0;
  switch (PM_NODE_TYPE(n)) {
  case PM_LOCAL_VARIABLE_WRITE_NODE: wn = ((pm_local_variable_write_node_t *)n)->name; wd = ((pm_local_variable_write_node_t *)n)->depth; break;
  case PM_LOCAL_VARIABLE_OPERATOR_WRITE_NODE: wn = ((pm_local_variable_operator_write_node_t *)n)->name; wd = ((pm_local_variable_operator_write_node_t *)n)->depth; break;
  case PM_LOCAL_VARIABLE_OR_WRITE_NODE: wn = ((pm_local_variable_or_write_node_t *)n)->name; wd = ((pm_local_variable_or_write_node_t *)n)->depth; break;
  case PM_LOCAL_VARIABLE_AND_WRITE_NODE: wn = ((pm_local_variable_and_write_node_t *)n)->name; wd = ((pm_local_variable_and_write_node_t *)n)->depth; break;
  case PM_LOCAL_VARIABLE_TARGET_NODE: wn = ((pm_local_variable_target_node_t *)n)->name; wd = ((pm_local_variable_target_node_t *)n)->depth; break;
  default: break;
  }
  if (wn && wd == s->scope) {
    /* the text assigning a macro local: its later reads are not the value
       substituted here */
    char *w = mx_name(wn);
    if (mx_lookup(s->c->loc, s->c->nloc, w)) s->bad = 1;
    free(w);
    if (s->bad) return false;
  }
  if (PM_NODE_TYPE(n) == PM_LOCAL_VARIABLE_READ_NODE &&
      ((pm_local_variable_read_node_t *)n)->depth == s->scope) {
    nm = mx_name(((pm_local_variable_read_node_t *)n)->name);
    Mv *p = mx_lookup(s->c->loc, s->c->nloc, nm);
    if (p) { v = *p; is_var = 1; }
  }
  if (nm) free(nm);
  if (!is_var) return true;
  mxb_putn(s->b, (const char *)s->from, (size_t)(n->location.start - s->from));
  mxb_puts(s->b, "(");
  mv_inspect(v, s->b);
  mxb_puts(s->b, ")");
  s->from = n->location.end;
  return false;
}

/* `scope`: the depth of the macro's own locals as seen from `n` (1 in a
   lambda body the macro passes on). */

static int mx_subst_text_at(MxCtx *c, pm_node_t *n, MxBuf *b, uint32_t scope) {
  MxSubst s = { c, n->location.start, b, 0, scope };
  /* `n` itself too: a read, a write of a macro local, or a block or lambda
     handed over whole (whose body is one scope further in) */
  if (mx_subst_visit(n, &s)) pm_visit_child_nodes(n, mx_subst_visit, &s);
  if (s.bad || s.from > n->location.end) return 0;
  mxb_putn(b, (const char *)s.from, (size_t)(n->location.end - s.from));
  return 1;
}

static int mx_subst_text(MxCtx *c, pm_node_t *n, MxBuf *b) { return mx_subst_text_at(c, n, b, 0); }

/* a residual expression: its value when computable, else its text with the
   macro values substituted; `public_send(name, ...)` becomes a plain call */

static int mx_residual(MxCtx *c, pm_node_t *n, MxBuf *b) {
  Mv v;
  if (mx_eval(c, n, &v)) { mv_inspect(v, b); return 1; }
  if (PM_NODE_TYPE(n) == PM_CALL_NODE) {
    pm_call_node_t *cn = (pm_call_node_t *)n;
    char *name = mx_name(cn->name);
    int snd = (strcmp(name, "public_send") == 0 || strcmp(name, "send") == 0 || strcmp(name, "__send__") == 0) &&
              mx_prim_builtin(name);
    free(name);
    if (snd && (!cn->receiver || PM_NODE_TYPE(cn->receiver) == PM_SELF_NODE) && cn->arguments &&
        cn->arguments->arguments.size >= 1 && !cn->block) {
      Mv mn;
      if (!mx_eval(c, cn->arguments->arguments.nodes[0], &mn) || (mn.k != MV_STR && mn.k != MV_SYM) ||
          !mx_sym_plain(mn.s)) return 0;
      /* `attr=(v)` would read as a local assignment, not a call */
      if (mn.s[0] && mn.s[strlen(mn.s) - 1] == '=') return 0;
      mxb_puts(b, mn.s);
      mxb_puts(b, "(");
      for (size_t i = 1; i < cn->arguments->arguments.size; i++) {
        if (i > 1) mxb_puts(b, ", ");
        if (!mx_residual(c, cn->arguments->arguments.nodes[i], b)) return 0;
      }
      mxb_puts(b, ")");
      return 1;
    }
  }
  return mx_subst_text(c, n, b);
}

static int mx_is_raise(pm_node_t *n) {
  if (PM_NODE_TYPE(n) != PM_CALL_NODE) return 0;
  pm_call_node_t *cn = (pm_call_node_t *)n;
  if (cn->receiver) return 0;
  char *nm = mx_name(cn->name);
  int r = strcmp(nm, "raise") == 0 || strcmp(nm, "fail") == 0;
  free(nm);
  return r;
}

/* A write the evaluator cannot follow may have changed any ivar: every known
   one is unknown now, and so is every one not seen yet. */

static int mx_exec(MxCtx *c, pm_node_t *n) {
  if (c->returned || c->stopped) return 1;
  MxBuf *o = c->out;
  switch (PM_NODE_TYPE(n)) {
  case PM_RETURN_NODE: {
    pm_return_node_t *r = (pm_return_node_t *)n;
    if (r->arguments && r->arguments->arguments.size > 1) return 0;
    if (!mx_eval(c, r->arguments ? r->arguments->arguments.nodes[0] : NULL, &c->ret)) return 0;
    c->returned = 1;
    return 1;
  }
  case PM_LOCAL_VARIABLE_WRITE_NODE: {
    pm_local_variable_write_node_t *w = (pm_local_variable_write_node_t *)n;
    Mv v;
    if (!mx_eval(c, w->value, &v)) return 0;
    char *nm = mx_name(w->name);
    mx_set(c->loc, &c->nloc, 64, nm, v);
    free(nm);
    c->ret = v;
    return 1;
  }
  case PM_IF_NODE: case PM_UNLESS_NODE: {
    int is_if = PM_NODE_TYPE(n) == PM_IF_NODE;
    pm_node_t *pred = is_if ? ((pm_if_node_t *)n)->predicate : ((pm_unless_node_t *)n)->predicate;
    Mv pv;
    if (!mx_eval(c, pred, &pv)) return 0;
    int take = mv_truthy(pv) == is_if;
    pm_statements_node_t *then = is_if ? ((pm_if_node_t *)n)->statements : ((pm_unless_node_t *)n)->statements;
    pm_node_t *els = is_if ? ((pm_if_node_t *)n)->subsequent : (pm_node_t *)((pm_unless_node_t *)n)->else_clause;
    if (take) return then ? mx_exec_stmts(c, then) : (c->ret = mv_nil(), 1);
    if (!els) { c->ret = mv_nil(); return 1; }
    if (PM_NODE_TYPE(els) == PM_ELSE_NODE) {
      pm_statements_node_t *es = ((pm_else_node_t *)els)->statements;
      return es ? mx_exec_stmts(c, es) : (c->ret = mv_nil(), 1);
    }
    return mx_exec(c, els);   /* elsif */
  }
  case PM_BEGIN_NODE: {
    pm_begin_node_t *bn = (pm_begin_node_t *)n;
    if (bn->else_clause || bn->ensure_clause) return 0;
    if (!bn->rescue_clause) return bn->statements ? mx_exec_stmts(c, bn->statements) : 1;
    if (!o) return 0;   /* whether a rescue body runs is decided at run time */
    mxb_puts(o, "begin\n");
    size_t body_at = o->len;
    if (bn->statements && !mx_exec_stmts(c, bn->statements)) return 0;
    c->stopped = 0;
    for (pm_rescue_node_t *r = bn->rescue_clause; r; r = r->subsequent) {
      mxb_puts(o, "rescue");
      for (size_t i = 0; i < r->exceptions.size; i++) {
        mxb_puts(o, i ? ", " : " ");
        pm_node_t *e = r->exceptions.nodes[i];
        mxb_putn(o, (const char *)e->location.start, (size_t)(e->location.end - e->location.start));
      }
      if (r->reference) {
        mxb_puts(o, " => ");
        mxb_putn(o, (const char *)r->reference->location.start,
                 (size_t)(r->reference->location.end - r->reference->location.start));
      }
      mxb_puts(o, "\n");
      int sv_fr = c->in_ffi_rescue;
      c->in_ffi_rescue = strstr(o->p + body_at, "attach_function") != NULL;
      if (r->statements && !mx_exec_stmts(c, r->statements)) return 0;
      c->in_ffi_rescue = sv_fr;
      c->stopped = 0;
    }
    mxb_puts(o, "end\n");
    return 1;
  }
  case PM_CALL_NODE: {
    pm_call_node_t *cn = (pm_call_node_t *)n;
    char *name = mx_name(cn->name);
    int self_recv = !cn->receiver || PM_NODE_TYPE(cn->receiver) == PM_SELF_NODE;
    pm_node_list_t *args = cn->arguments ? &cn->arguments->arguments : NULL;
    size_t argc = args ? args->size : 0;
    int ok = 0;
    MxMacro *m = self_recv ? mx_nested_macro(c->modname, name) : NULL;
    if (m) {
      Mv r;
      ok = c->depth < 16 && mx_call_macro(c, m, cn->arguments, &r);
      if (ok) c->ret = r;
    }
    else if (self_recv && argc >= 1 && !cn->block &&
             /* only these evaluate a string as the class body: instance_eval
                defines on the singleton class, and the _exec forms take a
                block, not code */
             (strcmp(name, "module_eval") == 0 || strcmp(name, "class_eval") == 0) &&
             mx_prim_builtin(name)) {
      Mv code;
      if (mx_eval(c, args->nodes[0], &code) && code.k == MV_STR && sp_snippet_graftable(code.s)) {
        if (o) { mxb_puts(o, code.s); mxb_puts(o, "\n"); }
        c->ret = mv_nil();
        ok = 1;
      }
    }
    else if (self_recv && argc == 2 && strcmp(name, "const_set") == 0 && !cn->block &&
             mx_prim_builtin(name)) {
      Mv cnm;
      if (mx_eval(c, args->nodes[0], &cnm) && (cnm.k == MV_STR || cnm.k == MV_SYM) &&
          isupper((unsigned char)cnm.s[0]) && mx_sym_plain(cnm.s)) {
        ok = 1;
        if (o) {
          mxb_puts(o, cnm.s); mxb_puts(o, " = ");
          ok = mx_residual(c, args->nodes[1], o);
          mxb_puts(o, "\n");
        }
      }
    }
    else if (self_recv && argc == 2 && !cn->block &&
             (strcmp(name, "define_singleton_method") == 0 || strcmp(name, "define_method") == 0) &&
             mx_prim_builtin(name) &&
             PM_NODE_TYPE(args->nodes[1]) == PM_LAMBDA_NODE &&
             !((pm_lambda_node_t *)args->nodes[1])->parameters) {
      Mv mn;
      if (mx_eval(c, args->nodes[0], &mn) && (mn.k == MV_STR || mn.k == MV_SYM) && mx_sym_plain(mn.s)) {
        ok = 1;
        if (o && c->in_ffi_rescue && name[7] == 's') {
          /* standing in for the function attach_function could not find:
             a static def would replace the attached one */
          mxb_puts(o, "__ffi_define_proc(:");
          mxb_puts(o, mn.s);
          mxb_puts(o, ", ");
          ok = mx_residual(c, args->nodes[1], o);
          mxb_puts(o, ")\n");
        }
        else if (o) {
          pm_lambda_node_t *lam = (pm_lambda_node_t *)args->nodes[1];
          /* the body runs when the method is called, on that method's self:
             its text, with only the macro's locals (captured now)
             substituted -- an ivar read or a macro call in it is not
             evaluated now */
          mxb_puts(o, name[7] == 's' ? "def self." : "def ");
          mxb_puts(o, mn.s);
          mxb_puts(o, "\n");
          if (lam->body) {
            if (PM_NODE_TYPE(lam->body) == PM_STATEMENTS_NODE) {
              pm_statements_node_t *st = (pm_statements_node_t *)lam->body;
              for (size_t i = 0; i < st->body.size && ok; i++) {
                ok = mx_subst_text_at(c, st->body.nodes[i], o, 1);
                mxb_puts(o, "\n");
              }
            }
            else { ok = mx_subst_text_at(c, lam->body, o, 1); mxb_puts(o, "\n"); }
          }
          mxb_puts(o, "end\n");
        }
      }
    }
    else {
      /* any other call is residual code -- unless it is made on a value the
         evaluator holds (`l.push(n)` with a local l = []): what it changes
         there is not followed, so the macro is not expanded */
      /* a call the evaluator can make (a macro's last expression, `a.join`)
         is its value: nothing to keep */
      Mv ev;
      if (mx_eval(c, n, &ev)) { c->ret = ev; free(name); return 1; }
      Mv rv;
      if (cn->receiver && PM_NODE_TYPE(cn->receiver) != PM_SELF_NODE &&
          mx_eval(c, cn->receiver, &rv) && (rv.k == MV_ARR || rv.k == MV_STR)) {
        free(name);
        return 0;
      }
      ok = 1;
      c->ret = mv_undef();   /* its value is the run time's */
      if (o) {
        if (self_recv && !cn->receiver && !cn->block && argc > 0 && strcmp(name, "public_send") != 0 &&
            strcmp(name, "send") != 0) {
          /* keep the call's shape, arguments substituted one by one */
          mxb_puts(o, name);
          mxb_puts(o, " ");
          for (size_t i = 0; i < argc && ok; i++) {
            if (i) mxb_puts(o, ", ");
            pm_node_t *a = args->nodes[i];
            if (PM_NODE_TYPE(a) == PM_KEYWORD_HASH_NODE) {
              pm_keyword_hash_node_t *kh = (pm_keyword_hash_node_t *)a;
              for (size_t j = 0; j < kh->elements.size && ok; j++) {
                if (j) mxb_puts(o, ", ");
                pm_node_t *el = kh->elements.nodes[j];
                if (PM_NODE_TYPE(el) != PM_ASSOC_NODE) { ok = 0; break; }
                pm_assoc_node_t *as = (pm_assoc_node_t *)el;
                ok = mx_residual(c, as->key, o);
                mxb_puts(o, " => ");
                if (ok) ok = mx_residual(c, as->value, o);
              }
            }
            else ok = mx_residual(c, a, o);
          }
        }
        else ok = mx_residual(c, n, o);
        mxb_puts(o, "\n");
      }
      if (ok && mx_is_raise(n)) c->stopped = 1;
    }
    free(name);
    return ok;
  }
  default: {
    Mv v;
    if (mx_eval(c, n, &v)) { c->ret = v; return 1; }
    return 0;
  }
  }
}

static int mx_exec_stmts(MxCtx *c, pm_statements_node_t *s) {
  if (!s) return 1;
  for (size_t i = 0; i < s->body.size; i++) {
    if (c->returned || c->stopped) break;
    if (!mx_exec(c, s->body.nodes[i])) return 0;
  }
  return 1;
}

/* bind the macro's parameters to the call's (literal) arguments and run it */
static int mx_call_macro(MxCtx *c, MxMacro *m, pm_arguments_node_t *argn, Mv *ret) {
  MxCtx sub; memset(&sub, 0, sizeof sub);
  sub.out = c->out; sub.depth = c->depth + 1;
  sub.modname = m->module;
  pm_node_list_t *args = argn ? &argn->arguments : NULL;
  size_t argc = args ? args->size : 0;
  pm_keyword_hash_node_t *kw = NULL;
  if (argc > 0 && PM_NODE_TYPE(args->nodes[argc - 1]) == PM_KEYWORD_HASH_NODE) {
    kw = (pm_keyword_hash_node_t *)args->nodes[argc - 1];
    argc--;
  }
  for (size_t i = 0; i < argc; i++)
    if (PM_NODE_TYPE(args->nodes[i]) == PM_SPLAT_NODE || PM_NODE_TYPE(args->nodes[i]) == PM_BLOCK_ARGUMENT_NODE)
      return 0;
  pm_parameters_node_t *ps = m->def->parameters;
  size_t nreq = ps ? ps->requireds.size : 0, nopt = ps ? ps->optionals.size : 0;
  if (ps && (ps->rest || ps->posts.size || ps->keyword_rest || ps->block)) return 0;
  if (argc < nreq || argc > nreq + nopt) return 0;
  size_t ai = 0;
  for (size_t i = 0; i < nreq; i++, ai++) {
    Mv v;
    if (PM_NODE_TYPE(ps->requireds.nodes[i]) != PM_REQUIRED_PARAMETER_NODE) return 0;
    if (!mx_eval(c, args->nodes[ai], &v)) return 0;
    char *nm = mx_name(((pm_required_parameter_node_t *)ps->requireds.nodes[i])->name);
    mx_set(sub.loc, &sub.nloc, 64, nm, v); free(nm);
  }
  for (size_t i = 0; i < nopt; i++) {
    pm_optional_parameter_node_t *op = (pm_optional_parameter_node_t *)ps->optionals.nodes[i];
    Mv v;
    if (ai < argc) { if (!mx_eval(c, args->nodes[ai++], &v)) return 0; }
    else if (!mx_eval(&sub, op->value, &v)) return 0;
    char *nm = mx_name(op->name);
    mx_set(sub.loc, &sub.nloc, 64, nm, v); free(nm);
  }
  size_t nkw = ps ? ps->keywords.size : 0;
  if (kw && nkw == 0) return 0;
  if (kw) {
    /* every given keyword must name a parameter */
    for (size_t j = 0; j < kw->elements.size; j++) {
      pm_node_t *el = kw->elements.nodes[j];
      if (PM_NODE_TYPE(el) != PM_ASSOC_NODE) return 0;
      Mv k;
      if (!mx_eval(c, ((pm_assoc_node_t *)el)->key, &k) || k.k != MV_SYM) return 0;
      int found = 0;
      for (size_t i = 0; i < nkw && !found; i++) {
        pm_node_t *kp = ps->keywords.nodes[i];
        pm_constant_id_t kid = PM_NODE_TYPE(kp) == PM_OPTIONAL_KEYWORD_PARAMETER_NODE
          ? ((pm_optional_keyword_parameter_node_t *)kp)->name
          : ((pm_required_keyword_parameter_node_t *)kp)->name;
        char *kn = mx_name(kid);
        size_t kl = strlen(kn);
        if (kl && kn[kl - 1] == ':') kn[kl - 1] = 0;
        found = strcmp(kn, k.s) == 0;
        free(kn);
      }
      if (!found) return 0;
    }
  }
  for (size_t i = 0; i < nkw; i++) {
    pm_node_t *kp = ps->keywords.nodes[i];
    int req = PM_NODE_TYPE(kp) == PM_REQUIRED_KEYWORD_PARAMETER_NODE;
    pm_constant_id_t kid = req ? ((pm_required_keyword_parameter_node_t *)kp)->name
                               : ((pm_optional_keyword_parameter_node_t *)kp)->name;
    char *kn = mx_name(kid);
    size_t kl = strlen(kn);
    if (kl && kn[kl - 1] == ':') kn[kl - 1] = 0;
    Mv v; int have = 0;
    for (size_t j = 0; kw && j < kw->elements.size && !have; j++) {
      pm_assoc_node_t *as = (pm_assoc_node_t *)kw->elements.nodes[j];
      Mv k;
      if (mx_eval(c, as->key, &k) && k.k == MV_SYM && strcmp(k.s, kn) == 0) {
        if (!mx_eval(c, as->value, &v)) { free(kn); return 0; }
        have = 1;
      }
    }
    if (!have) {
      if (req) { free(kn); return 0; }
      if (!mx_eval(&sub, ((pm_optional_keyword_parameter_node_t *)kp)->value, &v)) { free(kn); return 0; }
    }
    mx_set(sub.loc, &sub.nloc, 64, kn, v);
    free(kn);
  }
  sub.ret = mv_nil();
  pm_node_t *body = m->def->body;
  int ok = 1;
  if (body) {
    if (PM_NODE_TYPE(body) == PM_STATEMENTS_NODE) ok = mx_exec_stmts(&sub, (pm_statements_node_t *)body);
    else if (PM_NODE_TYPE(body) == PM_BEGIN_NODE) ok = mx_exec(&sub, body);
    else ok = mx_exec(&sub, body);
  }
  if (!ok) return 0;
  *ret = sub.ret;
  return 1;
}

/* does the macro (or a macro it calls) do something that only its expansion
   can give the compiler? */

typedef struct { const char *mod; int found; int depth; } MxDyn;

static int mx_macro_dynamic(MxMacro *m, int depth);

static bool mx_dyn_visit(const pm_node_t *n, void *data) {
  MxDyn *d = (MxDyn *)data;
  if (d->found) return false;
  if (PM_NODE_TYPE(n) == PM_CALL_NODE) {
    pm_call_node_t *cn = (pm_call_node_t *)n;
    char *nm = mx_name(cn->name);
    int self_recv = !cn->receiver || PM_NODE_TYPE(cn->receiver) == PM_SELF_NODE;
    if (self_recv) {
      static const char *const DYN[] = { "module_eval", "class_eval", "instance_eval",
        "const_set", "define_method", "define_singleton_method", "public_send", "send",
        "__send__", NULL };
      for (int i = 0; DYN[i]; i++) if (strcmp(nm, DYN[i]) == 0) d->found = 1;
      if (strcmp(nm, "attach_function") == 0 && cn->arguments && cn->arguments->arguments.size >= 1) {
        pm_node_t *a0 = cn->arguments->arguments.nodes[0];
        if (PM_NODE_TYPE(a0) != PM_SYMBOL_NODE && PM_NODE_TYPE(a0) != PM_STRING_NODE) d->found = 1;
      }
      MxMacro *sub = mx_nested_macro(d->mod, nm);
      if (sub && d->depth < 8 && mx_macro_dynamic(sub, d->depth + 1)) d->found = 1;
    }
    free(nm);
  }
  return !d->found;
}

static int mx_macro_dynamic(MxMacro *m, int depth) {
  if (m->dynamic >= 0) return m->dynamic;
  if (depth > 8) return 0;
  MxDyn d = { m->module, 0, depth };
  if (m->def->body) pm_visit_node(m->def->body, mx_dyn_visit, &d);
  if (depth == 0) m->dynamic = d.found;
  return d.found;
}

static char *mx_last_name(pm_node_t *cp) {
  if (!cp) return NULL;
  if (PM_NODE_TYPE(cp) == PM_CONSTANT_READ_NODE) return mx_name(((pm_constant_read_node_t *)cp)->name);
  if (PM_NODE_TYPE(cp) == PM_CONSTANT_PATH_NODE) return mx_name(((pm_constant_path_node_t *)cp)->name);
  return NULL;
}

/* collect module instance-method defs */

/* ---- collecting the macros, and what could answer a call in their place ---- */

static void mx_note_def(const char *name) {
  if (mx_names_has(&g_mx_defs, name)) mx_names_add(&g_mx_dup, name);
  else mx_names_add(&g_mx_defs, name);
}

static char *mx_sym_or_str(const pm_node_t *n) {
  const pm_string_t *u = PM_NODE_TYPE(n) == PM_SYMBOL_NODE ? &((const pm_symbol_node_t *)n)->unescaped
                       : PM_NODE_TYPE(n) == PM_STRING_NODE ? &((const pm_string_node_t *)n)->unescaped : NULL;
  if (!u) return NULL;
  return strndup((const char *)pm_string_source(u), pm_string_length(u));
}

/* a name a call of the `def`-like family gives: the literal arguments, or
   every name when one is computed. `setter`: attr_writer/accessor give name= too. */
static void mx_note_literals(const pm_call_node_t *cn, int setter, int hide, int *computed) {
  if (!cn->arguments) return;
  for (size_t i = 0; i < cn->arguments->arguments.size; i++) {
    char *s = mx_sym_or_str(cn->arguments->arguments.nodes[i]);
    if (!s) { *computed = 1; continue; }
    if (hide) mx_names_add(&g_mx_hidden, s); else mx_note_def(s);
    if (setter) {
      char *w = malloc(strlen(s) + 2); sprintf(w, "%s=", s);
      if (hide) mx_names_add(&g_mx_hidden, w); else mx_note_def(w);
      free(w);
    }
    free(s);
  }
}

static int mx_is_attr(const char *n) {
  return strcmp(n, "attr_reader") == 0 || strcmp(n, "attr_writer") == 0 ||
         strcmp(n, "attr_accessor") == 0 || strcmp(n, "attr") == 0;
}

/* The statements of a module body: every instance method it gives counts as
   a definition of that name, and the plain `def`s are the macros. */
static void mx_collect_module(pm_statements_node_t *st, const char *path, int ffi) {
  for (size_t i = 0; i < st->body.size; i++) {
    pm_node_t *s = st->body.nodes[i];
    if (PM_NODE_TYPE(s) == PM_DEF_NODE && !((pm_def_node_t *)s)->receiver) {
      pm_def_node_t *d = (pm_def_node_t *)s;
      char *dn = mx_name(d->name);
      mx_note_def(dn);
      if (ffi) { free(dn); continue; }
      if (g_mx_nmacros == g_mx_cmacros) {
        g_mx_cmacros = g_mx_cmacros ? g_mx_cmacros * 2 : 64;
        g_mx_macros = realloc(g_mx_macros, sizeof(MxMacro) * (size_t)g_mx_cmacros);
      }
      g_mx_macros[g_mx_nmacros].module = strdup(path);
      g_mx_macros[g_mx_nmacros].name = dn;
      g_mx_macros[g_mx_nmacros].next_same = -1;
      g_mx_macros[g_mx_nmacros].def = d;
      g_mx_macros[g_mx_nmacros].dynamic = -1;
      g_mx_macros[g_mx_nmacros].expanded = 0;
      g_mx_nmacros++;
    }
    else if (PM_NODE_TYPE(s) == PM_ALIAS_METHOD_NODE) {
      char *an = mx_sym_or_str(((pm_alias_method_node_t *)s)->new_name);
      if (an) { mx_note_def(an); free(an); } else g_mx_hide_all = 1;
    }
    else if (PM_NODE_TYPE(s) == PM_CALL_NODE && !((pm_call_node_t *)s)->receiver) {
      const pm_call_node_t *cn = (const pm_call_node_t *)s;
      char *nm = mx_name(cn->name);
      int computed = 0;
      if (mx_is_attr(nm)) mx_note_literals(cn, strcmp(nm, "attr_reader") != 0 && strcmp(nm, "attr") != 0, 0, &computed);
      else if (strcmp(nm, "define_method") == 0 || strcmp(nm, "alias_method") == 0) {
        /* only the first argument is the new name */
        if (cn->arguments && cn->arguments->arguments.size) {
          char *a0 = mx_sym_or_str(cn->arguments->arguments.nodes[0]);
          if (a0) { mx_note_def(a0); free(a0); } else computed = 1;
        }
      }
      else if (cn->arguments && cn->arguments->arguments.size == 1 &&
               PM_NODE_TYPE(cn->arguments->arguments.nodes[0]) == PM_DEF_NODE) {
        /* private def m ... */
        pm_def_node_t *d = (pm_def_node_t *)cn->arguments->arguments.nodes[0];
        if (!d->receiver) { char *dn = mx_name(d->name); mx_note_def(dn); free(dn); }
      }
      free(nm);
      if (computed) g_mx_hide_all = 1;
    }
  }
}

static int g_mx_in_ffi;   /* inside the ffi package's FFI module */

/* The class and module bodies, with their lexical path: `A::B` stays `A::B`,
   under the enclosing one. */
static bool mx_collect_visit(const pm_node_t *n, void *data) {
  const char *path = data ? (const char *)data : "";
  if (PM_NODE_TYPE(n) != PM_CLASS_NODE && PM_NODE_TYPE(n) != PM_MODULE_NODE) return true;
  int is_mod = PM_NODE_TYPE(n) == PM_MODULE_NODE;
  pm_node_t *cp = is_mod ? ((pm_module_node_t *)n)->constant_path : ((pm_class_node_t *)n)->constant_path;
  pm_node_t *body = is_mod ? ((pm_module_node_t *)n)->body : ((pm_class_node_t *)n)->body;
  size_t cl = (size_t)(cp->location.end - cp->location.start);
  char *full = malloc(strlen(path) + cl + 3);
  if (cl >= 2 && cp->location.start[0] == ':') sprintf(full, "%.*s", (int)cl, (const char *)cp->location.start);
  else sprintf(full, "%s::%.*s", path, (int)cl, (const char *)cp->location.start);
  mx_names_add(&g_mx_paths, full);
  /* the ffi package's own FFI, and what it holds: its methods are the
     runtime, not macros (but they count as definitions of their names) */
  char *ln = mx_last_name(cp);
  int ffi = is_mod && ln && strcmp(ln, "FFI") == 0;
  free(ln);
  if (ffi) g_mx_in_ffi++;
  if (is_mod && body && PM_NODE_TYPE(body) == PM_STATEMENTS_NODE)
    mx_collect_module((pm_statements_node_t *)body, full, g_mx_in_ffi > 0);
  if (body) pm_visit_node(body, mx_collect_visit, full);
  if (ffi) g_mx_in_ffi--;
  free(full);
  return false;
}

/* Names a class method, alias or removal gives anywhere in the program: a call
   of such a name may reach that instead of a macro. A method given a computed
   name hides them all -- except inside a module's own method, which is macro
   code, evaluated (or kept and run) as the macro is. */
typedef struct { int in_macro; } MxHideScan;

static void mx_hide_sclass_body(const pm_node_t *b) {
  if (!b || PM_NODE_TYPE(b) != PM_STATEMENTS_NODE) { if (b) g_mx_hide_all = 1; return; }
  const pm_statements_node_t *st = (const pm_statements_node_t *)b;
  for (size_t i = 0; i < st->body.size; i++) {
    pm_node_t *s = st->body.nodes[i];
    if (PM_NODE_TYPE(s) == PM_DEF_NODE) {
      char *dn = mx_name(((pm_def_node_t *)s)->name); mx_names_add(&g_mx_hidden, dn); free(dn);
    }
    else if (PM_NODE_TYPE(s) == PM_ALIAS_METHOD_NODE) {
      char *an = mx_sym_or_str(((pm_alias_method_node_t *)s)->new_name);
      if (an) { mx_names_add(&g_mx_hidden, an); free(an); } else g_mx_hide_all = 1;
    }
    else if (PM_NODE_TYPE(s) == PM_CALL_NODE) {
      const pm_call_node_t *cn = (const pm_call_node_t *)s;
      char *nm = mx_name(cn->name);
      int computed = 0;
      if (!cn->receiver) {
        if (mx_is_attr(nm)) mx_note_literals(cn, strcmp(nm, "attr_reader") != 0 && strcmp(nm, "attr") != 0, 1, &computed);
        else if (strcmp(nm, "define_method") == 0 || strcmp(nm, "alias_method") == 0) {
          char *a0 = cn->arguments && cn->arguments->arguments.size ? mx_sym_or_str(cn->arguments->arguments.nodes[0]) : NULL;
          if (a0) { mx_names_add(&g_mx_hidden, a0); free(a0); } else computed = 1;
        }
        else if (cn->arguments && cn->arguments->arguments.size == 1 &&
                 PM_NODE_TYPE(cn->arguments->arguments.nodes[0]) == PM_DEF_NODE) {
          pm_def_node_t *d = (pm_def_node_t *)cn->arguments->arguments.nodes[0];
          char *dn = mx_name(d->name); mx_names_add(&g_mx_hidden, dn); free(dn);
        }
      }
      free(nm);
      if (computed) g_mx_hide_all = 1;
    }
  }
}

static bool mx_hide_visit(const pm_node_t *n, void *data) {
  MxHideScan *hs = data;
  switch (PM_NODE_TYPE(n)) {
  case PM_MODULE_NODE: {
    /* a module's own methods are the macros: scan them as macro code */
    pm_node_t *b = ((const pm_module_node_t *)n)->body;
    if (b && PM_NODE_TYPE(b) == PM_STATEMENTS_NODE) {
      pm_statements_node_t *st = (pm_statements_node_t *)b;
      for (size_t i = 0; i < st->body.size; i++) {
        pm_node_t *s = st->body.nodes[i];
        if (PM_NODE_TYPE(s) == PM_DEF_NODE) {
          MxHideScan in = { 1 };
          pm_def_node_t *d = (pm_def_node_t *)s;
          if (d->receiver) { char *dn = mx_name(d->name); mx_names_add(&g_mx_hidden, dn); free(dn); }
          if (d->body) pm_visit_node(d->body, mx_hide_visit, &in);
        }
        else pm_visit_node(s, mx_hide_visit, hs);
      }
    }
    return false;
  }
  case PM_DEF_NODE: {
    const pm_def_node_t *d = (const pm_def_node_t *)n;
    if (d->receiver) { char *dn = mx_name(d->name); mx_names_add(&g_mx_hidden, dn); free(dn); }
    return true;
  }
  case PM_SINGLETON_CLASS_NODE:
    mx_hide_sclass_body(((const pm_singleton_class_node_t *)n)->body);
    return true;
  case PM_ALIAS_METHOD_NODE: {
    char *an = mx_sym_or_str(((const pm_alias_method_node_t *)n)->new_name);
    if (an) { mx_names_add(&g_mx_hidden, an); free(an); } else g_mx_hide_all = 1;
    return true;
  }
  case PM_UNDEF_NODE: {
    const pm_undef_node_t *u = (const pm_undef_node_t *)n;
    for (size_t i = 0; i < u->names.size; i++) {
      char *s = mx_sym_or_str(u->names.nodes[i]);
      if (s) { mx_names_add(&g_mx_hidden, s); free(s); } else g_mx_hide_all = 1;
    }
    return true;
  }
  case PM_CALL_NODE: {
    const pm_call_node_t *cn = (const pm_call_node_t *)n;
    char *nm = mx_name(cn->name);
    if (strcmp(nm, "define_singleton_method") == 0 || strcmp(nm, "alias_method") == 0 ||
        strcmp(nm, "remove_method") == 0 || strcmp(nm, "undef_method") == 0 ||
        strcmp(nm, "remove_singleton_method") == 0) {
      char *a0 = cn->arguments && cn->arguments->arguments.size ? mx_sym_or_str(cn->arguments->arguments.nodes[0]) : NULL;
      if (a0) { mx_names_add(&g_mx_hidden, a0); free(a0); }
      else if (!hs->in_macro) g_mx_hide_all = 1;
    }
    free(nm);
    return true;
  }
  default: return true;
  }
}

/* The literal names a piece of generated code gives class methods: later calls
   in the class of those names are not macros' any more. */
static bool mx_gen_visit(const pm_node_t *n, void *data) {
  MxNames *out = data;
  if (PM_NODE_TYPE(n) == PM_DEF_NODE && ((const pm_def_node_t *)n)->receiver) {
    char *dn = mx_name(((const pm_def_node_t *)n)->name); mx_names_add(out, dn); free(dn);
  }
  else if (PM_NODE_TYPE(n) == PM_SINGLETON_CLASS_NODE) {
    const pm_node_t *b = ((const pm_singleton_class_node_t *)n)->body;
    if (b && PM_NODE_TYPE(b) == PM_STATEMENTS_NODE)
      for (size_t i = 0; i < ((const pm_statements_node_t *)b)->body.size; i++) {
        pm_node_t *s = ((const pm_statements_node_t *)b)->body.nodes[i];
        if (PM_NODE_TYPE(s) == PM_DEF_NODE) { char *dn = mx_name(((pm_def_node_t *)s)->name); mx_names_add(out, dn); free(dn); }
      }
  }
  else if (PM_NODE_TYPE(n) == PM_CALL_NODE) {
    const pm_call_node_t *cn = (const pm_call_node_t *)n;
    char *nm = mx_name(cn->name);
    if ((strcmp(nm, "define_singleton_method") == 0 || strcmp(nm, "alias_method") == 0) && cn->arguments &&
        cn->arguments->arguments.size) {
      char *a0 = mx_sym_or_str(cn->arguments->arguments.nodes[0]);
      if (a0) { mx_names_add(out, a0); free(a0); }
    }
    free(nm);
  }
  return true;
}

static void mx_note_generated(const char *code, MxNames *out) {
  pm_parser_t p;
  pm_parser_init(&p, (const uint8_t *)code, strlen(code), NULL);
  pm_node_t *root = pm_parse(&p);
  const pm_parser_t *sv = g_parser;
  g_parser = &p;
  pm_visit_node(root, mx_gen_visit, out);
  g_parser = sv;
  pm_node_destroy(&p, root);
  pm_parser_free(&p);
}

typedef struct { const uint8_t *start, *end; char *text; } MxEdit;

typedef struct { MxEdit *e; int n, cap; } MxEdits;

/* A class's macro state as the walk reaches each statement: the modules it
   extended so far, its ivars, and the body being walked (the statements a
   `def self.x` called from a nested branch is looked up in). */

/* per class (by its lexical path), across every body of it in the program */
typedef struct {
  char *path;
  const char **ext; int next;   /* the modules it extends at its top level, by path */
  int vis;                      /* a bare private/protected/public/module_function came */
  int unknown;                  /* a macro call was left as written that may define methods */
  MxNames gen;                  /* class methods its expansions define */
} MxClass;

static MxClass *g_mx_classes; static int g_mx_nclasses;

static MxClass *mx_class_state(const char *path) {
  for (int i = 0; i < g_mx_nclasses; i++) if (strcmp(g_mx_classes[i].path, path) == 0) return &g_mx_classes[i];
  g_mx_classes = realloc(g_mx_classes, sizeof(MxClass) * (size_t)(g_mx_nclasses + 1));
  MxClass *k = &g_mx_classes[g_mx_nclasses++];
  memset(k, 0, sizeof *k);
  k->path = strdup(path);
  return k;
}

/* a constant as written, found as Ruby would from inside `from`: the
   innermost enclosing path that has it, then the top level */
static const char *mx_resolve_const(const char *from, const char *text) {
  for (const char *p = text; *p; p++)
    if (!(isalnum((unsigned char)*p) || *p == '_' || *p == ':')) return NULL;
  if (text[0] == ':') return mx_names_find(&g_mx_paths, text);
  size_t fl = strlen(from);
  char *cand = malloc(fl + strlen(text) + 3);
  const char *found = NULL;
  for (;;) {
    sprintf(cand, "%.*s::%s", (int)fl, from, text);
    found = mx_names_find(&g_mx_paths, cand);
    if (found || fl == 0) break;
    const char *cut = from + fl;
    while (cut > from && !(cut[-1] == ':' && cut - 1 > from && cut[-2] == ':')) cut--;
    fl = cut > from ? (size_t)(cut - from) - 2 : 0;
  }
  free(cand);
  return found;
}

static void mx_class_body(pm_statements_node_t *st, MxEdits *ed, MxClass *k, int top);

typedef struct { MxEdits *ed; const char *path; } MxWalk;

static bool mx_class_visit(const pm_node_t *n, void *data) {
  MxWalk *w = (MxWalk *)data;
  if (PM_NODE_TYPE(n) != PM_CLASS_NODE && PM_NODE_TYPE(n) != PM_MODULE_NODE) return true;
  int is_mod = PM_NODE_TYPE(n) == PM_MODULE_NODE;
  pm_node_t *cp = is_mod ? ((pm_module_node_t *)n)->constant_path : ((pm_class_node_t *)n)->constant_path;
  pm_node_t *body = is_mod ? ((pm_module_node_t *)n)->body : ((pm_class_node_t *)n)->body;
  size_t cl = (size_t)(cp->location.end - cp->location.start);
  char *path = malloc(strlen(w->path) + cl + 3);
  if (cl >= 2 && cp->location.start[0] == ':') sprintf(path, "%.*s", (int)cl, (const char *)cp->location.start);
  else sprintf(path, "%s::%.*s", w->path, (int)cl, (const char *)cp->location.start);
  if (body && PM_NODE_TYPE(body) == PM_STATEMENTS_NODE)
    mx_class_body((pm_statements_node_t *)body, w->ed, mx_class_state(path), 1);
  MxWalk sub = { w->ed, path };
  if (body) pm_visit_node(body, mx_class_visit, &sub);
  free(path);
  return false;
}

typedef struct { const uint8_t *base; int multi; } MxLitScan;

static bool mx_lit_visit(const pm_node_t *n, void *data) {
  MxLitScan *ls = data;
  const uint8_t *st = n->location.start, *en = n->location.end;
  const pm_location_t *op = NULL, *cl = NULL;
  switch (PM_NODE_TYPE(n)) {
  case PM_STRING_NODE: op = &((const pm_string_node_t *)n)->opening_loc; cl = &((const pm_string_node_t *)n)->closing_loc; break;
  case PM_X_STRING_NODE: op = &((const pm_x_string_node_t *)n)->opening_loc; cl = &((const pm_x_string_node_t *)n)->closing_loc; break;
  case PM_INTERPOLATED_STRING_NODE: op = &((const pm_interpolated_string_node_t *)n)->opening_loc; cl = &((const pm_interpolated_string_node_t *)n)->closing_loc; break;
  case PM_INTERPOLATED_X_STRING_NODE: op = &((const pm_interpolated_x_string_node_t *)n)->opening_loc; cl = &((const pm_interpolated_x_string_node_t *)n)->closing_loc; break;
  case PM_REGULAR_EXPRESSION_NODE: op = &((const pm_regular_expression_node_t *)n)->opening_loc; cl = &((const pm_regular_expression_node_t *)n)->closing_loc; break;
  case PM_INTERPOLATED_REGULAR_EXPRESSION_NODE: op = &((const pm_interpolated_regular_expression_node_t *)n)->opening_loc; cl = &((const pm_interpolated_regular_expression_node_t *)n)->closing_loc; break;
  case PM_SYMBOL_NODE: op = &((const pm_symbol_node_t *)n)->opening_loc; cl = &((const pm_symbol_node_t *)n)->closing_loc; break;
  case PM_INTERPOLATED_SYMBOL_NODE: op = &((const pm_interpolated_symbol_node_t *)n)->opening_loc; cl = &((const pm_interpolated_symbol_node_t *)n)->closing_loc; break;
  case PM_ARRAY_NODE: {
    const pm_location_t *ao = &((const pm_array_node_t *)n)->opening_loc;
    if (!ao->start || *ao->start != '%') return true;   /* a [..] list may span lines */
    break;
  }
  default: return true;
  }
  if (op && op->start && op->start < st) st = op->start;
  if (cl && cl->end && cl->end > en) en = cl->end;
  for (const uint8_t *q = st; q < en; q++) if (*q == '\n') { ls->multi = 1; return false; }
  return true;
}

/* The residual code, one statement per line, joined by `; ` on the call's
   own lines -- or NULL when that would not mean the same: trailing comments
   are cut (the one parse of the whole text says where), and a literal that
   spans lines, or a result Prism cannot parse, leaves the call as it is. */

static char *mx_join_residual(const char *t) {
  size_t tl = strlen(t);
  pm_parser_t tp;
  pm_parser_init(&tp, (const uint8_t *)t, tl, NULL);
  pm_node_t *tr = pm_parse(&tp);
  int bad = tp.error_list.size != 0;
  MxLitScan ls = { (const uint8_t *)t, 0 };
  if (!bad) pm_visit_node(tr, mx_lit_visit, &ls);
  char *drop = calloc(tl + 1, 1);
  for (pm_comment_t *cm = (pm_comment_t *)tp.comment_list.head; cm && drop; cm = (pm_comment_t *)cm->node.next)
    for (const uint8_t *q = cm->location.start; q < cm->location.end; q++)
      if (*q != '\n') drop[q - (const uint8_t *)t] = 1;
  pm_node_destroy(&tp, tr);
  pm_parser_free(&tp);
  if (bad || ls.multi || !drop) { free(drop); return NULL; }
  MxBuf rep = {0};
  int first = 1;
  size_t i = 0;
  while (i < tl) {
    size_t e = i;
    while (e < tl && t[e] != '\n') e++;
    size_t a = i, z = e;
    while (z > a && drop[z - 1]) z--;                      /* the trailing comment */
    while (a < z && (t[a] == ' ' || t[a] == '\t')) a++;
    while (z > a && (t[z - 1] == ' ' || t[z - 1] == '\t' || t[z - 1] == '\r')) z--;
    if (z > a && !drop[a]) {
      if (!first) mxb_puts(&rep, "; ");
      mxb_putn(&rep, t + a, z - a);
      first = 0;
    }
    i = e + 1;
  }
  free(drop);
  if (first) mxb_puts(&rep, "nil");
  pm_parser_t cp;
  pm_parser_init(&cp, (const uint8_t *)rep.p, rep.len, NULL);
  pm_node_t *cr = pm_parse(&cp);
  bad = cp.error_list.size != 0;
  pm_node_destroy(&cp, cr);
  pm_parser_free(&cp);
  if (bad) { free(rep.p); return NULL; }
  return rep.p;
}

/* Is some macro of this name, in any module, one that generates code? A call
   of it that is not expanded may then define methods. */
static int mx_dynamic_macro_named(const char *name) {
  MX_EACH_NAMED(m, name) if (mx_macro_dynamic(m, 0)) return 1;
  return 0;
}

static int mx_bare_visibility(const char *name) {
  return strcmp(name, "private") == 0 || strcmp(name, "protected") == 0 ||
         strcmp(name, "public") == 0 || strcmp(name, "module_function") == 0;
}

/* The statements of a class body, in program order. `top`: the statements
   themselves, not those in a branch of an `if`. */
static void mx_class_body(pm_statements_node_t *st, MxEdits *ed, MxClass *k, int top) {
  for (size_t i = 0; i < st->body.size; i++) {
    pm_node_t *s = st->body.nodes[i];
    /* `macro :X if COND` / `unless`: the expansion under the same condition */
    pm_node_t *guard = NULL; int guard_unless = 0;
    if ((PM_NODE_TYPE(s) == PM_IF_NODE || PM_NODE_TYPE(s) == PM_UNLESS_NODE)) {
      int is_if = PM_NODE_TYPE(s) == PM_IF_NODE;
      pm_statements_node_t *gs = is_if ? ((pm_if_node_t *)s)->statements : ((pm_unless_node_t *)s)->statements;
      pm_node_t *gelse = is_if ? ((pm_if_node_t *)s)->subsequent : (pm_node_t *)((pm_unless_node_t *)s)->else_clause;
      pm_node_t *gpred = is_if ? ((pm_if_node_t *)s)->predicate : ((pm_unless_node_t *)s)->predicate;
      int modifier = gs && gpred && gpred->location.start > gs->base.location.start;
      if (!modifier) {
        /* a block `if`: its statements are class-body statements too */
        if (gs) mx_class_body(gs, ed, k, 0);
        pm_node_t *ge = gelse;
        while (ge) {
          if (PM_NODE_TYPE(ge) == PM_ELSE_NODE) {
            if (((pm_else_node_t *)ge)->statements) mx_class_body(((pm_else_node_t *)ge)->statements, ed, k, 0);
            break;
          }
          if (PM_NODE_TYPE(ge) != PM_IF_NODE) break;
          if (((pm_if_node_t *)ge)->statements) mx_class_body(((pm_if_node_t *)ge)->statements, ed, k, 0);
          ge = ((pm_if_node_t *)ge)->subsequent;
        }
        continue;
      }
      if (!gs || gs->body.size != 1 || gelse || PM_NODE_TYPE(gs->body.nodes[0]) != PM_CALL_NODE) continue;
      guard = gpred;
      guard_unless = !is_if;
      s = gs->body.nodes[0];
    }
    pm_node_t *whole = guard ? st->body.nodes[i] : s;
    if (PM_NODE_TYPE(s) != PM_CALL_NODE) continue;
    pm_call_node_t *cn = (pm_call_node_t *)s;
    if (cn->receiver || cn->block) continue;
    char *name = mx_name(cn->name);
    if (mx_bare_visibility(name) && !cn->arguments) { k->vis = 1; free(name); continue; }
    if (strcmp(name, "extend") == 0 && cn->arguments) {
      /* the modules it names, by path, when it is a statement of the body */
      for (size_t j = 0; top && !guard && j < cn->arguments->arguments.size; j++) {
        pm_node_t *a = cn->arguments->arguments.nodes[j];
        if (PM_NODE_TYPE(a) != PM_CONSTANT_READ_NODE && PM_NODE_TYPE(a) != PM_CONSTANT_PATH_NODE) continue;
        char *text = strndup((const char *)a->location.start, (size_t)(a->location.end - a->location.start));
        const char *mp = mx_resolve_const(k->path, text);
        free(text);
        int dup = 0;
        for (int q = 0; mp && q < k->next; q++) if (strcmp(k->ext[q], mp) == 0) dup = 1;
        if (mp && !dup) {
          k->ext = realloc(k->ext, sizeof(char *) * (size_t)(k->next + 1));
          k->ext[k->next++] = mp;
        }
      }
      free(name);
      continue;
    }
    MxMacro *m = mx_class_macro(name);
    if (!m) {
      /* a macro name several modules or a class method share: the call may
         run code that defines methods */
      if (mx_dynamic_macro_named(name)) k->unknown = 1;
      free(name);
      continue;
    }
    if (!mx_macro_dynamic(m, 0)) { free(name); continue; }   /* defines nothing: stays as it is */
    int extended = 0;
    for (int q = 0; q < k->next; q++) if (strcmp(k->ext[q], m->module) == 0) extended = 1;
    int generated = mx_names_has(&k->gen, name);
    free(name);
    /* a heredoc argument's body lies outside the call's range */
    int hd = 0;
    for (const uint8_t *p = s->location.start; p + 2 < s->location.end && !hd; p++)
      if (p[0] == '<' && p[1] == '<' && (p[2] == '~' || p[2] == '-' || isalpha(p[2]) || p[2] == '_' ||
                                         p[2] == '"' || p[2] == '\'' || p[2] == '`'))
        hd = 1;
    if (!extended || k->vis || k->unknown || generated || hd) { k->unknown = 1; continue; }
    MxBuf out = {0};
    MxCtx c; memset(&c, 0, sizeof c);
    c.out = &out; c.modname = m->module;
    Mv r;
    g_mx_full = 0;
    int ok = mx_call_macro(&c, m, cn->arguments, &r) && !g_mx_full;
    if (!ok) {
      if (getenv("SPINEL_MACRO_DEBUG"))
        fprintf(stderr, "macro not expanded: %.*s\n", (int)(s->location.end - s->location.start), (const char *)s->location.start);
      k->unknown = 1;
      free(out.p); continue;
    }
    /* the replacement, on the call's own lines */
    int lines = 0;
    for (const uint8_t *p = whole->location.start; p < whole->location.end; p++) if (*p == '\n') lines++;
    MxBuf rep = {0};
    if (guard) {
      mxb_puts(&rep, guard_unless ? "unless " : "if ");
      mxb_putn(&rep, (const char *)guard->location.start, (size_t)(guard->location.end - guard->location.start));
      mxb_puts(&rep, "; ");
    }
    char *body = mx_join_residual(out.p ? out.p : "");
    if (!body) {
      if (getenv("SPINEL_MACRO_DEBUG"))
        fprintf(stderr, "macro residual not joinable: %.*s\n", (int)(s->location.end - s->location.start), (const char *)s->location.start);
      k->unknown = 1;
      free(rep.p); free(out.p); continue;
    }
    mx_note_generated(body, &k->gen);
    mxb_puts(&rep, body);
    free(body);
    if (guard) mxb_puts(&rep, "; end");
    /* the guard's own line breaks are in its copied text already */
    if (guard)
      for (const uint8_t *p = guard->location.start; p < guard->location.end; p++) if (*p == '\n') lines--;
    for (int q = 0; q < lines; q++) mxb_puts(&rep, "\n");
    free(out.p);
    if (ed->n == ed->cap) { ed->cap = ed->cap ? ed->cap * 2 : 32; ed->e = realloc(ed->e, sizeof(MxEdit) * (size_t)ed->cap); }
    ed->e[ed->n].start = whole->location.start;
    ed->e[ed->n].end = whole->location.end;
    ed->e[ed->n].text = rep.p;
    ed->n++;
    if (m->expanded < 512) m->sites[m->expanded] = s;
    m->expanded++;
  }
}

/* calls of each dynamic macro's name anywhere in the program */
typedef struct { int *counts; } MxCount;

static bool mx_count_visit(const pm_node_t *n, void *data) {
  MxCount *mc = (MxCount *)data;
  if (PM_NODE_TYPE(n) == PM_CALL_NODE) {
    char *nm = mx_name(((pm_call_node_t *)n)->name);
    for (int i = 0; i < g_mx_nmacros; i++) {
      if (g_mx_macros[i].expanded == 0) continue;
      char *dn = mx_name(g_mx_macros[i].def->name);
      if (strcmp(dn, nm) == 0) {
        mc->counts[i]++;
        if (getenv("SPINEL_MACRO_DEBUG")) {
          int seen = 0;
          for (int q = 0; q < g_mx_macros[i].expanded && q < 512; q++) if (g_mx_macros[i].sites[q] == n) seen = 1;
          if (!seen) {
            int line = 1;
            for (const uint8_t *p = g_parser->start; p < n->location.start; p++) if (*p == '\n') line++;
            fprintf(stderr, "unexpanded call of %s at buffer line %d\n", nm, line);
          }
        }
      }
      free(dn);
    }
    free(nm);
  }
  /* a symbol or string naming it (`method(:m)`, `respond_to?("m")`,
     `public_send("m", ...)`) keeps it too */
  const pm_string_t *us = PM_NODE_TYPE(n) == PM_SYMBOL_NODE ? &((pm_symbol_node_t *)n)->unescaped
                        : PM_NODE_TYPE(n) == PM_STRING_NODE ? &((pm_string_node_t *)n)->unescaped : NULL;
  if (us) {
    for (int i = 0; i < g_mx_nmacros; i++) {
      if (g_mx_macros[i].expanded == 0) continue;
      char *dn = mx_name(g_mx_macros[i].def->name);
      if (strlen(dn) == pm_string_length(us) &&
          memcmp(dn, pm_string_source(us), strlen(dn)) == 0) mc->counts[i] += 1000000;
      free(dn);
    }
  }
  return true;
}

/* A program that gives a reflective primitive a method of its own, or hooks
   what one does (`const_added`, `method_added`, ...), is expanded nowhere: an
   expansion would bypass the override or the hook, where CRuby runs them. */
static int mx_program_reflects(void) {
  static const char *const PRIM[] = { "module_eval", "class_eval", "instance_eval",
    "const_set", "define_method", "define_singleton_method", "public_send", "send",
    "__send__", NULL };
  static const char *const HOOK[] = { "const_added", "method_added", "singleton_method_added", NULL };
  for (int i = 0; PRIM[i]; i++) if (!mx_prim_builtin(PRIM[i])) return 1;
  for (int i = 0; HOOK[i]; i++)
    if (mx_names_has(&g_mx_hidden, HOOK[i]) || mx_first_named(HOOK[i]) || mx_names_has(&g_mx_defs, HOOK[i])) return 1;
  return 0;
}

static int mx_edit_cmp(const void *a, const void *b) {
  const MxEdit *x = a, *y = b;
  return x->start < y->start ? -1 : x->start > y->start;
}

/* Expand the class-body macro calls of `source` (the whole program). Returns
   a new buffer, or NULL when nothing was expanded. */

static char *sp_expand_class_macros(const char *source) {
  /* cheap gate: a module_eval / const_set / public_send somewhere */
  if (!strstr(source, "extend")) return NULL;
  if (!strstr(source, "module_eval") && !strstr(source, "class_eval") &&
      !strstr(source, "const_set") && !strstr(source, "public_send") &&
      !strstr(source, "define_singleton_method") && !strstr(source, "define_method"))
    return NULL;
  size_t len = strlen(source);
  if (getenv("SPINEL_MACRO_DUMP")) {
    FILE *df = fopen(getenv("SPINEL_MACRO_DUMP"), "w");
    if (df) { fputs(source, df); fclose(df); }
  }
  pm_parser_t parser;
  pm_parser_init(&parser, (const uint8_t *)source, len, NULL);
  pm_node_t *root = pm_parse(&parser);
  char *result = NULL;
  const pm_parser_t *sv = g_parser;
  g_parser = &parser;
  if (parser.error_list.size == 0) {
    g_mx_nmacros = 0;
    pm_visit_node(root, mx_collect_visit, NULL);
    mx_index_macros();
    MxHideScan hs = { 0 };
    pm_visit_node(root, mx_hide_visit, &hs);
    if (g_mx_nmacros > 0 && mx_program_reflects()) g_mx_nmacros = 0;
    if (g_mx_nmacros > 0) {
      MxEdits ed = {0};
      /* one walk in program order: a macro call sees only the extends the
         body made before it */
      MxWalk w = { &ed, "" };
      pm_visit_node(root, mx_class_visit, &w);
      for (int i = 0; i < g_mx_nclasses; i++) {
        free(g_mx_classes[i].ext);
        mx_names_free(&g_mx_classes[i].gen);
        free(g_mx_classes[i].path);
      }
      g_mx_nclasses = 0;
      if (ed.n > 0) {
        /* a macro every call of which was expanded is dropped: what it would
           do at run time is the compiler's to refuse, and nothing calls it */
        MxCount mc = { calloc((size_t)g_mx_nmacros + 1, sizeof(int)) };
        pm_visit_node(root, mx_count_visit, &mc);
        for (int i = 0; i < g_mx_nmacros; i++) {
          MxMacro *m = &g_mx_macros[i];
          if (getenv("SPINEL_MACRO_DEBUG") && m->expanded) {
            char *dn = mx_name(m->def->name);
            fprintf(stderr, "macro %s: %d calls, %d expanded\n", dn, mc.counts[i], m->expanded);
            free(dn);
          }
          if (m->expanded == 0 || mc.counts[i] != m->expanded) continue;
          const uint8_t *ds = m->def->base.location.start, *de = m->def->base.location.end;
          MxBuf blank = {0};
          for (const uint8_t *p = ds; p < de; p++) if (*p == '\n') mxb_puts(&blank, "\n");
          if (!blank.p) mxb_puts(&blank, "");
          if (ed.n == ed.cap) { ed.cap = ed.cap ? ed.cap * 2 : 32; ed.e = realloc(ed.e, sizeof(MxEdit) * (size_t)ed.cap); }
          ed.e[ed.n].start = ds; ed.e[ed.n].end = de; ed.e[ed.n].text = blank.p; ed.n++;
        }
        free(mc.counts);
        qsort(ed.e, (size_t)ed.n, sizeof(MxEdit), mx_edit_cmp);
        MxBuf nb = {0};
        const uint8_t *from = (const uint8_t *)source;
        for (int i = 0; i < ed.n; i++) {
          if (ed.e[i].start < from) continue;   /* nested in an earlier edit */
          mxb_putn(&nb, (const char *)from, (size_t)(ed.e[i].start - from));
          mxb_puts(&nb, ed.e[i].text);
          from = ed.e[i].end;
        }
        mxb_putn(&nb, (const char *)from, (size_t)((const uint8_t *)source + len - from));
        result = nb.p;
        if (getenv("SPINEL_MACRO_DEBUG"))
          for (int i = 0; i < ed.n; i++) fprintf(stderr, "macro: %s\n", ed.e[i].text);
      }
      for (int i = 0; i < ed.n; i++) free(ed.e[i].text);
      free(ed.e);
    }
    for (int i = 0; i < g_mx_nmacros; i++) { free(g_mx_macros[i].module); free(g_mx_macros[i].name); }
    free(g_mx_mtab); g_mx_mtab = NULL; g_mx_mcap = 0;
    g_mx_nmacros = 0;
    mx_names_free(&g_mx_paths);
    mx_names_free(&g_mx_defs);
    mx_names_free(&g_mx_dup);
    mx_names_free(&g_mx_hidden);
    g_mx_hide_all = 0;
  }
  g_parser = sv;
  pm_node_destroy(&parser, root);
  pm_parser_free(&parser);
  return result;
}
