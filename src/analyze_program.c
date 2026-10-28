/* analyze_program.c -- the program's files and their load order.

   Under --load-model=graph (#9898, CRuby's load model) each file the program
   loads is a root of the node table (nt_root; the entry's is the table's
   root) and each require a LoadNode naming the file it loads
   (`target_file`). A file's top level is a body of its own, run when the
   file is first required, and its locals are its own; `self` there is main,
   one object for the whole program. This module owns the files:

     - one top-level scope per file, shaped as main's (no name, no def, no
       class: the Toplevel), whose walk registers the file's classes, methods
       and locals (prog_file_scopes; the load record walks them, elab_program);
     - which scopes are a file's top level (prog_is_top_scope) and which
       nodes a file's root or its statements (prog_is_root*);
     - which files the program runs (prog_settle_files: one no live
       require reaches is taken out) and which have a function of their own
       when loaded (prog_file_tops);
     - the program's top-level statements in load order (prog_top_stmts):
       a load at the top level runs its file's top level there, once; and
       with them the files no load there places (prog_visit_files);
     - what the program refuses for now: a require that resolves to no file
       at compile time, an autoload (prog_refuse_loads), and the statements the readers of the top level
       in order would have to place across a load (prog_refuse_order). */

#include "analyze_internal.h"
#include "builtin_names.h"
#include <limits.h>

static int prog_graph(const Compiler *c) { return c->nt->nfile_roots > 0; }
/* Is the program its files (--load-model=graph), each a root? */
int prog_has_files(const Compiler *c) { return prog_graph(c); }

int prog_root_stmts(const Compiler *c, int i) {
  int r = nt_root(c->nt, i);
  return r >= 0 ? nt_ref(c->nt, r, "statements") : -1;
}

/* Is node id a file's root (its ProgramNode)? */
int prog_is_root(const Compiler *c, int id) {
  if (id < 0 || nt_kind(c->nt, id) != NK_ProgramNode) return 0;
  for (int i = 0; i < nt_nroots(c->nt); i++) if (nt_root(c->nt, i) == id) return 1;
  return 0;
}

/* Is node st a file's top-level statement list? */
int prog_is_root_stmts(const Compiler *c, int st) {
  if (st < 0 || nt_kind(c->nt, st) != NK_StatementsNode) return 0;
  for (int i = 0; i < nt_nroots(c->nt); i++) if (prog_root_stmts(c, i) == st) return 1;
  return 0;
}

/* Is `s` a file's top level: main's (scope 0) or a required file's? The
   required files' scopes are made one after another (prog_file_scopes). */
int prog_is_top_scope(const Compiler *c, const Scope *s) {
  int i = (int)(s - c->scopes), n = nt_nroots(c->nt);
  return i == 0 || (prog_graph(c) && n > 1 && i >= c->file_scope[1] && i <= c->file_scope[n - 1]);
}

/* A required file's top-level scope, after main's (scope 0). */
void prog_file_scopes(Compiler *c) {
  int n = nt_nroots(c->nt);
  c->file_scope = calloc((size_t)n, sizeof(int));
  if (!c->file_scope) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  for (int i = 1; prog_graph(c) && i < n; i++) {
    Scope *s = comp_scope_new(c, NULL, -1);
    { s->body = prog_root_stmts(c, i); comp_touch_scope(s->idx); }
    c->file_scope[i] = c->nscopes - 1;
  }
}

/* The LoadNode that first runs file f's top level, in the load order the
   parse's load graph decides (#10305): the `load_by` its root carries. -1
   for the entry and for a file the parse does not place (one another
   require may run first: under a condition, in a method, block or class
   body, in a value, or any file once a require's path is computed at run
   time). */
static int prog_load_by(const Compiler *c, int f) {
  const NodeTable *nt = c->nt;
  int r = f > 0 && f < nt->nfile_roots ? nt_root(nt, f) : -1;
  return r >= 0 ? (int)nt_int(nt, r, "load_by", -1) : -1;
}

/* The file a load at the top level runs: the target of the LoadNode that
   first runs it (prog_load_by), else -1. Its file's statements come next in
   load order. */
int prog_ordered_load(const Compiler *c, int id) {
  const NodeTable *nt = c->nt;
  if (id < 0 || nt_kind(nt, id) != NK_LoadNode) return -1;
  int f = (int)nt_int(nt, id, "target_file", -1);
  return f > 0 && prog_load_by(c, f) == id ? f : -1;
}

/* The file a require that is not a statement of a file's top level runs:
   the target of the LoadNode prog_settle_files placed at its site, else -1.
   The record enters it where it reaches the require, so that the file's
   statements run in place, as the inline model splices them; the top-level
   statement holding the require is the root's `load_stmt`. */
int prog_site_places(const Compiler *c, int id) {
  const NodeTable *nt = c->nt;
  if (id < 0 || nt_kind(nt, id) != NK_LoadNode) return -1;
  int f = (int)nt_int(nt, id, "target_file", -1);
  int r = f > 0 && f < nt->nfile_roots ? nt_root(nt, f) : -1;
  return r >= 0 && prog_load_by(c, f) == id && nt_int(nt, r, "load_stmt", -1) >= 0 ? f : -1;
}

/* The files a require whose path is computed when it runs may name (`how`
   set): candidate k's file when the parse knows them, or any file of the
   program (open). */
int prog_load_ncand(const NodeTable *nt, int load) {
  return is_load_how_set(nt_str(nt, load, "how")) ? (int)nt_int(nt, load, "ncand", 0) : 0;
}
int prog_load_cand(const NodeTable *nt, int load, int k) {
  char key[32];
  snprintf(key, sizeof key, "cand_%d", k);
  return (int)nt_int(nt, load, key, -1);
}
int prog_load_open(const NodeTable *nt, int load) {
  return is_load_how_set(nt_str(nt, load, "how")) && nt_int(nt, load, "open", 0);
}
/* Does the program need the run-time $LOAD_PATH to start as CRuby's does
   (sp_load_path_seed)? Under --load-model=graph (the entry's root carries the
   directories), where it has a require of a set of files, which searches the
   array, or reads it. A program writes none of $LOAD_PATH's names (refused). */
int prog_load_path_seeded(const NodeTable *nt) {
  if (!nt_str(nt, nt_root(nt, 0), "load_root")) return 0;
  NT_FOREACH_KIND(nt, NK_LoadNode, id)
    if (is_load_how_set(nt_str(nt, id, "how"))) return 1;
  NT_FOREACH_KIND(nt, NK_GlobalVariableReadNode, id)
    if (is_load_path_global(nt_str(nt, id, "name"))) return 1;
  return 0;
}

/* The program's top-level statements in load order: the entry's, and after
   the statement that first loads a file at the top level (prog_ordered_load)
   that file's. A file loaded only elsewhere -- in a method, or a block kept to
   run later -- has no place in this order. Each statement
   comes with the file whose top level holds it. */
typedef void (*ProgStmtFn)(void *ud, int stmt, int file);
/* ...and after a statement holding a require that places a file
   (prog_site_places), that file's too; pl lists those files in the order
   their requires stand */
typedef struct { int *f, n; } ProgPlaced;
static void prog_top_walk(const Compiler *c, int f, ProgStmtFn fn, void *ud, const ProgPlaced *pl) {
  int st = prog_root_stmts(c, f), n = 0;
  const int *v = st >= 0 ? nt_arr(c->nt, st, "body", &n) : NULL;
  for (int k = 0; k < n; k++) {
    fn(ud, v[k], f);
    int t = prog_ordered_load(c, v[k]);
    if (t >= 0) prog_top_walk(c, t, fn, ud, pl);
    for (int i = 0; i < pl->n; i++)
      if (nt_int(c->nt, nt_root(c->nt, pl->f[i]), "load_stmt", -1) == v[k]) prog_top_walk(c, pl->f[i], fn, ud, pl);
  }
}
static void prog_top_from(const Compiler *c, ProgStmtFn fn, void *ud) {
  ProgPlaced pl = { NULL, 0 };
  for (int f = 1; f < nt_nroots(c->nt); f++)
    if (nt_root(c->nt, f) >= 0 && nt_int(c->nt, nt_root(c->nt, f), "load_stmt", -1) >= 0) pl.n++;
  if (pl.n) {
    pl.f = malloc(sizeof(int) * (size_t)pl.n);
    if (!pl.f) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
    int m = 0;
    for (int f = 1; f < nt_nroots(c->nt); f++)
      if (nt_root(c->nt, f) >= 0 && nt_int(c->nt, nt_root(c->nt, f), "load_stmt", -1) >= 0) {
        int i = m++;   /* by the require's node id: the order they stand in */
        while (i > 0 && prog_load_by(c, pl.f[i - 1]) > prog_load_by(c, f)) { pl.f[i] = pl.f[i - 1]; i--; }
        pl.f[i] = f;
      }
  }
  prog_top_walk(c, 0, fn, ud, &pl);
  free(pl.f);
}
typedef struct { void (*fn)(void *, int); void *ud; } ProgStmtOnly;
static void prog_stmt_only(void *ud, int stmt, int file) {
  (void)file;
  ProgStmtOnly *o = ud;
  o->fn(o->ud, stmt);
}
void prog_top_stmts(const Compiler *c, void (*fn)(void *ud, int stmt), void *ud) {
  ProgStmtOnly o = { fn, ud };
  prog_top_from(c, prog_stmt_only, &o);
}
/* ...as an array: the statements in load order, and in *file (when asked)
   the file each is a statement of; *n their number. The caller frees both. */
typedef struct { int *stmt, *file, n, cap; } ProgSeq;
static void prog_seq_add(void *ud, int stmt, int file) {
  ProgSeq *q = ud;
  if (q->n == q->cap) {
    q->cap = q->cap ? q->cap * 2 : 16;
    q->stmt = realloc(q->stmt, sizeof(int) * (size_t)q->cap);
    q->file = realloc(q->file, sizeof(int) * (size_t)q->cap);
    if (!q->stmt || !q->file) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  }
  q->stmt[q->n] = stmt; q->file[q->n++] = file;
}
int *prog_top_seq(const Compiler *c, int *n, int **file) {
  ProgSeq q = { NULL, NULL, 0, 0 };
  prog_top_from(c, prog_seq_add, &q);
  *n = q.n;
  if (file) *file = q.file;
  else free(q.file);
  return q.stmt;
}

/* The program's files in load order, for a pass that reads what an
   earlier statement defined: fn(ud, stmt, file) for each top-level
   statement as prog_top_seq orders them, then fn(ud, root, file) for each
   file none of them is in (one no load at the top level places, or the
   entry when it has no statement). */
void prog_visit_files(const Compiler *c, void (*fn)(void *ud, int node, int file), void *ud) {
  int n = nt_nroots(c->nt), sn = 0, *file = NULL;
  int *seq = prog_top_seq(c, &sn, &file);
  unsigned char *seen = calloc((size_t)(n > 0 ? n : 1), 1);
  if (!seen) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  for (int k = 0; k < sn; k++) { seen[file[k]] = 1; fn(ud, seq[k], file[k]); }
  for (int f = 0; f < n; f++)
    if (!seen[f] && nt_root(c->nt, f) >= 0) fn(ud, nt_root(c->nt, f), f);
  free(seen); free(seq); free(file);
}

/* ---- the program's order ----
   One order, the parse's (#10305): node ids are a file's own order (flatten
   numbers a file's nodes as it walks its tree), and between files the load
   graph's, which each placed file's root carries (prog_load_by): a file's
   top level runs at the top-level statement that first loads it, after that
   statement and before the file's next one. The load-phase record
   (analyze_elab.c) ranks the top-level statements in the order they run,
   from the entry, each file's root ranked at its entry, ahead of its
   statements; a node takes the rank of its file's top-level statement
   holding it, and node ids order only the nodes of one statement. A file
   the parse does not place (another require may run it first: one under a
   condition, in a method or a block, or any file once a require's path is
   computed at run time) runs at a time the text does not fix: its nodes
   have no rank, and against another file no order. A node under no file's
   root (one a desugaring made and hung nowhere) keeps the id order it had.
   The record's own points also order the statements inside one top-level
   statement (class bodies, the blocks run at once); prog_order does not
   read them yet, and SPINEL_ELAB_CHECK=1 reports where they would answer
   otherwise (elab_check_order). */
static int prog_order_now(Compiler *c, int a, int b) {
  if (a == b) return PROG_SAME;
  if (!prog_graph(c) || a < 0 || b < 0) return a < b ? PROG_BEFORE : PROG_AFTER;
  int fa, fb, ra, rb;
  elab_top_place(c, a, &fa, &ra);
  elab_top_place(c, b, &fb, &rb);
  if (fa < 0 || fb < 0) return a < b ? PROG_BEFORE : PROG_AFTER;
  /* two top-level statements by their ranks, in one file too: a statement
     the parse or a desugaring put in a file's list (a boot library's load
     ahead of the entry's statements) has ids past the file's own */
  if (ra >= 0 && rb >= 0 && ra != rb) return ra < rb ? PROG_BEFORE : PROG_AFTER;
  if (fa == fb) return a < b ? PROG_BEFORE : PROG_AFTER;   /* one statement's nodes, as flatten numbered them */
  /* a file a require inside the statement places runs within it: the record's order */
  if (ra >= 0 && ra == rb) return elab_order(c, a, b);
  return PROG_UNKNOWN;
}
static int prog_order_for(Compiler *c, int a, int b, const char *reader) {
  int o = prog_order_now(c, a, b);
  if (elab_check_on(c)) elab_check_order(c, reader, a, b, o);
  return o;
}
int prog_order(Compiler *c, int a, int b) { return prog_order_for(c, a, b, "prog_order"); }

/* v[0..n) sorted by key[], stably (a merge sort): key[i] is v[i]'s */
static void prog_sort_keyed(int *v, long long *key, int n) {
  long long *tkey = malloc(sizeof(long long) * (size_t)n);
  int *tmp = malloc(sizeof(int) * (size_t)n);
  if (!tkey || !tmp) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  for (int w = 1; w < n; w *= 2) {
    for (int lo = 0; lo < n; lo += 2 * w) {
      int mid = lo + w < n ? lo + w : n, hi = lo + 2 * w < n ? lo + 2 * w : n, i = lo, j = mid, k = lo;
      while (i < mid && j < hi) {
        if (key[j] < key[i]) { tkey[k] = key[j]; tmp[k++] = v[j++]; }
        else { tkey[k] = key[i]; tmp[k++] = v[i++]; }
      }
      while (i < mid) { tkey[k] = key[i]; tmp[k++] = v[i++]; }
      while (j < hi) { tkey[k] = key[j]; tmp[k++] = v[j++]; }
    }
    memcpy(v, tmp, sizeof(int) * (size_t)n);
    memcpy(key, tkey, sizeof(long long) * (size_t)n);
  }
  free(tkey); free(tmp);
}

/* Sort v[0..n) into the program's order of the nodes they stand for:
   node_of[v[i]] when node_of is given, else v[i]. By the rank of the
   top-level statement holding each node, and the nodes of one statement by
   id, as prog_order answers for two of them; a node that runs at no known
   point (one under no root, which a desugaring hung nowhere, or one of a
   file the load graph does not place) after all the others, by id, so the
   order is a total one even where prog_order answers by ids or UNKNOWN.
   Under the inline model, the node ids. */
void prog_sort(Compiler *c, int *v, int n, const int *node_of) {
  if (n < 2) return;
  long long *key = malloc(sizeof(long long) * (size_t)n);
  int *was = elab_check_on(c) ? malloc(sizeof(int) * (size_t)n) : NULL;
  if (!key || (elab_check_on(c) && !was)) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  if (was) memcpy(was, v, sizeof(int) * (size_t)n);
  for (int i = 0; i < n; i++) {
    int id = node_of ? node_of[v[i]] : v[i], f = -1, r = 0;
    if (prog_graph(c)) { elab_top_place(c, id, &f, &r); if (f < 0) r = -1; }
    key[i] = ((long long)(r >= 0 ? r : INT_MAX) << 32) | (unsigned)id;
  }
  prog_sort_keyed(v, key, n);
  /* statements of a file a require places share the rank of the statement
     holding it: within a rank, by the statement the record runs first (the
     id order above stays within one statement) */
  for (int f = 1; prog_graph(c) && f < nt_nroots(c->nt); f++) {
    if (nt_root(c->nt, f) < 0 || nt_int(c->nt, nt_root(c->nt, f), "load_stmt", -1) < 0) continue;
    for (int i = 0; i < n; i++) {
      int id = node_of ? node_of[v[i]] : v[i], fl = -1, r = 0;
      elab_top_place(c, id, &fl, &r);
      key[i] = ((long long)(fl >= 0 && r >= 0 ? r : INT_MAX) << 32) | (unsigned)(elab_sort_key(c, id) >> 32);
    }
    prog_sort_keyed(v, key, n);
    break;
  }
  if (was) {   /* SPINEL_ELAB_CHECK: the record's order of the same nodes */
    for (int i = 0; i < n; i++) key[i] = elab_sort_key(c, node_of ? node_of[was[i]] : was[i]);
    prog_sort_keyed(was, key, n);
    elab_check_sort(c, v, was, n, node_of);
    free(was);
  }
  free(key);
}

/* prog_order for a reader with no answer of its own where the order is not
   known: -1 a before b, 1 after, 0 the same node; an UNKNOWN is refused at
   node `at`, naming the reader (a file loaded at no fixed point gets one in
   part 3c). */
int prog_cmp(Compiler *c, int a, int b, int at, const char *reader) {
  int o = prog_order_for(c, a, b, reader);
  if (o == PROG_UNKNOWN) {
    char msg[256];
    snprintf(msg, sizeof msg, "--load-model=graph: %s reads the order of two files, one of them loaded at no fixed point, for now", reader);
    unsupported_feature(c, at, msg);
  }
  return o;
}

/* prog_cmp in the order the load phase runs statements, read from the
   record's points (elab_order) rather than from top-level ranks and node
   ids: a file's BEGIN blocks run ahead of its other statements, and the
   statements inside one top-level statement in the order they run. An
   alias captures the definition in effect when it runs (#3737), so the
   alias readers ask this one: a def in a BEGIN block is in effect ahead of
   an alias the file's text holds earlier. An UNKNOWN is refused at `at`,
   naming the reader, as prog_cmp does. */
int prog_cmp_run(Compiler *c, int a, int b, int at, const char *reader) {
  int o = elab_order(c, a, b);
  if (o == PROG_UNKNOWN) {
    char msg[256];
    snprintf(msg, sizeof msg, "--load-model=graph: %s reads the order of two files, one of them loaded at no fixed point, for now", reader);
    unsupported_feature(c, at, msg);
  }
  return o;
}

/* Does root i only define things -- methods, aliases, and classes or modules
   whose bodies do no more -- so that loading it runs nothing? Asked of the
   program as it stands: codegen asks it of the desugared tree. */
static int prog_defines_only_stmts(const NodeTable *nt, int st) {
  if (st < 0) return 1;
  if (nt_kind(nt, st) != NK_StatementsNode) return 0;
  int n = 0; const int *v = nt_arr(nt, st, "body", &n);
  for (int i = 0; i < n; i++) {
    NodeKind k = nt_kind(nt, v[i]);
    /* (a NilNode is what a desugaring leaves of a statement it took out:
       builtins/ files' modules, desugar_builtins) */
    if (k == NK_DefNode || k == NK_AliasMethodNode || k == NK_NilNode) continue;
    if ((k == NK_ClassNode || k == NK_ModuleNode) && nt_ref(nt, v[i], "superclass") < 0 &&
        prog_defines_only_stmts(nt, nt_ref(nt, v[i], "body"))) continue;
    return 0;
  }
  return 1;
}
int prog_defines_only(const Compiler *c, int i) {
  return prog_defines_only_stmts(c->nt, prog_root_stmts(c, i));
}

/* The root whose tree holds node id (a file's ProgramNode), or -1. */
static int prog_root_of(const Compiler *c, const int *parent, int id) {
  while (id >= 0 && parent[id] >= 0) id = parent[id];
  return prog_is_root(c, id) ? id : -1;
}

/* The nodes the program runs: those under the entry's root, and under the
   root of each file a LoadNode among them loads, as the tree has them. A
   node a fold left in a dead branch, or a file only such nodes load, is
   under none. seen[] (one byte per node) is set for them; live[] (one per
   file) for the files. A node's parent is not the way up: a statement a
   fold spliced out of a dead branch has that branch for its parent too. */
static void prog_reach(const NodeTable *nt, unsigned char *seen, unsigned char *live) {
  int n = nt_nroots(nt), top = 0;
  int *stack = malloc(sizeof(int) * ((size_t)nt->count + 1));
  if (!stack) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  live[0] = 1;
  if (nt_root(nt, 0) >= 0) { seen[nt_root(nt, 0)] = 1; stack[top++] = nt_root(nt, 0); }
  while (top > 0) {
    int id = stack[--top];
    if (nt_kind(nt, id) == NK_LoadNode) {
      int nc = prog_load_ncand(nt, id);
      for (int k = -1; k < nc; k++) {   /* its file, and a closed set's */
        int t = k < 0 ? (int)nt_int(nt, id, "target_file", -1) : prog_load_cand(nt, id, k);
        if (t > 0 && t < n && !live[t]) {
          live[t] = 1;
          if (nt_root(nt, t) >= 0 && !seen[nt_root(nt, t)]) { seen[nt_root(nt, t)] = 1; stack[top++] = nt_root(nt, t); }
        }
      }
    }
    for (int j = 0; j < nt_num_refs(nt, id); j++) {
      int ch = nt_ref_at(nt, id, j);
      if (ch >= 0 && ch < nt->count && !seen[ch]) { seen[ch] = 1; stack[top++] = ch; }
    }
    for (int j = 0; j < nt_num_arrs(nt, id); j++) {
      int an = 0; const int *ids = nt_arr_at(nt, id, j, &an);
      for (int k = 0; k < an; k++)
        if (ids[k] >= 0 && ids[k] < nt->count && !seen[ids[k]]) { seen[ids[k]] = 1; stack[top++] = ids[k]; }
    }
  }
  free(stack);
}

/* Which required files run a function of their own when loaded
   (sp_file_N_top, emit_file_tops): has[i] for each file i below nt_nroots.
   A file that does more than define things has one. One that only defines
   things has nothing to run, and a load whose value nothing reads is
   nothing; but a load that is emitted as an expression (anywhere but as a
   statement whose value nothing reads) answers whether it ran the file, once,
   so the file has its loaded flag and an empty function for that load to
   call. A load of a native library
   that stands that way as well has no file: native(ud, load) for each. */
void prog_file_tops(Compiler *c, unsigned char *has, void (*native)(void *ud, int load), void *ud) {
  const NodeTable *nt = c->nt;
  int n = nt_nroots(nt);
  for (int i = 0; i < n; i++) has[i] = i > 0 && !prog_defines_only(c, i);
  unsigned char *seen = calloc((size_t)nt->count + 1, 1), *live = calloc((size_t)n, 1);
  if (!seen || !live) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  prog_reach(nt, seen, live);
  const int *parent = comp_parent_map(c);
  NT_FOREACH_KIND(nt, NK_LoadNode, id) {
    int f = (int)nt_int(nt, id, "target_file", -1);
    /* a closed set's files run through the dispatch, each a function of its own */
    for (int k = 0; seen[id] && k < prog_load_ncand(nt, id); k++) {
      int t = prog_load_cand(nt, id, k);
      if (t > 0 && t < n) has[t] = 1;
    }
    if (seen[id] && prog_load_open(nt, id))   /* an open one: every file the program runs */
      for (int t = 1; t < n; t++) has[t] |= live[t];
    if (!seen[id] || (f > 0 && f < n && has[f]) || (f <= 0 && !native)) continue;
    int stmt = parent[id] >= 0 && nt_kind(nt, parent[id]) == NK_StatementsNode;
    if (stmt && an_node_dropped(c, id)) continue;
    if (f > 0 && f < n) has[f] = 1;
    else if (is_load_how_native(nt_str(nt, id, "how"))) native(ud, id);
  }
  free(seen); free(live);
}

/* What --load-model=graph does not load yet, refused by name (#9898), asked
   once the load sites are known, ahead of the desugaring:
     - a require of the program's own entry file, which CRuby runs again as
       a new file since `$0` is not a loaded feature;
     - an autoload: its file loads at the constant's first reference
       (part 4);
     - in a required file, an END block, registered when its statement
       runs; `class Class`, which desugar_class_reopen reads at the entry's
       top level only; and a `return` in a block at its top level, which
       ends the file's load from wherever the block runs. */
void prog_refuse_loads(Compiler *c) {
  const NodeTable *nt = c->nt;
  if (!prog_graph(c)) return;
  int *parent = an_parent_map(nt);
  if (!parent) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  for (int id = 0; id < nt->count; id++) {
    NodeKind k = nt_kind(nt, id);
    if (k == NK_CallNode) {
      const char *cn = nt_str(nt, id, "name");
      if (cn && is_autoload_name(cn) && nt_ref(nt, id, "receiver") < 0)
        unsupported_feature(c, id, "--load-model=graph loads an autoload's file at its constant's first reference only later, for now");
    }
    else if (k == NK_LoadNode) {
      if (nt_int(nt, id, "target_file", -1) == 0)
        unsupported_feature(c, id, "--load-model=graph does not load the program's own entry file again, for now");
    }
    else if (k == NK_PostExecutionNode) {
      int r = prog_root_of(c, parent, id);
      if (r >= 0 && r != nt->root_id)
        unsupported_feature(c, id, "--load-model=graph: an END block in a required file, for now");
    }
    else if (k == NK_ReturnNode) {
      /* the nearest method, lambda or block around it: a block's, at the top level */
      int a = parent[id];
      while (a >= 0 && nt_kind(nt, a) != NK_DefNode && nt_kind(nt, a) != NK_LambdaNode && nt_kind(nt, a) != NK_BlockNode)
        a = parent[a];
      int r = a >= 0 && nt_kind(nt, a) == NK_BlockNode ? prog_root_of(c, parent, id) : -1;
      for (int b = a; r >= 0 && b >= 0; b = parent[b])
        if (nt_kind(nt, b) == NK_DefNode || nt_kind(nt, b) == NK_LambdaNode) r = -1;
      if (r >= 0 && r != nt->root_id)
        unsupported_feature(c, id, "--load-model=graph: a `return` in a block at a required file's top level, for now");
    }
  }
  for (int i = 1; i < nt_nroots(nt); i++) {
    int st = prog_root_stmts(c, i), n = 0;
    const int *v = st >= 0 ? nt_arr(nt, st, "body", &n) : NULL;
    for (int k = 0; k < n; k++)
      if ((nt_kind(nt, v[k]) == NK_ClassNode || nt_kind(nt, v[k]) == NK_ModuleNode) &&
          is_class_const(nt, nt_ref(nt, v[k], "constant_path")))
        unsupported_feature(c, v[k], "--load-model=graph: `class Class` in a required file (desugar_class_reopen reads one file), for now");
  }
  free(parent);
}

/* What each file the entry reaches is loaded by, once the folds have run
   (#9898).
   - A file that no load able to run reaches is not part of the program. A
     fold of a constant condition (RUBY_VERSION, the engine checks) leaves a
     `require` in the branch it decided dead under no root's tree, and a file
     only such requires name, or only the requires of a file so dropped, is
     never loaded. The inline model splices a file at its require, so a dead
     branch takes the file along; here the file's statements are taken out
     of the tree, and nothing registers its classes, methods and constants
     (ruby_version_fold's `const_defined?`). A file named by an autoload has
     no LoadNode: it is refused (prog_refuse_loads) until its own step. One a
     computed require's closed set names is reached by that LoadNode
     (prog_load_cand), and is never placed at one site: the require may run
     it first.
   - A file the parse does not place (it has no require that is a statement
     of a top level) and that has one require in all, where the load phase's
     walk reaches it (elab_load_sites: under a condition, a loop, a rescue,
     a class body, an iterator's block, an assignment's value), is placed at
     that require: `load_by` the LoadNode, `load_stmt` the top-level
     statement holding it. The record enters it there, with the require's
     may, as the inline model splices it. Any other file keeps a region of
     its own.
   Asked after the folds, ahead of the readers of the program's order. */
typedef struct { Compiler *c; int stmt, n, open; int *nsite, *site, *at; unsigned char *ok; } ProgSites;
static void prog_site_note(void *ud, int load, int in_place) {
  ProgSites *q = ud;
  for (int k = 0; k < prog_load_ncand(q->c->nt, load); k++) {   /* a set's files: no one site places them */
    int t = prog_load_cand(q->c->nt, load, k);
    if (t > 0 && t < q->n) { q->nsite[t]++; q->ok[t] = 0; }
  }
  q->open |= prog_load_open(q->c->nt, load);
  int t = (int)nt_int(q->c->nt, load, "target_file", -1);
  if (t <= 0 || t >= q->n) return;
  q->nsite[t]++; q->site[t] = load; q->at[t] = q->stmt; q->ok[t] = (unsigned char)in_place;
}
/* The top-level statement of a file that holds node id, or -1. */
static int prog_top_stmt_of(const Compiler *c, const int *parent, int id) {
  while (id >= 0 && parent[id] >= 0 && !prog_is_root_stmts(c, parent[id])) id = parent[id];
  return id >= 0 && parent[id] >= 0 ? id : -1;
}

/* A file a computed require may name is placed at its own require only if
   that require, a statement of a top level, runs before the computed one
   does: before the top-level statement holding it, a method or block it
   stands in being made no earlier than that statement. Any other file the
   require may name could be run by it first, and has no place (a region of
   its own). A placed file whose require is no longer in the order, since
   its file lost its place, has none either. (A window that tells when a
   method can first be called would tighten this: the statement holding the
   require is the earliest it can run.) */
static void prog_unplace_candidates(Compiler *c, const unsigned char *seen, const unsigned char *live) {
  NodeTable *nt = (NodeTable *)c->nt;
  int n = nt_nroots(nt);
  int *parent = an_parent_map(nt), *pos = malloc(sizeof(int) * ((size_t)nt->count + 1));
  if (!parent || !pos) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  for (int again = 1; again; ) {
    int sn = 0, *seq = prog_top_seq(c, &sn, NULL);
    for (int i = 0; i < nt->count; i++) pos[i] = -1;
    for (int k = 0; k < sn; k++) pos[seq[k]] = k;
    free(seq);
    again = 0;
    for (int f = 1; f < n; f++) {   /* a require that is no statement of the order places nothing */
      int l = prog_load_by(c, f);
      if (l >= 0 && pos[l] < 0) { nt_node_set_int(nt, nt_root(nt, f), "load_by", -1); again = 1; }
    }
    NT_FOREACH_KIND(nt, NK_LoadNode, id) {
      int nc = prog_load_ncand(nt, id), open = prog_load_open(nt, id);
      if (!seen[id] || (!nc && !open)) continue;
      int ts = prog_top_stmt_of(c, parent, id), sp = ts >= 0 ? pos[ts] : -1;
      for (int k = 0; k < (open ? n - 1 : nc); k++) {
        int f = open ? k + 1 : prog_load_cand(nt, id, k), l = f > 0 && f < n && (open ? live[f] : 1) ? prog_load_by(c, f) : -1;
        if (l >= 0 && (sp < 0 || pos[l] > sp)) { nt_node_set_int(nt, nt_root(nt, f), "load_by", -1); again = 1; }
      }
    }
  }
  free(parent); free(pos);
}

void prog_settle_files(Compiler *c) {
  NodeTable *nt = (NodeTable *)c->nt;
  int n = nt_nroots(nt);
  if (!prog_graph(c) || n < 2) return;
  unsigned char *seen = calloc((size_t)nt->count + 1, 1), *live = calloc((size_t)n, 1), *ok = calloc((size_t)n, 1);
  int *nsite = calloc((size_t)n, sizeof(int)), *site = calloc((size_t)n, sizeof(int)), *at = calloc((size_t)n, sizeof(int));
  if (!seen || !live || !ok || !nsite || !site || !at) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  prog_reach(nt, seen, live);
  ProgSites q = { c, -1, n, 0, nsite, site, at, ok };
  for (int f = 0; f < n; f++) {
    int st = prog_root_stmts(c, f), m = 0;
    const int *v = st >= 0 && live[f] ? nt_arr(nt, st, "body", &m) : NULL;
    for (int k = 0; k < m; k++) { q.stmt = v[k]; elab_load_sites(c, v[k], prog_site_note, &q); }
  }
  if (q.open) memset(ok, 0, (size_t)n);   /* an open require may run any file first */
  prog_unplace_candidates(c, seen, live);
  for (int f = 1; f < n; f++) {
    int st = live[f] ? -1 : prog_root_stmts(c, f);
    if (st >= 0) nt_node_set_arr(nt, st, "body", NULL, 0);
    else if (live[f] && prog_load_by(c, f) < 0 && nsite[f] == 1 && ok[f]) {
      nt_node_set_int(nt, nt_root(nt, f), "load_by", site[f]);
      nt_node_set_int(nt, nt_root(nt, f), "load_stmt", at[f]);
    }
  }
  free(seen); free(live); free(ok); free(nsite); free(site); free(at);
}

/* The statements a reader of the top level in order would have to place
   across a load (part 3b), refused by name, asked just ahead of
   rename_main_singleton_defs, once the builtins/ files' modules are taken apart
   (desugar_builtins, desugar_builtin_scalar_defs). In a required file's top
   level:
     - a top-level `def self.m` (rename_main_singleton_defs);
     - `include` (qc_object_mixin_write, which runs ahead of the load
       record). */
void prog_refuse_order(Compiler *c) {
  const NodeTable *nt = c->nt;
  if (!prog_graph(c)) return;
  for (int i = 0; i < nt_nroots(nt); i++) {
    int st = prog_root_stmts(c, i), n = 0;
    const int *v = st >= 0 ? nt_arr(nt, st, "body", &n) : NULL;
    for (int k = 0; k < n; k++) {
      NodeKind sk = nt_kind(nt, v[k]);
      const char *nm = nt_str(nt, v[k], "name");
      if (i > 0 && sk == NK_DefNode && nt_ref(nt, v[k], "receiver") >= 0)
        unsupported_feature(c, v[k], "--load-model=graph: a top-level `def self.m` in a required file (rename_main_singleton_defs reads one file), for now");
      if (i > 0 && sk == NK_CallNode && nt_ref(nt, v[k], "receiver") < 0 && nm && is_include_name(nm))
        unsupported_feature(c, v[k], "--load-model=graph: a top-level include in a required file (qc_object_mixin_write reads one file), for now");
    }
  }
}
