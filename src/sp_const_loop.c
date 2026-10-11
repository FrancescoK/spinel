/* Class bodies built by a loop over a literal Hash (included into
 * spinel_parse.c, after sp_macro.c, whose evaluator it uses).
 *
 * A library sometimes defines a family of constants and classes from a table,
 * with a loop the class body runs once at load time:
 *
 *   module HTTPStatus
 *     StatusMessage = { 200 => 'OK', 404 => 'Not Found' }
 *     CodeToError = {}
 *     StatusMessage.each { |code, message|
 *       err_name = message.gsub(/[ \-]/, '')
 *       parent = code < 400 ? Success : ClientError
 *       const_set("RC_#{err_name.upcase}", code)
 *       err_class = Class.new(parent)
 *       err_class.instance_variable_set(:@code, code)
 *       const_set(err_name, err_class)
 *       CodeToError[code] = err_class
 *     }
 *   end
 *
 * Every name and value here is known when the program is compiled. This pass
 * runs the loop over the table and writes what it does back as the class
 * body's own statements, on the loop's lines:
 *
 *   RC_OK = 200; class OK < Success; @code = 200; end; CodeToError[200] = OK; ...
 *
 * The loop is replaced only when everything it does is understood:
 *  - it is a statement of a class or module body, `H.each` / `H.each_pair`
 *    with a block of two parameters, and H is a constant assigned a Hash
 *    literal of literal keys and values earlier in the same body, assigned
 *    nowhere else, and named elsewhere only as the receiver of a call that
 *    reads it;
 *  - its block writes only its own locals, from values the evaluator computes
 *    (sp_macro.c's mx_eval), a constant, an `if` / `case` choosing among
 *    those, or `Class.new(Constant)`;
 *  - and otherwise only calls `const_set(name, value)` with a computed
 *    constant name, `instance_variable_set(:@x, value)` on a class it made
 *    before that class is named, `Const[key] = value`, or `freeze` on a
 *    String it holds.
 * A class it makes must be named by a const_set before anything else uses
 * it, with a name the program gives a value nowhere else. The program must
 * leave the core classes whose methods the loop runs alone, give the table
 * no methods of its own, and have no inherited hook (CRuby calls it before
 * the class has a name). Anything else leaves the loop as written. */

typedef enum { CL_MV = 0, CL_CONST, CL_KLASS } ClKind;
typedef struct { ClKind k; Mv mv; char *cref; int klass; } ClVal;
typedef struct { char *parent; char *name; char *ivars; } ClKlass;   /* ivars: "@a = 1; @b = 2; " */
typedef struct { char *name; ClVal v; } ClVar;

typedef struct {
  ClVar loc[64]; int nloc;
  ClKlass *kl; int nkl, ckl;
  MxBuf *out;
  MxCtx mx;          /* the plain values, for mx_eval */
  const char *src;   /* the whole program, to look for other definitions of a name */
  char **names; int nnames;   /* the constants the loop has named so far */
} ClCtx;

static int cl_ident_char(char ch) { return isalnum((unsigned char)ch) || ch == '_' || (unsigned char)ch >= 0x80; }

/* Does `src` spell `word` as a whole word right after one of `pre`
   (e.g. "class " + "OK"), ignoring extra blanks after the prefix? */
static int cl_word_after(const char *src, const char *pre, const char *word) {
  size_t pl = strlen(pre), wl = strlen(word);
  for (const char *p = strstr(src, pre); p; p = strstr(p + 1, pre)) {
    if (p > src && cl_ident_char(p[-1])) continue;
    const char *q = p + pl;
    while (*q == ' ' || *q == '\t') q++;
    if (strncmp(q, "::", 2) == 0) q += 2;
    if (strncmp(q, word, wl) == 0 && (!cl_ident_char(word[wl - 1]) || !cl_ident_char(q[wl]))) return 1;
  }
  return 0;
}

/* Is the constant `name` given a value anywhere else in the program, or
   twice by this loop? A const_set then replaces an existing value (with
   CRuby's warning), which a class definition would reopen instead. */
static int cl_name_taken(ClCtx *c, const char *name) {
  for (int i = 0; i < c->nnames; i++) if (strcmp(c->names[i], name) == 0) return 1;
  if (cl_word_after(c->src, "class ", name) || cl_word_after(c->src, "module ", name)) return 1;
  size_t wl = strlen(name);
  for (const char *p = strstr(c->src, name); p; p = strstr(p + 1, name)) {
    if ((p > c->src && (cl_ident_char(p[-1]) || p[-1] == ':' || p[-1] == '"' || p[-1] == '\'')) ||
        cl_ident_char(p[wl])) continue;
    const char *q = p + wl;
    while (*q == ' ' || *q == '\t') q++;
    if (q[0] == '=' && q[1] != '=' && q[1] != '~' && q[1] != '>') return 1;
    if ((q[0] == '|' || q[0] == '&' || q[0] == '+' || q[0] == '-') && q[1] == q[0] && q[2] == '=') return 1;
    if ((q[0] == '|' || q[0] == '&' || q[0] == '+' || q[0] == '-' || q[0] == '*') && q[1] == '=') return 1;
  }
  return 0;
}

static void cl_take_name(ClCtx *c, const char *name) {
  c->names = realloc(c->names, sizeof(char *) * (size_t)(c->nnames + 1));
  c->names[c->nnames++] = strdup(name);
}

/* Does the program change a core class whose methods the expansion runs
   ahead of time (reopening it, or adding to it by reflection)? */
static int cl_core_changed(const char *src, const char *cls) {
  static const char *const via[] = { ".class_eval", ".class_exec", ".module_eval", ".module_exec", ".prepend",
                                     ".include", ".define_method", ".send", ".__send__", ".public_send",
                                     ".alias_method", ".remove_method", ".undef_method", NULL };
  if (cl_word_after(src, "class ", cls) || cl_word_after(src, "refine ", cls)) return 1;
  size_t cl = strlen(cls);
  for (const char *p = strstr(src, cls); p; p = strstr(p + 1, cls)) {
    if (p > src && (cl_ident_char(p[-1]) || p[-1] == ':')) continue;
    for (int i = 0; via[i]; i++) {
      size_t vl = strlen(via[i]);
      if (strncmp(p + cl, via[i], vl) == 0 && !cl_ident_char(p[cl + vl])) return 1;
    }
  }
  return 0;
}

static void cl_sync(ClCtx *c) {
  c->mx.nloc = 0;
  for (int i = 0; i < c->nloc && i < 64; i++)
    if (c->loc[i].v.k == CL_MV) mx_set(c->mx.loc, &c->mx.nloc, 64, c->loc[i].name, c->loc[i].v.mv);
}

static ClVal *cl_lookup(ClCtx *c, const char *name) {
  for (int i = 0; i < c->nloc; i++) if (strcmp(c->loc[i].name, name) == 0) return &c->loc[i].v;
  return NULL;
}

static int cl_set(ClCtx *c, const char *name, ClVal v) {
  ClVal *o = cl_lookup(c, name);
  if (o) *o = v;
  else {
    if (c->nloc >= 64) return 0;
    c->loc[c->nloc].name = strdup(name);
    c->loc[c->nloc].v = v;
    c->nloc++;
  }
  cl_sync(c);
  return 1;
}

static char *cl_text(const pm_node_t *n) {
  return strndup((const char *)n->location.start, (size_t)(n->location.end - n->location.start));
}

static int cl_eval(ClCtx *c, pm_node_t *n, ClVal *out);

/* the value as Ruby source, where it reads back as itself */
static int cl_spell(ClCtx *c, ClVal v, MxBuf *b) {
  if (v.k == CL_CONST) { mxb_puts(b, v.cref); return 1; }
  if (v.k == CL_KLASS) {
    if (!c->kl[v.klass].name) return 0;     /* an anonymous class has no spelling */
    mxb_puts(b, c->kl[v.klass].name);
    return 1;
  }
  if (v.mv.k == MV_UNDEF) return 0;
  mv_inspect(v.mv, b);
  return 1;
}

static int cl_eval(ClCtx *c, pm_node_t *n, ClVal *out) {
  memset(out, 0, sizeof *out);
  switch (PM_NODE_TYPE(n)) {
  case PM_CONSTANT_READ_NODE: case PM_CONSTANT_PATH_NODE:
    out->k = CL_CONST; out->cref = cl_text(n);
    return 1;
  case PM_LOCAL_VARIABLE_READ_NODE: {
    char *nm = mx_name(((pm_local_variable_read_node_t *)n)->name);
    ClVal *v = cl_lookup(c, nm);
    free(nm);
    if (!v) return 0;
    *out = *v; return 1;
  }
  case PM_PARENTHESES_NODE: {
    pm_node_t *b = ((pm_parentheses_node_t *)n)->body;
    if (b && PM_NODE_TYPE(b) == PM_STATEMENTS_NODE) {
      if (((pm_statements_node_t *)b)->body.size != 1) return 0;
      b = ((pm_statements_node_t *)b)->body.nodes[0];
    }
    return b && cl_eval(c, b, out);
  }
  case PM_IF_NODE: {
    pm_if_node_t *in = (pm_if_node_t *)n;
    Mv pv;
    if (!mx_eval(&c->mx, in->predicate, &pv)) return 0;
    pm_statements_node_t *arm = in->statements;
    if (!mv_truthy(pv)) {
      pm_node_t *e = in->subsequent;
      if (!e) { out->mv = mv_nil(); return 1; }
      if (PM_NODE_TYPE(e) != PM_ELSE_NODE) return cl_eval(c, e, out);
      arm = ((pm_else_node_t *)e)->statements;
    }
    if (!arm) { out->mv = mv_nil(); return 1; }
    return arm->body.size == 1 && cl_eval(c, arm->body.nodes[0], out);
  }
  case PM_CALL_NODE: {
    pm_call_node_t *cn = (pm_call_node_t *)n;
    char *name = mx_name(cn->name);
    int is_new = strcmp(name, "new") == 0;
    free(name);
    /* Class.new(Constant) */
    if (is_new && cn->receiver && PM_NODE_TYPE(cn->receiver) == PM_CONSTANT_READ_NODE && !cn->block &&
        cn->arguments && cn->arguments->arguments.size == 1) {
      char *rn = mx_name(((pm_constant_read_node_t *)cn->receiver)->name);
      int cls = strcmp(rn, "Class") == 0;
      free(rn);
      if (!cls) return 0;
      ClVal pv;
      if (!cl_eval(c, cn->arguments->arguments.nodes[0], &pv) || pv.k != CL_CONST) return 0;
      if (c->nkl == c->ckl) { c->ckl = c->ckl ? c->ckl * 2 : 16; c->kl = realloc(c->kl, sizeof(ClKlass) * (size_t)c->ckl); }
      c->kl[c->nkl].parent = pv.cref; c->kl[c->nkl].name = NULL; c->kl[c->nkl].ivars = strdup("");
      out->k = CL_KLASS; out->klass = c->nkl++;
      return 1;
    }
    break;
  }
  default: break;
  }
  out->k = CL_MV;
  return mx_eval(&c->mx, n, &out->mv);
}

/* `when` values: an Integer, String or Symbol literal, or an Integer range */
static int cl_when_matches(ClCtx *c, pm_node_t *w, Mv v, int *hit) {
  if (PM_NODE_TYPE(w) == PM_RANGE_NODE) {
    pm_range_node_t *rg = (pm_range_node_t *)w;
    Mv lo, hi;
    if (!rg->left || !rg->right || !mx_eval(&c->mx, rg->left, &lo) || !mx_eval(&c->mx, rg->right, &hi) ||
        lo.k != MV_INT || hi.k != MV_INT) return 0;
    int excl = (w->flags & PM_RANGE_FLAGS_EXCLUDE_END) != 0;
    *hit = v.k == MV_INT && v.i >= lo.i && (excl ? v.i < hi.i : v.i <= hi.i);
    return 1;
  }
  Mv wv;
  if (!mx_eval(&c->mx, w, &wv) || (wv.k != MV_INT && wv.k != MV_STR && wv.k != MV_SYM)) return 0;
  *hit = mv_eq(v, wv);
  return 1;
}

static int cl_exec_stmts(ClCtx *c, pm_statements_node_t *s);

static int cl_exec(ClCtx *c, pm_node_t *n) {
  MxBuf *o = c->out;
  switch (PM_NODE_TYPE(n)) {
  case PM_LOCAL_VARIABLE_WRITE_NODE: {
    pm_local_variable_write_node_t *w = (pm_local_variable_write_node_t *)n;
    if (w->depth != 0) return 0;     /* a local of the scope around the block */
    ClVal v;
    if (!cl_eval(c, w->value, &v)) return 0;
    char *nm = mx_name(w->name);
    int ok = cl_set(c, nm, v);
    free(nm);
    return ok;
  }
  case PM_IF_NODE: case PM_UNLESS_NODE: {
    int is_if = PM_NODE_TYPE(n) == PM_IF_NODE;
    pm_node_t *pred = is_if ? ((pm_if_node_t *)n)->predicate : ((pm_unless_node_t *)n)->predicate;
    Mv pv;
    if (!mx_eval(&c->mx, pred, &pv)) return 0;
    pm_statements_node_t *then = is_if ? ((pm_if_node_t *)n)->statements : ((pm_unless_node_t *)n)->statements;
    pm_node_t *els = is_if ? ((pm_if_node_t *)n)->subsequent : (pm_node_t *)((pm_unless_node_t *)n)->else_clause;
    if (mv_truthy(pv) == is_if) return cl_exec_stmts(c, then);
    if (!els) return 1;
    if (PM_NODE_TYPE(els) == PM_ELSE_NODE) return cl_exec_stmts(c, ((pm_else_node_t *)els)->statements);
    return cl_exec(c, els);
  }
  case PM_CASE_NODE: {
    pm_case_node_t *cs = (pm_case_node_t *)n;
    Mv v;
    if (!cs->predicate || !mx_eval(&c->mx, cs->predicate, &v)) return 0;
    for (size_t i = 0; i < cs->conditions.size; i++) {
      pm_when_node_t *wn = (pm_when_node_t *)cs->conditions.nodes[i];
      if (PM_NODE_TYPE(cs->conditions.nodes[i]) != PM_WHEN_NODE) return 0;
      for (size_t j = 0; j < wn->conditions.size; j++) {
        int hit = 0;
        if (!cl_when_matches(c, wn->conditions.nodes[j], v, &hit)) return 0;
        if (hit) return cl_exec_stmts(c, wn->statements);
      }
    }
    return cs->else_clause ? cl_exec_stmts(c, cs->else_clause->statements) : 1;
  }
  case PM_CALL_NODE: {
    pm_call_node_t *cn = (pm_call_node_t *)n;
    if (cn->block) return 0;
    pm_node_list_t *args = cn->arguments ? &cn->arguments->arguments : NULL;
    size_t argc = args ? args->size : 0;
    for (size_t i = 0; i < argc; i++)
      if (PM_NODE_TYPE(args->nodes[i]) == PM_SPLAT_NODE || PM_NODE_TYPE(args->nodes[i]) == PM_KEYWORD_HASH_NODE ||
          PM_NODE_TYPE(args->nodes[i]) == PM_BLOCK_ARGUMENT_NODE) return 0;
    char *name = mx_name(cn->name);
    int self_recv = !cn->receiver || PM_NODE_TYPE(cn->receiver) == PM_SELF_NODE;
    int ok = 0;
    if (self_recv && argc == 2 && strcmp(name, "const_set") == 0) {
      Mv cnm; ClVal v;
      if (mx_eval(&c->mx, args->nodes[0], &cnm) && (cnm.k == MV_STR || cnm.k == MV_SYM) &&
          isupper((unsigned char)cnm.s[0]) && mx_sym_plain(cnm.s) && cnm.s[strlen(cnm.s) - 1] != '?' &&
          cnm.s[strlen(cnm.s) - 1] != '!' && cnm.s[strlen(cnm.s) - 1] != '=' &&
          !cl_name_taken(c, cnm.s) && cl_eval(c, args->nodes[1], &v)) {
        cl_take_name(c, cnm.s);
        if (v.k == CL_KLASS && !c->kl[v.klass].name) {
          /* the class takes its name: its definition, with what was set on it */
          ClKlass *k = &c->kl[v.klass];
          k->name = strdup(cnm.s);
          mxb_puts(o, "class "); mxb_puts(o, k->name); mxb_puts(o, " < "); mxb_puts(o, k->parent);
          mxb_puts(o, "; "); mxb_puts(o, k->ivars); mxb_puts(o, "end; ");
          ok = 1;
        }
        else {
          MxBuf vb = {0};
          if (cl_spell(c, v, &vb)) {
            mxb_puts(o, cnm.s); mxb_puts(o, " = "); mxb_puts(o, vb.p ? vb.p : "nil"); mxb_puts(o, "; ");
            ok = 1;
          }
          free(vb.p);
        }
      }
    }
    else if (!self_recv && argc == 2 && strcmp(name, "instance_variable_set") == 0) {
      ClVal r, v; Mv ivn;
      if (cl_eval(c, cn->receiver, &r) && r.k == CL_KLASS && !c->kl[r.klass].name &&
          mx_eval(&c->mx, args->nodes[0], &ivn) && (ivn.k == MV_SYM || ivn.k == MV_STR) &&
          ivn.s[0] == '@' && ivn.s[1] != '@' && mx_sym_plain(ivn.s + 1) && cl_eval(c, args->nodes[1], &v)) {
        MxBuf vb = {0};
        if (cl_spell(c, v, &vb)) {
          ClKlass *k = &c->kl[r.klass];
          size_t need = strlen(k->ivars) + strlen(ivn.s) + (vb.p ? strlen(vb.p) : 3) + 8;
          char *nv = malloc(need);
          snprintf(nv, need, "%s%s = %s; ", k->ivars, ivn.s, vb.p ? vb.p : "nil");
          free(k->ivars); k->ivars = nv;
          ok = 1;
        }
        free(vb.p);
      }
    }
    else if (!self_recv && argc == 2 && strcmp(name, "[]=") == 0 &&
             (PM_NODE_TYPE(cn->receiver) == PM_CONSTANT_READ_NODE || PM_NODE_TYPE(cn->receiver) == PM_CONSTANT_PATH_NODE)) {
      ClVal kv, v;
      MxBuf kb = {0}, vb = {0};
      if (cl_eval(c, args->nodes[0], &kv) && cl_eval(c, args->nodes[1], &v) &&
          cl_spell(c, kv, &kb) && cl_spell(c, v, &vb)) {
        char *rt = cl_text(cn->receiver);
        mxb_puts(o, rt); mxb_puts(o, "["); mxb_puts(o, kb.p); mxb_puts(o, "] = "); mxb_puts(o, vb.p); mxb_puts(o, "; ");
        free(rt);
        ok = 1;
      }
      free(kb.p); free(vb.p);
    }
    else if (!self_recv && argc == 0 && strcmp(name, "freeze") == 0) {
      /* a String the loop holds is a value it spells out: nothing to keep */
      ClVal r;
      ok = cl_eval(c, cn->receiver, &r) && r.k == CL_MV && (r.mv.k == MV_STR || r.mv.k == MV_INT || r.mv.k == MV_SYM);
    }
    free(name);
    return ok;
  }
  default: return 0;
  }
}

static int cl_exec_stmts(ClCtx *c, pm_statements_node_t *s) {
  if (!s) return 1;
  for (size_t i = 0; i < s->body.size; i++) if (!cl_exec(c, s->body.nodes[i])) return 0;
  return 1;
}

/* ---- where the table's constant is named ---- */
typedef struct {
  pm_constant_id_t name;
  const pm_node_t *def;      /* its one write */
  const pm_node_t *loop;     /* the loop's receiver */
  int writes, bad;
} ClUse;

static int cl_read_only(const char *m) {
  static const char *const R[] = { "each", "each_pair", "[]", "fetch", "key?", "has_key?", "include?",
    "member?", "key", "keys", "values", "size", "length", "empty?", "dig", "to_a", "frozen?", "freeze",
    "each_key", "each_value", "values_at", "has_value?", "value?", "count", "any?", "all?", "none?",
    "find", "detect", "map", "collect", "select", "filter", "reject", "min_by", "max_by", "sort_by",
    "group_by", "sum", "inject", "reduce", "to_h", "invert", "sort", "first", "inspect", "to_s", "hash", "==", NULL };
  for (int i = 0; R[i]; i++) if (strcmp(R[i], m) == 0) return 1;
  return 0;
}

static bool cl_use_visit(const pm_node_t *n, void *data) {
  ClUse *u = (ClUse *)data;
  switch (PM_NODE_TYPE(n)) {
  case PM_CONSTANT_WRITE_NODE: case PM_CONSTANT_OR_WRITE_NODE: case PM_CONSTANT_AND_WRITE_NODE:
  case PM_CONSTANT_OPERATOR_WRITE_NODE: {
    pm_constant_id_t nm = PM_NODE_TYPE(n) == PM_CONSTANT_WRITE_NODE ? ((pm_constant_write_node_t *)n)->name
                        : PM_NODE_TYPE(n) == PM_CONSTANT_OR_WRITE_NODE ? ((pm_constant_or_write_node_t *)n)->name
                        : PM_NODE_TYPE(n) == PM_CONSTANT_AND_WRITE_NODE ? ((pm_constant_and_write_node_t *)n)->name
                        : ((pm_constant_operator_write_node_t *)n)->name;
    if (nm == u->name) u->writes++;
    break;
  }
  case PM_CONSTANT_PATH_WRITE_NODE: case PM_CONSTANT_PATH_OR_WRITE_NODE: case PM_CONSTANT_PATH_AND_WRITE_NODE:
  case PM_CONSTANT_PATH_OPERATOR_WRITE_NODE: case PM_CONSTANT_TARGET_NODE: case PM_CONSTANT_PATH_TARGET_NODE:
    /* a write of any path, or a multiple assignment: not followed */
    u->bad = 1;
    break;
  case PM_CALL_NODE: {
    const pm_call_node_t *cn = (const pm_call_node_t *)n;
    const pm_node_t *r = cn->receiver;
    int mine = r && ((PM_NODE_TYPE(r) == PM_CONSTANT_READ_NODE && ((pm_constant_read_node_t *)r)->name == u->name) ||
                     (PM_NODE_TYPE(r) == PM_CONSTANT_PATH_NODE && ((pm_constant_path_node_t *)r)->name == u->name));
    if (mine) {
      char *m = mx_name(cn->name);
      int ro = cl_read_only(m);
      free(m);
      /* the receiver read is fine; its arguments and block are visited */
      if (!ro) u->bad = 1;
      if (cn->arguments) pm_visit_node((const pm_node_t *)cn->arguments, cl_use_visit, u);
      if (cn->block) pm_visit_node(cn->block, cl_use_visit, u);
      return false;
    }
    break;
  }
  case PM_CONSTANT_READ_NODE:
    if (((pm_constant_read_node_t *)n)->name == u->name) u->bad = 1;   /* handed on as a value */
    break;
  case PM_CONSTANT_PATH_NODE:
    if (((pm_constant_path_node_t *)n)->name == u->name) u->bad = 1;
    return false;
  default: break;
  }
  return true;
}

typedef struct { MxEdits *ed; pm_node_t *root; const char *src; } ClWalk;

/* the Hash literal the table is: every key and value a literal */
static int cl_table(ClCtx *c, pm_node_t *h, Mv **keys, Mv **vals, int *n) {
  if (PM_NODE_TYPE(h) != PM_HASH_NODE) return 0;
  pm_hash_node_t *hn = (pm_hash_node_t *)h;
  *n = (int)hn->elements.size;
  *keys = calloc((size_t)*n + 1, sizeof(Mv)); *vals = calloc((size_t)*n + 1, sizeof(Mv));
  for (int i = 0; i < *n; i++) {
    pm_node_t *e = hn->elements.nodes[i];
    if (PM_NODE_TYPE(e) != PM_ASSOC_NODE) return 0;
    pm_assoc_node_t *as = (pm_assoc_node_t *)e;
    if (!mx_eval(&c->mx, as->key, &(*keys)[i]) || !mx_eval(&c->mx, as->value, &(*vals)[i])) return 0;
    if ((*keys)[i].k == MV_ARR || (*vals)[i].k == MV_ARR) return 0;
    for (int j = 0; j < i; j++) if (mv_eq((*keys)[i], (*keys)[j])) return 0;   /* a repeated key */
  }
  return 1;
}

static void cl_try_body(ClWalk *w, pm_statements_node_t *st) {
  for (size_t i = 0; i < st->body.size; i++) {
    pm_node_t *s = st->body.nodes[i];
    if (PM_NODE_TYPE(s) != PM_CALL_NODE) continue;
    pm_call_node_t *cn = (pm_call_node_t *)s;
    if (!cn->receiver || PM_NODE_TYPE(cn->receiver) != PM_CONSTANT_READ_NODE || cn->arguments ||
        !cn->block || PM_NODE_TYPE(cn->block) != PM_BLOCK_NODE) continue;
    char *m = mx_name(cn->name);
    int each = strcmp(m, "each") == 0 || strcmp(m, "each_pair") == 0;
    free(m);
    if (!each) continue;
    pm_block_node_t *blk = (pm_block_node_t *)cn->block;
    if (!blk->parameters || PM_NODE_TYPE(blk->parameters) != PM_BLOCK_PARAMETERS_NODE) continue;
    pm_parameters_node_t *ps = ((pm_block_parameters_node_t *)blk->parameters)->parameters;
    if (!ps || ps->requireds.size != 2 || ps->optionals.size || ps->rest || ps->posts.size ||
        ps->keywords.size || ps->keyword_rest || ps->block) continue;
    if (PM_NODE_TYPE(ps->requireds.nodes[0]) != PM_REQUIRED_PARAMETER_NODE ||
        PM_NODE_TYPE(ps->requireds.nodes[1]) != PM_REQUIRED_PARAMETER_NODE) continue;
    if (blk->body && PM_NODE_TYPE(blk->body) != PM_STATEMENTS_NODE) continue;
    /* the table: one write, earlier in this body, of a literal Hash */
    pm_constant_id_t tn = ((pm_constant_read_node_t *)cn->receiver)->name;
    pm_node_t *def = NULL;
    for (size_t j = 0; j < i; j++) {
      pm_node_t *d = st->body.nodes[j];
      if (PM_NODE_TYPE(d) == PM_CONSTANT_WRITE_NODE && ((pm_constant_write_node_t *)d)->name == tn) def = d;
    }
    if (!def) continue;
    ClUse u; memset(&u, 0, sizeof u); u.name = tn;
    pm_visit_node(w->root, cl_use_visit, &u);
    if (u.writes != 1 || u.bad) continue;
    /* a method of the table's own replaces the Hash's each */
    { static const char *const sing[] = { "define_singleton_method", "extend", "singleton_class",
                                          "instance_eval", "instance_exec", NULL };
      char *tt = cl_text(cn->receiver);
      size_t tl = strlen(tt) + 2; char *dp = malloc(tl);
      snprintf(dp, tl, "%s.", tt);
      int own = cl_word_after(w->src, "def ", dp) || cl_word_after(w->src, "class << ", tt);
      for (int q = 0; sing[q] && !own; q++) own = cl_word_after(w->src, dp, sing[q]);
      free(dp); free(tt);
      if (own) continue; }
    ClCtx c; memset(&c, 0, sizeof c);
    c.src = w->src;
    Mv *keys = NULL, *vals = NULL; int n = 0;
    if (!cl_table(&c, ((pm_constant_write_node_t *)def)->value, &keys, &vals, &n)) { free(keys); free(vals); continue; }
    char *kname = mx_name(((pm_required_parameter_node_t *)ps->requireds.nodes[0])->name);
    char *vname = mx_name(((pm_required_parameter_node_t *)ps->requireds.nodes[1])->name);
    MxBuf out = {0};
    c.out = &out;
    int ok = 1;
    for (int e = 0; e < n && ok; e++) {
      c.nloc = 0;
      ClVal kv; memset(&kv, 0, sizeof kv); kv.mv = keys[e];
      ClVal vv; memset(&vv, 0, sizeof vv); vv.mv = vals[e];
      ok = cl_set(&c, kname, kv) && cl_set(&c, vname, vv) &&
           cl_exec_stmts(&c, (pm_statements_node_t *)blk->body);
    }
    /* a class it made that never took a name is a value the run time needs */
    for (int k = 0; k < c.nkl && ok; k++) if (!c.kl[k].name) ok = 0;
    if (ok) {
      int lines = 0;
      for (const uint8_t *p = s->location.start; p < s->location.end; p++) if (*p == '\n') lines++;
      MxBuf rep = {0};
      mxb_puts(&rep, out.p ? out.p : "");
      { char *rv = cl_text(cn->receiver);   /* Hash#each answers its receiver */
        mxb_puts(&rep, rv); free(rv); }
      for (int q = 0; q < lines; q++) mxb_puts(&rep, "\n");
      MxEdits *ed = w->ed;
      if (ed->n == ed->cap) { ed->cap = ed->cap ? ed->cap * 2 : 8; ed->e = realloc(ed->e, sizeof(MxEdit) * (size_t)ed->cap); }
      ed->e[ed->n].start = s->location.start;
      ed->e[ed->n].end = s->location.end;
      ed->e[ed->n].text = rep.p;
      ed->n++;
    }
    else if (getenv("SPINEL_MACRO_DEBUG"))
      fprintf(stderr, "table loop not expanded: %.*s\n", (int)(s->location.end - s->location.start > 60 ? 60 : s->location.end - s->location.start),
              (const char *)s->location.start);
    free(out.p); free(kname); free(vname); free(keys); free(vals);
    for (int k = 0; k < c.nkl; k++) { free(c.kl[k].name); free(c.kl[k].ivars); }
    free(c.kl);
    for (int k = 0; k < c.nloc; k++) free(c.loc[k].name);
    for (int k = 0; k < c.nnames; k++) free(c.names[k]);
    free(c.names);
  }
}

static bool cl_visit(const pm_node_t *n, void *data) {
  ClWalk *w = (ClWalk *)data;
  pm_node_t *body = PM_NODE_TYPE(n) == PM_CLASS_NODE ? ((pm_class_node_t *)n)->body
                  : PM_NODE_TYPE(n) == PM_MODULE_NODE ? ((pm_module_node_t *)n)->body : NULL;
  if (body && PM_NODE_TYPE(body) == PM_STATEMENTS_NODE) cl_try_body(w, (pm_statements_node_t *)body);
  return true;
}

/* Expand the table loops of `source` (the whole program). Returns a new
   buffer, or NULL when nothing was expanded. */
static char *sp_expand_table_loops(const char *source) {
  if (!strstr(source, "const_set") || !strstr(source, "Class.new")) return NULL;
  /* a program that gives const_set a method of its own, or hooks it, keeps
     its loops: the expansion would bypass them */
  if (strstr(source, "def const_set") || strstr(source, "def self.const_set") || strstr(source, "const_added") ||
      strstr(source, "def instance_variable_set")) return NULL;
  /* the loop runs Hash, String, Integer, Range and Symbol methods, Class.new
     and const_set ahead of time: a program that changes those classes keeps
     its loops. So does one with an inherited hook, which CRuby calls while
     the new class has no name yet. */
  static const char *const core[] = { "Hash", "String", "Integer", "Range", "Symbol", "Class", "Module",
                                      "Comparable", "Kernel", "Object", "BasicObject", NULL };
  for (int i = 0; core[i]; i++) if (cl_core_changed(source, core[i])) return NULL;
  if (strstr(source, "inherited")) return NULL;
  size_t len = strlen(source);
  pm_parser_t parser;
  pm_parser_init(&parser, (const uint8_t *)source, len, NULL);
  pm_node_t *root = pm_parse(&parser);
  char *result = NULL;
  const pm_parser_t *sv = g_parser;
  g_parser = &parser;
  if (parser.error_list.size == 0) {
    MxEdits ed = {0};
    ClWalk w = { &ed, root, source };
    pm_visit_node(root, cl_visit, &w);
    if (ed.n > 0) {
      qsort(ed.e, (size_t)ed.n, sizeof(MxEdit), mx_edit_cmp);
      MxBuf nb = {0};
      const uint8_t *from = (const uint8_t *)source;
      for (int i = 0; i < ed.n; i++) {
        if (ed.e[i].start < from) continue;
        mxb_putn(&nb, (const char *)from, (size_t)(ed.e[i].start - from));
        mxb_puts(&nb, ed.e[i].text);
        from = ed.e[i].end;
      }
      mxb_putn(&nb, (const char *)from, (size_t)((const uint8_t *)source + len - from));
      result = nb.p;
      if (getenv("SPINEL_MACRO_DEBUG"))
        for (int i = 0; i < ed.n; i++) fprintf(stderr, "table loop: %s\n", ed.e[i].text);
    }
    for (int i = 0; i < ed.n; i++) free(ed.e[i].text);
    free(ed.e);
  }
  g_parser = sv;
  pm_node_destroy(&parser, root);
  pm_parser_free(&parser);
  return result;
}
