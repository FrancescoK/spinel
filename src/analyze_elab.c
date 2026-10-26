/* analyze_elab.c -- the load-phase elaborator's record (#9898).

   CRuby builds a program's classes by running its load phase: the files in
   load order, each file's statements in order, and class bodies as they
   run. The record says where in that phase each statement runs, so that a
   question of order ("was this defined before that call?") is read from it
   rather than from node ids, which are a file's own order only.

   A point is (region, seq). Region 0 is the load phase the load graph
   places (#10305): the entry, and each file at the statement that first
   loads it (prog_ordered_load). Each file it does not place (one loaded
   under a condition, in a method or a block, or by a computed path) has a
   region of its own after them, whose points order among themselves and
   against any other region are UNKNOWN. seq counts the statements in the
   order they run. The walk:
     - enters a file at its load: its root's point, its BEGIN blocks, then
       its statements;
     - enters the bodies that run where they stand: class, module and
       `class << x` bodies, BEGIN blocks, and the blocks the load phase runs
       at once (class_eval and the other eval and exec forms, tap,
       Class.new, Module.new, Struct.new, Data.define);
     - enters the branches of a condition, a loop or a rescue, whose
       statements may not run: their points are `may`;
     - does not enter method bodies, lambdas and other blocks, which run
       when they are called: elab_point_of answers no point there.
   Any other node takes the point of its nearest walked statement.

   The map is a function of the tree as it stands, rebuilt when the node
   table changes, as the parent map is: the readers ask the order ahead of
   the scope walk (the builtins/ per-call-site copies) and after it, of
   nodes later passes add. Under --load-model=inline the walk is the same
   over the one program text, so a statement a desugaring placed mid-body
   has its point there, whatever its id.

   prog_order and prog_sort read the map (analyze_program.c), by the rank of
   the top-level statement holding each node and node ids within one, which
   is the order they gave before the map. SPINEL_ELAB_CHECK=1 compares each
   of their answers with the full points' (elab_order) and reports where the
   two differ. */

#include "analyze_internal.h"
#include "builtin_names.h"
#include "timing.h"
#include <limits.h>

int g_dump_load_record = 0;

/* One walked statement. top is the index of the top-level statement (or
   file root) holding it, and rank, on that one, its place in the order
   prog_order reads: each file's statements in their list order, a placed
   file's right after its load (a BEGIN block keeps its place in the list
   there; the walk runs it first). -1 outside region 0. */
typedef struct { int node, file, region, top, rank, depth; unsigned char may; } LrStmt;

/* The order questions SPINEL_ELAB_CHECK counts, by reader */
typedef struct { const char *reader; long asked, differ; } LrCheck;
enum { LR_CHECK_MAX = 16, LR_CHECK_SHOW = 100 };

enum { LR_LATE = 1,   /* runs later: in a method body, a lambda or a block that is not run at once */
       LR_NOW = 2 };  /* a block the load phase runs where it stands */

struct LoadRecord {
  LrStmt *st; int nst, cst;  /* the walked statements, in the order they run: seq is the index */
  int *at;                   /* [n] each node's statement; -1 under no file's root */
  unsigned char *bits;       /* [n] LR_* */
  int n, nregion;
  unsigned ver;              /* the node table the map is of */
  int check, shown;
  LrCheck fam[LR_CHECK_MAX];
  double ms; int builds;
};

static LoadRecord *lr_get(Compiler *c) {
  if (!c->lrec) {
    c->lrec = calloc(1, sizeof *c->lrec);
    if (!c->lrec) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
    const char *e = getenv("SPINEL_ELAB_CHECK");
    c->lrec->check = e && *e && *e != '0';
  }
  return c->lrec;
}

typedef struct { Compiler *c; LoadRecord *r; unsigned char *entered; int region, rank; } ElabWalk;

static int lr_add(ElabWalk *w, int node, int file, int top, int may, int depth) {
  LoadRecord *r = w->r;
  if (r->nst == r->cst) {
    r->cst = r->cst ? r->cst * 2 : 256;
    r->st = realloc(r->st, sizeof *r->st * (size_t)r->cst);
    if (!r->st) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  }
  int k = r->nst++;
  r->st[k] = (LrStmt){ node, file, w->region, top < 0 ? k : top, -1, depth, (unsigned char)may };
  r->at[node] = k;
  return k;
}

static void elab_inner(ElabWalk *w, int s, int file, int top, int may, int depth);

/* The statements of a body that runs here: a statement list, or a body
   with rescue clauses (a BeginNode), whose parts elab_inner walks. */
static void elab_body(ElabWalk *w, int body, int file, int top, int may, int depth) {
  const NodeTable *nt = w->c->nt;
  if (body < 0) return;
  if (nt_kind(nt, body) == NK_BeginNode) { elab_inner(w, body, file, top, may, depth); return; }
  int n = 1;
  const int *v = &body;   /* a body of one expression is its one statement */
  if (nt_kind(nt, body) == NK_StatementsNode) v = nt_arr(nt, body, "body", &n);
  for (int k = 0; k < n; k++) {
    if (v[k] < 0 || w->r->at[v[k]] != -2) continue;   /* a subtree two lists share: once */
    lr_add(w, v[k], file, top, may, depth);
    elab_inner(w, v[k], file, top, may, depth);
  }
}

/* A block the load phase runs where it stands: class_eval and kin, tap,
   and a class builder's (`Class.new(B) do`, `Struct.new(:a) do`). Its
   receiver does not matter: each runs its block before it answers. */
static int elab_runs_block_now(const NodeTable *nt, int call) {
  const char *nm = nt_str(nt, call, "name");
  int rv = nt_ref(nt, call, "receiver");
  const char *rn = rv >= 0 && nt_kind(nt, rv) == NK_ConstantReadNode ? nt_str(nt, rv, "name") : NULL;
  return nm && (is_eval_exec_family(nm) || is_tap_name(nm) || is_class_builder(rn, nm));
}

/* The bodies inside statement s that run while s does. */
static void elab_inner(ElabWalk *w, int s, int file, int top, int may, int depth) {
  const NodeTable *nt = w->c->nt;
  switch (nt_kind(nt, s)) {
    case NK_ClassNode: case NK_ModuleNode: case NK_SingletonClassNode:
      elab_body(w, nt_ref(nt, s, "body"), file, top, may, depth + 1);
      break;
    case NK_PreExecutionNode:
      elab_body(w, nt_ref(nt, s, "statements"), file, top, may, depth + 1);
      break;
    case NK_ParenthesesNode:
      elab_body(w, nt_ref(nt, s, "body"), file, top, may, depth + 1);
      break;
    case NK_IfNode: case NK_UnlessNode: {   /* an elsif ladder as a loop */
      int b = s;
      while (b >= 0 && (nt_kind(nt, b) == NK_IfNode || nt_kind(nt, b) == NK_UnlessNode)) {
        elab_body(w, nt_ref(nt, b, "statements"), file, top, 1, depth + 1);
        b = nt_kind(nt, b) == NK_IfNode ? nt_ref(nt, b, "subsequent") : nt_ref(nt, b, "else_clause");
      }
      if (b >= 0) elab_body(w, nt_ref(nt, b, "statements"), file, top, 1, depth + 1);
      break;
    }
    case NK_CaseNode: case NK_CaseMatchNode: {
      int n = 0;
      const int *v = nt_arr(nt, s, "conditions", &n);
      for (int k = 0; k < n; k++) elab_body(w, nt_ref(nt, v[k], "statements"), file, top, 1, depth + 1);
      int e = nt_ref(nt, s, "else_clause");
      if (e >= 0) elab_body(w, nt_ref(nt, e, "statements"), file, top, 1, depth + 1);
      break;
    }
    case NK_WhileNode: case NK_UntilNode: case NK_ForNode:
      elab_body(w, nt_ref(nt, s, "statements"), file, top, 1, depth + 1);
      break;
    case NK_BeginNode: {
      elab_body(w, nt_ref(nt, s, "statements"), file, top, may, depth + 1);
      for (int r = nt_ref(nt, s, "rescue_clause"); r >= 0; r = nt_ref(nt, r, "subsequent"))
        elab_body(w, nt_ref(nt, r, "statements"), file, top, 1, depth + 1);
      int e = nt_ref(nt, s, "else_clause"), en = nt_ref(nt, s, "ensure_clause");
      if (e >= 0) elab_body(w, nt_ref(nt, e, "statements"), file, top, 1, depth + 1);
      if (en >= 0) elab_body(w, nt_ref(nt, en, "statements"), file, top, may, depth + 1);
      break;
    }
    case NK_ConstantWriteNode: case NK_ConstantPathWriteNode: case NK_LocalVariableWriteNode:
    case NK_InstanceVariableWriteNode: case NK_GlobalVariableWriteNode: case NK_ClassVariableWriteNode: {
      int v = nt_ref(nt, s, "value");   /* `X = Class.new(B) do ... end` */
      if (v >= 0 && nt_kind(nt, v) == NK_CallNode) elab_inner(w, v, file, top, may, depth);
      break;
    }
    case NK_CallNode: {
      int b = nt_ref(nt, s, "block");
      if (b < 0 || nt_kind(nt, b) != NK_BlockNode || !elab_runs_block_now(nt, s)) break;
      w->r->bits[b] |= LR_NOW;
      elab_body(w, nt_ref(nt, b, "body"), file, top, may, depth + 1);
      break;
    }
    default: break;
  }
}

/* File f's top level, entered at its load: its root, its BEGIN blocks (run
   first, when the file loads), then its statements, each placed file right
   after the statement that loads it. */
static void elab_file(ElabWalk *w, int f) {
  const Compiler *c = w->c;
  const NodeTable *nt = c->nt;
  int root = nt_root(nt, f), st = prog_root_stmts(c, f), n = 0;
  w->entered[f] = 1;
  if (root < 0 || w->r->at[root] != -2) return;
  int e = lr_add(w, root, f, -1, 0, 0);
  w->r->st[e].rank = w->region == 0 ? w->rank++ : -1;
  if (st >= 0) w->r->at[st] = e;
  const int *v = st >= 0 ? nt_arr(nt, st, "body", &n) : NULL;
  for (int k = 0; k < n; k++)
    if (v[k] >= 0 && nt_kind(nt, v[k]) == NK_PreExecutionNode && w->r->at[v[k]] == -2) {
      int b = lr_add(w, v[k], f, -1, 0, 0);
      elab_inner(w, v[k], f, b, 0, 0);
    }
  for (int k = 0; k < n; k++) {
    if (v[k] < 0) continue;
    int s = w->r->at[v[k]];
    if (nt_kind(nt, v[k]) != NK_PreExecutionNode) {
      if (s != -2) continue;
      s = lr_add(w, v[k], f, -1, 0, 0);
      elab_inner(w, v[k], f, s, 0, 0);
    }
    if (s >= 0 && w->r->st[s].top == s) w->r->st[s].rank = w->region == 0 ? w->rank++ : -1;
    int t = prog_ordered_load(c, v[k]);
    if (t >= 0 && !w->entered[t]) elab_file(w, t);
  }
}

/* Is a node under parent p one that runs later than p's statement: under
   a method, a lambda, or a block that is not run where it stands? */
static int lr_defers(const NodeTable *nt, int p, unsigned char bits) {
  NodeKind k = nt_kind(nt, p);
  return k == NK_DefNode || k == NK_LambdaNode || (k == NK_BlockNode && !(bits & LR_NOW));
}

static void elab_points_build(Compiler *c) {
  double t0 = sp_timing_now();
  LoadRecord *r = lr_get(c);
  const NodeTable *nt = c->nt;
  const int *par = comp_parent_map(c);
  int n = nt->count, nroots = nt_nroots(nt);
  free(r->at); free(r->bits);
  r->at = malloc(sizeof(int) * (size_t)(n ? n : 1));
  r->bits = calloc((size_t)(n ? n : 1), 1);
  int *stack = malloc(sizeof(int) * (size_t)(n ? n : 1));
  ElabWalk w = { c, r, calloc((size_t)nroots, 1), 0, 0 };
  if (!r->at || !r->bits || !stack || !w.entered) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  for (int id = 0; id < n; id++) r->at[id] = -2;
  r->nst = 0; r->n = n; r->ver = nt->version; r->nregion = 1;
  elab_file(&w, 0);
  for (int f = 1; f < nroots; f++)   /* the files no load places, a region each */
    if (!w.entered[f] && nt_root(nt, f) >= 0) { w.region = r->nregion++; elab_file(&w, f); }
  for (int id = 0; id < n; id++) {   /* the rest from their nearest walked statement */
    int s = 0, a = id;
    while (r->at[a] == -2 && par[a] >= 0) { stack[s++] = a; a = par[a]; }
    if (r->at[a] == -2) r->at[a] = -1;
    while (s > 0) {
      int b = stack[--s], p = par[b];
      r->at[b] = r->at[p];
      if ((r->bits[p] & LR_LATE) || lr_defers(nt, p, r->bits[p])) r->bits[b] |= LR_LATE;
    }
  }
  free(stack); free(w.entered);
  r->builds++;
  if (sp_timing_on()) r->ms += sp_timing_now() - t0;
}

static LoadRecord *elab_fresh(Compiler *c) {
  LoadRecord *r = lr_get(c);
  if (!r->at || r->n != c->nt->count || r->ver != c->nt->version) elab_points_build(c);
  return r;
}

/* The point at which node's statement runs; region -1 (no point) for a
   node in a method body, a lambda or a block run later, or under no file. */
LoadPoint elab_point_of(Compiler *c, int node) {
  LoadRecord *r = elab_fresh(c);
  int e = node >= 0 && node < r->n ? r->at[node] : -1;
  if (e < 0 || (r->bits[node] & LR_LATE)) return (LoadPoint){ -1, -1 };
  return (LoadPoint){ r->st[e].region, e };
}

/* Does node's statement run only under a condition (a branch, a loop body,
   a rescue clause)? */
int elab_point_may(Compiler *c, int node) {
  LoadRecord *r = elab_fresh(c);
  int e = node >= 0 && node < r->n ? r->at[node] : -1;
  return e >= 0 && r->st[e].may;
}

/* PROG_BEFORE / AFTER / SAME, or UNKNOWN for two regions or no point. */
int elab_cmp(LoadPoint a, LoadPoint b) {
  if (a.region < 0 || b.region < 0 || a.region != b.region) return PROG_UNKNOWN;
  return a.seq == b.seq ? PROG_SAME : a.seq < b.seq ? PROG_BEFORE : PROG_AFTER;
}

/* The place prog_order reads (analyze_program.c): node's file (-1 under no
   file's root) and the rank of the top-level statement holding it (-1 in a
   file the load graph does not place). */
void elab_top_place(Compiler *c, int node, int *file, int *rank) {
  LoadRecord *r = elab_fresh(c);
  int e = node >= 0 && node < r->n ? r->at[node] : -1;
  *file = e >= 0 ? r->st[e].file : -1;
  *rank = e >= 0 && r->st[e].region == 0 ? r->st[r->st[e].top].rank : -1;
}

/* The record's order of two nodes: by the points of their statements
   (a method body's nodes at its def's), node ids within one statement. */
int elab_order(Compiler *c, int a, int b) {
  if (a == b) return PROG_SAME;
  LoadRecord *r = elab_fresh(c);
  int ea = a >= 0 && a < r->n ? r->at[a] : -1, eb = b >= 0 && b < r->n ? r->at[b] : -1;
  if (ea < 0 || eb < 0 || ea == eb) return a < b ? PROG_BEFORE : PROG_AFTER;
  if (r->st[ea].region != r->st[eb].region) return PROG_UNKNOWN;
  return ea < eb ? PROG_BEFORE : PROG_AFTER;
}

/* prog_sort's key in the record's order: the statement's seq, a node
   under no file last. */
long long elab_sort_key(Compiler *c, int node) {
  LoadRecord *r = elab_fresh(c);
  int e = node >= 0 && node < r->n ? r->at[node] : -1;
  return ((long long)(e >= 0 ? e : INT_MAX) << 32) | (unsigned)node;
}

/* ---- SPINEL_ELAB_CHECK ---- */
int elab_check_on(Compiler *c) { return lr_get(c)->check; }

static LrCheck *lr_family(LoadRecord *r, const char *reader) {
  for (int i = 0; i < LR_CHECK_MAX; i++) {
    if (!r->fam[i].reader) r->fam[i].reader = reader;
    if (r->fam[i].reader == reader || sp_streq(r->fam[i].reader, reader)) return &r->fam[i];
  }
  return &r->fam[LR_CHECK_MAX - 1];
}

static const char *lr_order_name(int o) {
  return o == PROG_BEFORE ? "before" : o == PROG_AFTER ? "after" : o == PROG_SAME ? "same" : "unknown";
}

static void lr_node_desc(Compiler *c, int id, char *buf, size_t sz) {
  const NodeTable *nt = c->nt;
  if (id < 0 || id >= nt->count) { snprintf(buf, sz, "%d", id); return; }
  snprintf(buf, sz, "%d(%s line %d file %d)", id, nt_type(nt, id), (int)nt_int(nt, id, "node_line", 0),
           (int)nt_int(nt, id, "node_file", 0));
}

/* prog_order answered `now` for (a, b), asked by `reader` */
void elab_check_order(Compiler *c, const char *reader, int a, int b, int now) {
  LoadRecord *r = lr_get(c);
  int rec = elab_order(c, a, b);
  LrCheck *f = lr_family(r, reader);
  f->asked++;
  if (rec == now) return;
  f->differ++;
  if (r->shown++ >= LR_CHECK_SHOW) return;
  char da[96], db[96];
  lr_node_desc(c, a, da, sizeof da); lr_node_desc(c, b, db, sizeof db);
  fprintf(stderr, "spinel-elab-check: order reader=\"%s\" a=%s b=%s now=%s record=%s\n",
          reader, da, db, lr_order_name(now), lr_order_name(rec));
}

/* prog_sort put the nodes of v in the order `now`; the record's is `rec` */
void elab_check_sort(Compiler *c, const int *now, const int *rec, int n, const int *node_of) {
  LoadRecord *r = lr_get(c);
  LrCheck *f = lr_family(r, "prog_sort");
  int moved = 0, first = -1;
  for (int i = 0; i < n; i++) if (now[i] != rec[i]) { moved++; if (first < 0) first = i; }
  f->asked++;
  if (!moved) return;
  f->differ++;
  if (r->shown++ >= LR_CHECK_SHOW) return;
  char da[96], db[96];
  lr_node_desc(c, node_of ? node_of[now[first]] : now[first], da, sizeof da);
  lr_node_desc(c, node_of ? node_of[rec[first]] : rec[first], db, sizeof db);
  fprintf(stderr, "spinel-elab-check: sort n=%d moved=%d at=%d now=%s record=%s\n", n, moved, first, da, db);
}

/* ---- --dump-load-record ---- */
void elab_dump(Compiler *c, FILE *out) {
  LoadRecord *r = elab_fresh(c);
  const NodeTable *nt = c->nt;
  fprintf(out, "load record: %d points, %d regions\n", r->nst, r->nregion);
  for (int e = 0; e < r->nst; e++) {
    const LrStmt *s = &r->st[e];
    int cp = nt_ref(nt, s->node, "constant_path");
    const char *nm = cp >= 0 ? nt_str(nt, cp, "name") : nt_str(nt, s->node, "name");
    fprintf(out, "%*sr%d #%d%s f%d %s%s%s line %d\n", 2 * s->depth, "", s->region, e, s->may ? " may" : "",
            s->file, nt_type(nt, s->node), nm ? " " : "", nm ? nm : "", (int)nt_int(nt, s->node, "node_line", 0));
  }
}

void elab_free(Compiler *c) {
  LoadRecord *r = c->lrec;
  if (!r) return;
  if (r->builds && sp_timing_on()) {
    char extra[64];
    snprintf(extra, sizeof extra, " builds=%d", r->builds);
    sp_timing_end(sp_timing_now() - r->ms, "an_elab_points", extra);
  }
  for (int i = 0; r->check && i < LR_CHECK_MAX && r->fam[i].reader; i++)
    fprintf(stderr, "spinel-elab-check: family=\"%s\" asked=%ld differ=%ld\n", r->fam[i].reader, r->fam[i].asked, r->fam[i].differ);
  free(r->st); free(r->at); free(r->bits); free(r);
  c->lrec = NULL;
}
