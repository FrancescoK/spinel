/* analyze_lower.c -- the load stage's lowerings, as rows of one table.

   A lowering rewrites one surface shape into the forms the passes below it
   read (`m(&nil)` into the blockless call, `x => pat` into a one-arm case,
   `|a, (b, c)|` into a flat parameter and an assignment). Each is a row of
   `lowerings`: the step name its appended nodes are named after (nt_set_pass),
   the kinds of node it enters at, its visit, which rewrites the shape at one
   node, and its left, which says whether that shape is at a node.

   lower_run is the one loop. It visits every node below the count at its
   entry, in ascending id, the nodes no root reaches included (a pass that
   reads the whole table afterwards reads what they hold). A row appends nodes
   past that count and never visits them, as the loops it replaces did not.

   SPINEL_LOWER_CHECK=1 checks the rows instead of compiling. After each row
   it reports a node still in the row's shape, and a second run of the row
   that changes the table: a lowering that is not idempotent cannot be
   applied again to code a later pass splices in. At the end of the stage it
   reports every row's shape still present, every row that changes the table
   when the rows run once more in order. The report goes to stderr and the
   compile stops there, as it does under --dump-load-record: a second run
   perturbs the table, so no C follows. */

#include "analyze_internal.h"

enum {
  LF_MARKS = 1    /* sets marks only: no shape is eliminated, so no left */
};
enum { LW_MAX_KINDS = 6 };

typedef struct {
  const char *name;                 /* the step name (nt_set_pass) */
  unsigned flags;                   /* LF_* */
  NodeKind kinds[LW_MAX_KINDS];     /* the kinds it enters at; NK_NONE ends the list */
  LowerFn *visit;                   /* rewrites the shape at id: 1 when it did */
  LowerFn *left;                    /* the shape is at id; NULL: only a second run is checked */
  const char *shape;                /* the shape it eliminates, for the check's report */
} Lowering;

/* In the order the stage runs the rows; a row run twice (nil_block_arg) is
   one row. Where a row must come before another, the order is in the
   stage's list (an_phase_desugar_register). */
static const Lowering lowerings[LW__COUNT] = {
  [LW_NIL_BLOCK_ARG] = { "desugar_nil_block_arg", 0, { NK_CallNode },
    desugar_nil_block_arg_at, desugar_nil_block_arg_left, "`m(&nil)`" },
  [LW_PAREN_BLOCK_ARG] = { "desugar_paren_block_arg", 0, { NK_BlockArgumentNode },
    desugar_paren_block_arg_at, desugar_paren_block_arg_left, "`&(e)`: a block argument in parentheses" },
  [LW_PAREN_OPERANDS] = { "desugar_paren_operands", 0,
    { NK_CallNode, NK_LocalVariableWriteNode, NK_InstanceVariableWriteNode, NK_ClassVariableWriteNode, NK_ConstantWriteNode },
    desugar_paren_operands_at, desugar_paren_operands_left, "`(e).m`, `x = (e)`: a receiver or value in parentheses" },
  [LW_SEND_CLASS_MAKERS] = { "desugar_send_class_makers", 0, { NK_CallNode },
    desugar_send_class_makers_at, desugar_send_class_makers_left, "`Struct.send(:new, ..)`, `Data.send(:define, ..)`" },
  [LW_RESCUE_BLOCK_BODIES] = { "desugar_rescue_block_bodies", 0, { NK_BlockNode },
    desugar_rescue_block_bodies_at, desugar_rescue_block_bodies_left, "a block whose body is not a StatementsNode" },
  [LW_MARK_SYM_PROC_BLOCKS] = { "mark_sym_proc_blocks", LF_MARKS, { NK_BlockNode },
    mark_sym_proc_blocks_at, NULL, NULL },
  [LW_ERRNO_ALIASES] = { "desugar_errno_aliases", 0, { NK_ConstantPathNode },
    desugar_errno_aliases_at, desugar_errno_aliases_left, "`Errno::EWOULDBLOCK`, an alias of another errno's class" },
  [LW_PAREN_DEF_BODY] = { "desugar_paren_def_body", 0, { NK_DefNode },
    desugar_paren_def_body_at, desugar_paren_def_body_left, "`def m = (a; b)`" },
  [LW_MARK_MATCH_RANGES] = { "mark_match_ranges", LF_MARKS, { NK_WhenNode, NK_CallNode },
    mark_match_ranges_at, NULL, NULL },
  /* after mark_match_ranges: it skips a range an index call has marked */
  [LW_MARK_RANGE_LOCALS] = { "mark_match_ranges", LF_MARKS, { NK_LocalVariableWriteNode },
    mark_range_locals_at, NULL, NULL },
  [LW_DUPLICATE_UNDERSCORE_PARAMS] = { "desugar_duplicate_underscore_params", 0, { NK_DefNode, NK_BlockNode, NK_LambdaNode },
    desugar_duplicate_underscore_params_at, desugar_duplicate_underscore_params_left, "a parameter list that binds one `_x` twice" },
  [LW_ENCODING_QUERIES] = { "desugar_encoding_queries", 0, { NK_CallNode },
    desugar_encoding_queries_at, desugar_encoding_queries_left, "`Encoding.default_internal`, `Encoding.find(\"utf-8\")`" },
  [LW_ALIAS_METHOD_STRING_NAMES] = { "desugar_alias_method_string_names", 0, { NK_CallNode },
    desugar_alias_method_string_names_at, desugar_alias_method_string_names_left, "`alias_method \"a\", \"b\"`" },
  [LW_REASSIGNED_BLOCK_PARAMS] = { "desugar_reassigned_block_params", 0, { NK_BlockNode },
    desugar_reassigned_block_params_at, desugar_reassigned_block_params_left, "a block parameter the body assigns" },
  [LW_TAP_VALUE_WRITE] = { "desugar_tap_value_write", 0, { NK_LocalVariableWriteNode },
    desugar_tap_value_write_at, NULL, "`x = e.tap { }`" },
  [LW_BLK_PARAM_WRITES] = { "desugar_blk_param_writes", 0, { NK_DefNode },
    desugar_blk_param_writes_at, desugar_blk_param_writes_left, "a write to a method's `&blk` parameter" },
  [LW_REST_PARAM_WRITES] = { "desugar_rest_param_writes", 0, { NK_DefNode },
    desugar_rest_param_writes_at, desugar_rest_param_writes_left, "a write to a method's `*args` parameter" },
  [LW_YIELD_IN_CLOSURE] = { "desugar_yield_in_closure", 0, { NK_DefNode },
    desugar_yield_in_closure_at, desugar_yield_in_closure_left, "a `yield` inside a proc or lambda literal" },
  [LW_SAFE_NAV_ATTR_WRITE] = { "desugar_safe_nav_attr_write", 0,
    { NK_CallOperatorWriteNode, NK_CallOrWriteNode, NK_CallAndWriteNode },
    desugar_safe_nav_attr_write_at, desugar_safe_nav_attr_write_left, "`r&.a op= v`" },
  [LW_CONST_ATTR_OP_ASSIGN] = { "desugar_const_attr_op_assign", 0,
    { NK_CallOperatorWriteNode, NK_CallOrWriteNode, NK_CallAndWriteNode },
    desugar_const_attr_op_assign_at, desugar_const_attr_op_assign_left, "`Klass.a op= v`" },
  [LW_EMPTY_HASH_COMPARE_BY_IDENTITY] = { "desugar_empty_hash_compare_by_identity", 0, { NK_CallNode },
    desugar_empty_hash_compare_by_identity_at, desugar_empty_hash_compare_by_identity_left, "`{}.compare_by_identity`" },
  [LW_NAME_ANON_BLOCK_KWREST] = { "name_anon_block_kwrest", 0, { NK_BlockNode, NK_LambdaNode },
    name_anon_block_kwrest_at, name_anon_block_kwrest_left, "an anonymous `**` block parameter" },
  [LW_RIGHTWARD_PATTERN] = { "desugar_rightward_pattern", 0, { NK_MatchRequiredNode },
    desugar_rightward_pattern_at, desugar_rightward_pattern_left, "`x => pattern`" },
  [LW_MATCH_PREDICATE] = { "desugar_match_predicate", 0, { NK_MatchPredicateNode },
    desugar_match_predicate_at, desugar_match_predicate_left, "`x in pattern`" },
  [LW_SORT_BY_WITH_INDEX] = { "desugar_sort_by_with_index", 0, { NK_CallNode },
    desugar_sort_by_with_index_at, desugar_sort_by_with_index_left, "`sort_by.with_index { }`" },
  [LW_ANON_BLOCK_PARAM] = { "desugar_anon_block_param", 0, { NK_DefNode },
    desugar_anon_block_param_at, desugar_anon_block_param_left, "an anonymous `&`, `*` or `**` method parameter" },
  [LW_MULTI_VALUE_JUMP] = { "desugar_multi_value_jump", 0,
    { NK_ReturnNode, NK_BreakNode, NK_NextNode, NK_YieldNode, NK_CallNode },
    desugar_multi_value_jump_at, desugar_multi_value_jump_left, "`return *a, b`: a jump or call handing out several values" },
  [LW_BLOCK_DESTRUCTURE_PARAMS] = { "desugar_block_destructure_params", 0, { NK_BlockNode, NK_LambdaNode, NK_DefNode },
    desugar_block_destructure_params_at, desugar_block_destructure_params_left, "`|a, (b, c)|`: a destructuring parameter" },
  [LW_FOR_NONLOCAL_INDEX] = { "desugar_for_nonlocal_index", 0, { NK_ForNode },
    desugar_for_nonlocal_index_at, desugar_for_nonlocal_index_left, "`for $g in xs`: a `for` index that is not a local" },
  [LW_ENUM_FOR_WITH_ARGS] = { "desugar_enum_for_with_args", 0, { NK_DefNode },
    desugar_enum_for_with_args_at, NULL, "`return enum_for(:m, args)`" },
  [LW_ENUMERATOR_PRODUCE] = { "desugar_enumerator_produce", 0, { NK_CallNode },
    desugar_enumerator_produce_at, desugar_enumerator_produce_left, "`Enumerator.produce(x) { }`" },
  [LW_PARAM_DEFAULT_ASSIGNS_LOCAL] = { "desugar_param_default_assigns_local", 0, { NK_DefNode },
    desugar_param_default_assigns_local_at, NULL, "a parameter default that writes a local the body reads" },
};

/* ---- the kinds a row enters at ---- */

typedef struct { unsigned long long w[(NK__COUNT + 63) / 64]; } KindSet;

static KindSet kind_set_of(const Lowering *w) {
  KindSet s;
  memset(&s, 0, sizeof s);
  for (int k = 0; k < LW_MAX_KINDS && w->kinds[k]; k++) s.w[w->kinds[k] >> 6] |= 1ull << (w->kinds[k] & 63);
  return s;
}

static int kind_set_has(const KindSet *s, NodeKind k) { return (int)(s->w[k >> 6] >> (k & 63) & 1); }

/* ---- the driver ---- */

static void lower_scratch_reset(LowerCtx *lc) {
  lc->serial = 0;
  for (int i = 0; i < lc->nused; i++) free(lc->used[i]);
  free(lc->used);
  lc->used = NULL;
  lc->nused = 0;
  lc->used_built = 0;
}

/* One run of a row over the program: the rows below its count at entry that
   are of its kinds, in ascending id. The arrays that follow the table grow
   once, at the end. */
static int lower_pass(Compiler *c, LowerCtx *lc, const Lowering *w) {
  const NodeTable *nt = c->nt;
  KindSet set = kind_set_of(w);
  lc->n0 = nt->count;
  lower_scratch_reset(lc);
  int rewrote = 0;
  for (int id = 0; id < lc->n0; id++) {
    if (!kind_set_has(&set, nt_kind(nt, id))) continue;
    rewrote += w->visit(c, lc, id);
  }
  comp_grow_node_arrays(c);
  return rewrote;
}

/* ---- SPINEL_LOWER_CHECK ---- */

static void lower_say(LowerCtx *lc, const char *row, const char *what) {
  lc->findings++;
  fprintf(stderr, "spinel: lower check: %s: %s\n", row, what);
}

static void lower_where(const NodeTable *nt, int id, char *buf, size_t n) {
  long long ln = nt_int(nt, id, "node_line", 0);
  const char *file = nt_file_path(nt, (int)nt_int(nt, id, "node_file", 0));
  if (!file || !*file) file = nt->source_file;
  if (ln > 0) snprintf(buf, n, "%s:%lld", file && *file ? file : "source.rb", ln);
  else snprintf(buf, n, "no line");
}

/* The nodes of a row's kinds that are still in the shape it eliminates; the
   first is reported. */
static void lower_check_left(Compiler *c, LowerCtx *lc, int row, const char *when) {
  const Lowering *w = &lowerings[row];
  if (!w->left) return;
  const NodeTable *nt = c->nt;
  KindSet set = kind_set_of(w);
  lc->n0 = nt->count;
  int n = 0, first = -1;
  for (int id = 0; id < nt->count; id++) {
    if (!kind_set_has(&set, nt_kind(nt, id))) continue;
    if (!w->left(c, lc, id)) continue;
    if (first < 0) first = id;
    n++;
  }
  if (!n) return;
  char where[600], what[1000];
  lower_where(nt, first, where, sizeof where);
  snprintf(what, sizeof what, "%d node(s) still in the shape %s %s (first %s)", n, w->shape, when, where);
  lower_say(lc, w->name, what);
}

/* Run the row again over the table the first run left, and report a change.
   The row's own hash and count are what is compared. */
static void lower_check_again(Compiler *c, LowerCtx *lc, int row) {
  const Lowering *w = &lowerings[row];
  const NodeTable *nt = c->nt;
  unsigned long long h = nt_content_hash(nt);
  int n = nt->count;
  int again = lower_pass(c, lc, w);
  if (nt_content_hash(nt) == h) return;
  char what[200];
  snprintf(what, sizeof what, "a second run rewrote %d node(s) and changed the table (%d -> %d nodes)", again, n, nt->count);
  lower_say(lc, w->name, what);
}

void lower_begin(Compiler *c, LowerCtx *lc) {
  (void)c;
  memset(lc, 0, sizeof *lc);
  const char *e = getenv("SPINEL_LOWER_CHECK");
  lc->check = e && *e && *e != '0';
}

void lower_run(Compiler *c, LowerCtx *lc, int row) {
  NodeTable *nt = (NodeTable *)c->nt;
  const Lowering *w = &lowerings[row];
  const char *was = nt_set_pass(nt, w->name);
  lc->rewrote[row] += lower_pass(c, lc, w);
  if (lc->check) {
    lower_check_left(c, lc, row, "after its run");
    lower_check_again(c, lc, row);
  }
  nt_set_pass(nt, was);
}

/* The end of the stage: every row's shape, then the rows once more in the
   order of the table. */
static void lower_check_end(Compiler *c, LowerCtx *lc) {
  const NodeTable *nt = c->nt;
  for (int row = 0; row < LW__COUNT; row++) lower_check_left(c, lc, row, "at the end of the stage");
  for (int row = 0; row < LW__COUNT; row++) {
    unsigned long long h = nt_content_hash(nt);
    int n = nt->count;
    int again = lower_pass(c, lc, &lowerings[row]);
    if (nt_content_hash(nt) == h) continue;
    char what[200];
    snprintf(what, sizeof what, "run once more after the stage it rewrote %d node(s) and changed the table (%d -> %d nodes)",
             again, n, nt->count);
    lower_say(lc, lowerings[row].name, what);
  }
  fprintf(stderr, "spinel: lower check: %d rows, %d finding(s); rewrote:", LW__COUNT, lc->findings);
  for (int row = 0; row < LW__COUNT; row++)
    if (lc->rewrote[row] > 0) fprintf(stderr, " %s(%d)", lowerings[row].name, lc->rewrote[row]);
  fprintf(stderr, "\n");
}

void lower_finish(Compiler *c, LowerCtx *lc) {
  if (lc->check) {
    lower_check_end(c, lc);
    exit(0);
  }
  lower_scratch_reset(lc);
}
