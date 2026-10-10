/* analyze_const.c -- which constants a read can reach before their assignment.

   A constant is a C global assigned where the program assigns it, and CRuby
   raises NameError for a read, defined?, const_defined? or const_get that
   runs before that. A constant read after its assignment is the common case
   and needs nothing at run time, so the analysis settles it: its assignment
   is a statement of the top level or of a class or module body (a
   Struct.new, Class.new block's body counts; so does a multiple assignment's
   constant targets), and either

     - nothing that runs before it, in program order and entering the bodies,
       can run code of the program's: only definitions (def, class, module,
       alias, attr_*, include, extend, prepend, a visibility call) and the
       settled assignments of other constants, whose values are built of
       literals, settled constants, class constructors and the builtin
       operators on those; or
     - no read of the constant (a bare name or a path, defined?, const_get,
       const_defined?) and no `constants` call comes earlier in program order
       than the assignment: a method that reads it and is written before the
       assignment is such a read, one written after it is not, since the def
       has not run before the assignment has. An assignment's own value is
       earlier than it.

   The program has already spliced a required file in, so its top level is
   one more run of that walk.

   An assignment is a statement of a body when it is a plain `K = v`, a
   constant target of a multiple assignment, or `Mod::K = v`. Other
   assignments of the same constant (inside a method, a block or a branch,
   the `||=`, `op=` and const_set forms) matter only if one can come before
   that first one in program order.

   Every other constant keeps a presence flag, LocalVar.const_early: its
   assignment sets it, and a read that finds it clear raises NameError
   (codegen_util.c, const_has_flag). The walk reads no types, so the guard
   folds that decide `defined?(K)` before inference (comp_defined_guard_true)
   can ask it. A program that defines const_missing, which spinel does not
   call, flags none, and a name that is also a class's is not flagged.

   A program that defines a method a definition runs (inherited, included,
   method_added ...) has its definitions counted as code of the program's
   too, and one that reopens a builtin class has the builtin operators
   counted so. The pass also names, for each flagged bare read, the class or
   module it is written in (`const_cref`), as the error shows it. */

#include <limits.h>
#include "analyze_internal.h"
#include "builtin_names.h"

typedef struct {
  Compiler *c;
  const NodeTable *nt;
  char *settled;     /* per node: a ConstantWriteNode no code of the program's precedes */
  char *direct;      /* per node: a ConstantWriteNode that is a statement of a body */
  char *seen;        /* per constant: a settled assignment has run */
  char *plain;       /* per constant: ... of a value built of literals alone */
  int clean;         /* nothing that has run so far can run the program's code */
  int *wpost;        /* per node: where an assignment completes in program order */
  int *pre;          /* per node: where it starts in program order */
  int *cref_at;      /* per node: the class or module it is written in, as an index + 1 into crefs */
  char **crefs;      /* the lexical names of those, as an error shows them */
  int ncrefs, ccrefs;
  int *rd;           /* per constant: where it is first read in program order */
  int listed;        /* where the first `constants` call is in program order */
  int hooks;         /* a definition can run a hook of the program's */
  int cmissing;      /* the program defines const_missing, which spinel does not call */
  int reopened;      /* a builtin class is reopened: its operators may be the program's */
} ConstWalk;

static int cw_index(const ConstWalk *w, const LocalVar *lv) { return (int)(lv - w->c->consts); }

static void cw_stmt(ConstWalk *w, int id, int depth);

/* Statements of a body, run in order. */
static void cw_stmts(ConstWalk *w, int body, int depth) {
  if (body < 0) return;
  if (nt_kind(w->nt, body) != NK_StatementsNode) { cw_stmt(w, body, depth); return; }
  int n = 0; const int *ids = nt_arr(w->nt, body, "body", &n);
  for (int i = 0; i < n; i++) cw_stmt(w, ids[i], depth);
}

/* Evaluating node id runs no code of the program's: 0 when it can, 1 when it
   cannot, 2 when it also yields a value built of literals alone (whose
   builtin operators run none either). A body a class builder runs is walked
   as the statements it is. */
static int cw_value_walk(ConstWalk *w, int id, int depth);
static int cw_value(ConstWalk *w, int id, int depth) {
  int r = cw_value_walk(w, id, depth);
  /* from here on the program's code may have run */
  if (!r) w->clean = 0;
  return r;
}
static int cw_value_walk(ConstWalk *w, int id, int depth) {
  const NodeTable *nt = w->nt;
  if (id < 0) return 2;
  if (depth > 100) return 0;
  switch (nt_kind(nt, id)) {
    case NK_IntegerNode: case NK_FloatNode: case NK_StringNode: case NK_SymbolNode:
    case NK_NilNode: case NK_TrueNode: case NK_FalseNode: case NK_RationalNode:
    case NK_ImaginaryNode: case NK_RegularExpressionNode:
      return 2;
    case NK_SelfNode: case NK_LambdaNode: case NK_LocalVariableReadNode:
      return 1;
    case NK_DefNode: case NK_AliasMethodNode: case NK_UndefNode:
      return w->hooks ? 0 : 1;
    case NK_ArrayNode: case NK_HashNode: case NK_KeywordHashNode: case NK_StatementsNode:
    case NK_InterpolatedStringNode: case NK_RangeNode: case NK_AssocNode: case NK_ParenthesesNode:
    case NK_EmbeddedStatementsNode: {
      int r = 2;
      static const char *const arrs[] = { "elements", "body", "parts", NULL };
      static const char *const refs[] = { "left", "right", "key", "value", "statements", "body", NULL };
      for (int k = 0; arrs[k]; k++) {
        int n = 0; const int *ids = nt_arr(nt, id, arrs[k], &n);
        for (int i = 0; ids && i < n; i++) { int v = cw_value(w, ids[i], depth + 1); if (v < r) r = v; }
      }
      for (int k = 0; refs[k]; k++) {
        int ch = nt_ref(nt, id, refs[k]);
        if (ch >= 0) { int v = cw_value(w, ch, depth + 1); if (v < r) r = v; }
      }
      /* an interpolation converts its value: only a literal-built one is the builtin's */
      if (nt_kind(nt, id) == NK_EmbeddedStatementsNode && r == 1) r = 0;
      return r;
    }
    case NK_LocalVariableWriteNode:
      return cw_value(w, nt_ref(nt, id, "value"), depth + 1) ? 1 : 0;
    case NK_ConstantReadNode: case NK_ConstantPathNode: {
      /* a class or a builtin constant is there; a value constant must have been assigned */
      int par = nt_kind(nt, id) == NK_ConstantPathNode ? nt_ref(nt, id, "parent") : -1;
      if (par >= 0 && !cw_value(w, par, depth + 1)) return 0;
      const char *nm = nt_str(nt, id, "name");
      LocalVar *lv = nm ? comp_const(w->c, nm) : NULL;
      if (!lv) return 1;
      int i = cw_index(w, lv);
      return w->seen[i] ? (w->plain[i] ? 2 : 1) : 0;
    }
    case NK_CallNode: {
      const char *nm = nt_str(nt, id, "name");
      int r = nt_ref(nt, id, "receiver"), a = nt_ref(nt, id, "arguments"), blk = nt_ref(nt, id, "block");
      int an = 0; const int *av = a >= 0 ? nt_arr(nt, a, "arguments", &an) : NULL;
      if (!nm) return 0;
      int ar = 2;
      for (int i = 0; i < an; i++) { int v = cw_value(w, av[i], depth + 1); if (v < ar) ar = v; }
      if (ar == 0) return 0;
      if (r < 0) {
        if (blk >= 0) return 0;
        /* the declarations of a body; a mixin runs the module's hook, if any */
        if (is_attr_reader_family(nm) || is_attr_writer_family(nm) || is_visibility_or_module_function(nm))
          return 1;
        return is_mixin_call(nm) && !w->hooks ? 1 : 0;
      }
      int rv = cw_value(w, r, depth + 1);
      if (rv == 0) return 0;
      const char *rn = nt_kind(nt, r) == NK_ConstantReadNode ? nt_str(nt, r, "name") : NULL;
      /* Struct.new, Data.define, Class.new, Module.new: the body they take runs now */
      if (rn && is_class_builder(rn, nm) && !w->hooks && !w->reopened) {
        if (blk < 0) return 1;
        if (nt_kind(nt, blk) != NK_BlockNode) return 0;
        cw_stmts(w, nt_ref(nt, blk, "body"), depth + 1);
        return w->clean ? 1 : 0;
      }
      if (blk >= 0) return 0;
      if (rn && is_value_constructor(rn, nm) && ar == 2 && !w->reopened) return 1;
      if (is_freeze_family(nm) && an == 0) return rv;
      if (rv == 2 && ar == 2 && !w->reopened &&
          (is_arith_op(nm) || is_cmp_op(nm) || is_eq_op(nm) || is_bit_op(nm) || is_shift_op(nm)))
        return 2;
      /* +"lit" */
      if (rv == 2 && an == 0 && !w->reopened && is_unary_sign(nm))
        return 2;
      return 0;
    }
    default:
      return 0;
  }
}

/* One statement, run in program order. A constant assignment is settled when
   nothing that ran before it can have run the program's code, and so is one
   of the builtin library's (the statements of builtins/ and the packages
   run the library's own code, which never reads the program's constants). */
static void cw_stmt_walk(ConstWalk *w, int id, int depth) {
  const NodeTable *nt = w->nt;
  if (id < 0 || depth > 100) return;
  switch (nt_kind(nt, id)) {
    case NK_StatementsNode:
      cw_stmts(w, id, depth + 1);
      return;
    case NK_ClassNode: case NK_ModuleNode: case NK_SingletonClassNode: {
      /* creating the class runs `inherited` (and const_added) when defined */
      int sup = nt_kind(nt, id) == NK_ClassNode ? nt_ref(nt, id, "superclass") : -1;
      if (w->hooks || (sup >= 0 && !cw_value(w, sup, depth + 1))) w->clean = 0;
      cw_stmts(w, nt_ref(nt, id, "body"), depth + 1);
      return;
    }
    case NK_ConstantWriteNode: {
      int bi = nt_int(nt, id, "node_bi", 0) != 0;
      int was = w->clean || bi;
      int r = cw_value(w, nt_ref(nt, id, "value"), depth + 1);
      if (!r) w->clean = 0;
      const char *nm = nt_str(nt, id, "name");
      LocalVar *lv = nm ? comp_const(w->c, nm) : NULL;
      w->direct[id] = 1;
      if (was && (r || bi) && lv) {
        int i = cw_index(w, lv);
        w->settled[id] = 1;
        w->seen[i] = 1;
        w->plain[i] = r == 2;
      }
      return;
    }
    case NK_MultiWriteNode: {
      /* A, B = v: the constant targets are assigned when the value is done */
      static const char *const sides[] = { "lefts", "rights", NULL };
      int bi = nt_int(nt, id, "node_bi", 0) != 0;
      int was = w->clean || bi;
      int r = cw_value(w, nt_ref(nt, id, "value"), depth + 1);
      if (!r) w->clean = 0;
      for (int k = 0; sides[k]; k++) {
        int n = 0; const int *ts = nt_arr(nt, id, sides[k], &n);
        for (int i = 0; i < n; i++) {
          if (nt_kind(nt, ts[i]) != NK_ConstantTargetNode) continue;
          const char *nm = nt_str(nt, ts[i], "name");
          LocalVar *lv = nm ? comp_const(w->c, nm) : NULL;
          w->direct[ts[i]] = 1;
          if (was && (r || bi) && lv) { w->settled[ts[i]] = 1; w->seen[cw_index(w, lv)] = 1; }
        }
      }
      return;
    }
    case NK_ConstantPathWriteNode: {
      /* Mod::K = v is the assignment of K as a plain one is */
      int bi = nt_int(nt, id, "node_bi", 0) != 0;
      int was = w->clean || bi;
      int r = cw_value(w, nt_ref(nt, id, "value"), depth + 1);
      int tgt = nt_ref(nt, id, "target");
      const char *nm = tgt >= 0 ? nt_str(nt, tgt, "name") : NULL;
      LocalVar *lv = nm ? comp_const(w->c, nm) : NULL;
      w->direct[id] = 1;
      if (was && (r || bi) && lv) { w->settled[id] = 1; w->seen[cw_index(w, lv)] = 1; }
      return;
    }
    case NK_ConstantOrWriteNode: case NK_ConstantAndWriteNode:
    case NK_ConstantOperatorWriteNode: case NK_ConstantPathOrWriteNode:
    case NK_ConstantPathAndWriteNode: case NK_ConstantPathOperatorWriteNode:
      if (!cw_value(w, nt_ref(nt, id, "value"), depth + 1)) w->clean = 0;
      return;
    default:
      if (!cw_value(w, id, depth + 1)) w->clean = 0;
      return;
  }
}

static void cw_stmt(ConstWalk *w, int id, int depth) {
  int bi = id >= 0 && nt_int(w->nt, id, "node_bi", 0) != 0, clean = w->clean;
  cw_stmt_walk(w, id, depth);
  if (bi) w->clean = clean;
}

/* The constant a node reads by name: a bare or path constant, or the name
   const_get and its kin are given. */
static const char *cw_read_name(const NodeTable *nt, int id) {
  switch (nt_kind(nt, id)) {
    case NK_ConstantReadNode: case NK_ConstantPathNode:
      return nt_str(nt, id, "name");
    case NK_CallNode: {
      const char *cn = nt_str(nt, id, "name");
      int a = nt_ref(nt, id, "arguments"), an = 0;
      const int *av = a >= 0 ? nt_arr(nt, a, "arguments", &an) : NULL;
      if (!cn || !is_const_query_name(cn) || an < 1) return NULL;
      NodeKind ak = nt_kind(nt, av[0]);
      return ak == NK_SymbolNode ? nt_str(nt, av[0], "value") : ak == NK_StringNode ? nt_str(nt, av[0], "content") : NULL;
    }
    default:
      return NULL;
  }
}

/* One entry of cw_order's work list: a node to visit, an assignment that
   completes after its value, or a class body left (id: the cref outside). */
typedef struct { int id, tag; } CwItem;
enum { CW_VISIT, CW_DONE, CW_LEAVE };

/* The lexical name of the class or module a node is written in, an error
   shows: -1 when the node opens none; else its index in w->crefs. */
static int cw_cref_name(ConstWalk *w, int id, int cur) {
  const NodeTable *nt = w->nt;
  char buf[512];
  NodeKind k = nt_kind(nt, id);
  if (k == NK_SingletonClassNode) {
    int ex = nt_ref(nt, id, "expression");
    if (cur < 0 || ex < 0 || nt_kind(nt, ex) != NK_SelfNode) return -1;
    snprintf(buf, sizeof buf, "#<Class:%s>", w->crefs[cur]);
  }
  else {
    /* a Class.new block is no cref: the code in it is written where the call is */
    if (nt_int(nt, id, "class_new_anonymous", 0)) return -1;
    int cp = nt_ref(nt, id, "constant_path");
    const char *nm = cp >= 0 ? nt_str(nt, cp, "name") : NULL;
    int ci = nm ? comp_class_index(w->c, nm) : -1;
    const char *q = ci >= 0 ? class_ruby_name(w->c, ci) : nm;
    if (!q) return -1;
    snprintf(buf, sizeof buf, "%s", q);
  }
  for (int i = 0; i < w->ncrefs; i++) if (sp_streq(w->crefs[i], buf)) return i;
  if (w->ncrefs == w->ccrefs) {
    w->ccrefs = w->ccrefs ? w->ccrefs * 2 : 16;
    w->crefs = realloc(w->crefs, sizeof(char *) * (size_t)w->ccrefs);
    if (!w->crefs) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  }
  w->crefs[w->ncrefs] = strdup(buf);
  if (!w->crefs[w->ncrefs]) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  return w->ncrefs++;
}

/* Number the tree in program order (a node before its children, an
   assignment after its value): where each node starts, where each assignment
   completes, the first read of each constant, the first `constants` call, and
   the class or module each constant read is written in. The tables a
   const_get with a computed name is turned into are the compiler's, and
   their reads of every constant of a body are not the program's. */
static void cw_order(ConstWalk *w) {
  const NodeTable *nt = w->nt;
  int cap = 256, sp = 0, ord = 0, cur = -1;
  CwItem *stk = malloc(sizeof(CwItem) * (size_t)cap);
  if (!stk) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  stk[sp++] = (CwItem){ nt->root_id, CW_VISIT };
  while (sp > 0) {
    CwItem it = stk[--sp];
    if (it.tag == CW_LEAVE) { cur = it.id; continue; }
    if (it.tag == CW_DONE) {
      /* an assignment completes: a multiple assignment's targets together */
      static const char *const sides[] = { "lefts", "rights", NULL };
      ++ord;
      if (nt_kind(nt, it.id) != NK_MultiWriteNode) w->wpost[it.id] = ord;
      else for (int k = 0; sides[k]; k++) {
        int n = 0; const int *ts = nt_arr(nt, it.id, sides[k], &n);
        for (int i = 0; i < n; i++) w->wpost[ts[i]] = ord;
      }
      continue;
    }
    int id = it.id;
    NodeKind k = nt_kind(nt, id);
    if (k == NK_DefNode && is_const_table_def_name(nt_str(nt, id, "name"))) continue;
    w->pre[id] = ++ord;
    const char *rn = cw_read_name(nt, id);
    LocalVar *lv = rn ? comp_const(w->c, rn) : NULL;
    if (lv && w->rd[cw_index(w, lv)] > ord) w->rd[cw_index(w, lv)] = ord;
    if (k == NK_ConstantReadNode) w->cref_at[id] = cur + 1;
    if (k == NK_CallNode) {
      const char *cn = nt_str(nt, id, "name");
      if (cn && is_constants_list_name(cn) && w->listed > ord) w->listed = ord;
    }
    int nr = nt_num_refs(nt, id), na = nt_num_arrs(nt, id), room = nr + 3;
    for (int i = 0; i < na; i++) { int m = 0; nt_arr_at(nt, id, i, &m); room += m; }
    if (sp + room >= cap) {
      while (sp + room >= cap) cap *= 2;
      stk = realloc(stk, sizeof(CwItem) * (size_t)cap);
      if (!stk) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
    }
    if (k == NK_ClassNode || k == NK_ModuleNode || k == NK_SingletonClassNode) {
      int nc = cw_cref_name(w, id, cur);
      if (nc >= 0) { stk[sp++] = (CwItem){ cur, CW_LEAVE }; cur = nc; }
    }
    if (k == NK_ConstantWriteNode || k == NK_ConstantPathWriteNode || k == NK_MultiWriteNode)
      stk[sp++] = (CwItem){ id, CW_DONE };
    for (int i = na - 1; i >= 0; i--) {
      int m = 0; const int *ids = nt_arr_at(nt, id, i, &m);
      for (int j = m - 1; j >= 0; j--) if (ids[j] >= 0) stk[sp++] = (CwItem){ ids[j], CW_VISIT };
    }
    int tgt = k == NK_ConstantPathWriteNode || k == NK_ConstantPathOrWriteNode || k == NK_ConstantPathAndWriteNode ||
              k == NK_ConstantPathOperatorWriteNode ? nt_ref(nt, id, "target") : -1;
    for (int i = nr - 1; i >= 0; i--) {
      int ch = nt_ref_at(nt, id, i);
      /* the target of a path assignment is no read of the constant, its receiver is one */
      if (ch >= 0 && ch == tgt) ch = nt_ref(nt, ch, "parent");
      if (ch >= 0) stk[sp++] = (CwItem){ ch, CW_VISIT };
    }
  }
  free(stk);
}

/* The constant an assignment node writes, by name, and whether it is the
   plain kind a body statement can be (ConstantWriteNode, a constant target
   of a multiple assignment, a path write). NULL for a node that writes none. */
static const char *cw_write_name(const NodeTable *nt, int id) {
  switch (nt_kind(nt, id)) {
    case NK_ConstantWriteNode: case NK_ConstantTargetNode: case NK_ConstantOrWriteNode:
    case NK_ConstantAndWriteNode: case NK_ConstantOperatorWriteNode: case NK_ConstantPathTargetNode:
      return nt_str(nt, id, "name");
    case NK_ConstantPathWriteNode: case NK_ConstantPathOrWriteNode: case NK_ConstantPathAndWriteNode:
    case NK_ConstantPathOperatorWriteNode: {
      int tgt = nt_ref(nt, id, "target");
      return tgt >= 0 ? nt_str(nt, tgt, "name") : NULL;
    }
    case NK_CallNode: {
      const char *cn = nt_str(nt, id, "name");
      return cn && is_const_set_name(cn) ? cw_read_name(nt, id) : NULL;
    }
    default:
      return NULL;
  }
}

/* Mark the constants some assignment can follow a read of: LocalVar.const_early
   (see the header comment). */
void an_const_presence(Compiler *c) {
  const NodeTable *nt = c->nt;
  ConstWalk w = { .c = c, .nt = nt, .clean = 1, .listed = INT_MAX };
  size_t nn = (size_t)(nt->count > 0 ? nt->count : 1), nc = (size_t)(c->nconsts > 0 ? c->nconsts : 1);
  w.settled = calloc(nn, 1);
  w.direct = calloc(nn, 1);
  w.wpost = calloc(nn, sizeof(int));
  w.pre = calloc(nn, sizeof(int));
  w.cref_at = calloc(nn, sizeof(int));
  w.seen = calloc(nc, 1);
  w.plain = calloc(nc, 1);
  w.rd = malloc(nc * sizeof(int));
  int *first = calloc(nc, sizeof(int));   /* per constant: its earliest plain assignment's node + 1 */
  if (!w.settled || !w.direct || !w.wpost || !w.pre || !w.cref_at || !w.seen || !w.plain || !w.rd || !first) {
    fprintf(stderr, "spinel: out of memory\n"); exit(1);
  }
  for (size_t i = 0; i < nc; i++) w.rd[i] = INT_MAX;
  for (int id = 0; id < nt->count; id++) {
    NodeKind k = nt_kind(nt, id);
    if (k == NK_DefNode) {
      const char *dn = nt_str(nt, id, "name");
      if (dn && is_definition_hook_name(dn)) w.hooks = 1;
      if (dn && is_const_missing_name(dn)) w.cmissing = 1;
    }
    else if (k == NK_ClassNode || k == NK_ModuleNode) {
      int cp = nt_ref(nt, id, "constant_path");
      const char *cn = cp >= 0 ? nt_str(nt, cp, "name") : NULL;
      if (cn && (is_builtin_class_name(cn) || is_builtin_reopen_name(cn))) w.reopened = 1;
    }
  }
  cw_stmts(&w, nt_ref(nt, nt->root_id, "statements"), 0);
  cw_order(&w);
  /* The first plain assignment of each constant, in program order. Any other
     assignment of it (inside a branch or a method, the forms that read it
     first, const_set) leaves it early only if it can come before that one. */
  for (int id = 0; id < nt->count; id++) {
    const char *nm = cw_write_name(nt, id);
    LocalVar *lv = nm ? comp_const(c, nm) : NULL;
    if (!lv || !w.direct[id]) continue;
    int i = cw_index(&w, lv);
    if (!first[i] || w.wpost[id] < w.wpost[first[i] - 1]) first[i] = id + 1;
  }
  for (int id = 0; id < nt->count; id++) {
    const char *nm = cw_write_name(nt, id);
    LocalVar *lv = nm ? comp_const(c, nm) : NULL;
    if (!lv || w.direct[id]) continue;
    int i = cw_index(&w, lv);
    if (!first[i] || w.pre[id] < w.wpost[first[i] - 1]) lv->const_early = 1;
  }
  for (int i = 0; i < c->nconsts; i++) {
    if (!first[i] || c->consts[i].const_early) continue;
    int wr = first[i] - 1;
    if (!w.settled[wr] && (w.rd[i] < w.wpost[wr] || w.listed < w.wpost[wr])) c->consts[i].const_early = 1;
  }
  /* A name that is also a class's (an alias `Key = Impl::Key`) is one slot of
     the flat table for the value and the class, and a read of the class must
     not wait for the value. A program that defines const_missing gets the
     answers master gave: spinel does not call it, so the NameError a flag
     raises would be the wrong one. */
  for (int i = 0; i < c->nconsts; i++)
    if (c->consts[i].const_early && (w.cmissing || comp_class_index(c, c->consts[i].name) >= 0))
      c->consts[i].const_early = 0;
  /* the name a flagged read shows ahead of the constant: "" at the top level */
  for (int id = 0; id < nt->count; id++) {
    if (nt_kind(nt, id) != NK_ConstantReadNode || !w.pre[id]) continue;
    LocalVar *lv = comp_const(c, nt_str(nt, id, "name"));
    if (lv && lv->const_early)
      nt_node_set_str((NodeTable *)nt, id, "const_cref", w.cref_at[id] ? w.crefs[w.cref_at[id] - 1] : "");
  }
  for (int i = 0; i < w.ncrefs; i++) free(w.crefs[i]);
  free(w.crefs);
  free(w.settled); free(w.direct); free(w.wpost); free(w.pre); free(w.cref_at);
  free(w.seen); free(w.plain); free(w.rd); free(first);
}
