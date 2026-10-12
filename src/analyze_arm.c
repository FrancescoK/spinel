/* analyze_arm.c -- per-arm facts (#7483).

   A block given to an iteration on a value of more than one kind is
   emitted inside each arm of the receiver's dispatch, with its first
   parameter typed by that arm (the parameter of `xs.each_slice(2) { |s| }`
   is the slice of whichever Array the arm holds; a `map` over a boxed
   receiver pins its parameter to the box). The analysis records one type
   per node, so codegen typed the body again under each arm's assumption
   (arm_body_infer, codegen_view.c), and the types it settled on there were
   not the ones recorded.

   This file types those bodies once, after the analysis has settled: for
   each block a site of that kind can ask about, and each parameter type it
   can ask with, the body's node types under that parameter type, keyed by
   (block, kind). The node types and the parameter's slot are put back as
   they were, so nothing the analysis recorded changes. --arm-check holds
   these facts against the typing codegen runs (arm_body_infer), with no
   reader yet: a missing fact or a type that differs is reported. */

#include "analyze_internal.h"

/* the iterations whose block codegen retypes per arm (codegen_iter.c,
   codegen_fold.c, codegen_call_object.c), and the parameter type each
   asks with: the box, the receiver's own kind, or a String */
enum { AK_POLY = 1, AK_RECV = 2, AK_STRING = 4 };
static int arm_kinds_of(const char *nm) {
  static const struct { const char *name; int kinds; } tab[] = {
    { "map", AK_POLY }, { "collect", AK_POLY }, { "sum", AK_POLY },
    { "tap", AK_RECV }, { "then", AK_RECV }, { "yield_self", AK_RECV },
    { "each_slice", AK_RECV }, { "each_cons", AK_RECV },
    { "combination", AK_RECV }, { "permutation", AK_RECV },
    { "repeated_combination", AK_RECV }, { "repeated_permutation", AK_RECV },
    { "each", AK_STRING }, { "split", AK_STRING }, { "scan", AK_STRING }, { "upto", AK_STRING },
    { NULL, 0 } };
  for (int i = 0; tab[i].name; i++) if (sp_streq(nm, tab[i].name)) return tab[i].kinds;
  return 0;
}

static void arm_collect(const NodeTable *nt, int n, int **out, int *len, int *cap, int depth) {
  if (n < 0 || depth > 4096) return;
  if (*len >= *cap) {
    *cap = *cap ? *cap * 2 : 64;
    *out = realloc(*out, sizeof **out * (size_t)*cap);
    if (!*out) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  }
  (*out)[(*len)++] = n;
  if (nt_kind(nt, n) == NK_DefNode) return;
  for (int i = 0; i < nt_num_refs(nt, n); i++) arm_collect(nt, nt_ref_at(nt, n, i), out, len, cap, depth + 1);
  for (int i = 0; i < nt_num_arrs(nt, n); i++) {
    int an = 0; const int *av = nt_arr_at(nt, n, i, &an);
    for (int k = 0; k < an; k++) arm_collect(nt, av[k], out, len, cap, depth + 1);
  }
}

const ArmFact *arm_fact_find(const Compiler *c, int block, TyKind kind) {
  for (int i = 0; i < c->narm_facts; i++)
    if (c->arm_facts[i].block == block && c->arm_facts[i].kind == kind) return &c->arm_facts[i];
  return NULL;
}

static void arm_record(Compiler *c, int block, LocalVar *lv, TyKind kind) {
  const NodeTable *nt = c->nt;
  if (arm_fact_find(c, block, kind)) return;
  int body = nt_ref(nt, block, "body");
  int bn = 0; const int *bb = body >= 0 ? nt_arr(nt, body, "body", &bn) : NULL;
  int *nodes = NULL, len = 0, cap = 0;
  for (int j = 0; j < bn; j++) arm_collect(nt, bb[j], &nodes, &len, &cap, 0);
  TyKind *saved = malloc(sizeof *saved * (size_t)(len ? len : 1));
  TyKind *types = malloc(sizeof *types * (size_t)(len ? len : 1));
  if (!saved || !types) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  for (int i = 0; i < len; i++) saved[i] = nodes[i] < c->node_cap ? c->ntype[nodes[i]] : TY_UNKNOWN;
  /* a block whose first parameter is no plain one (`|*r|`): the sites
     retype the body with no slot set, and so does this */
  TyKind lsaved = lv ? lv->type : TY_UNKNOWN;
  if (lv) lv->type = kind;
  for (int j = 0; j < bn; j++) infer_type(c, bb[j]);
  for (int i = 0; i < len; i++) types[i] = nodes[i] < c->node_cap ? c->ntype[nodes[i]] : TY_UNKNOWN;
  if (lv) lv->type = lsaved;
  for (int i = 0; i < len; i++) if (nodes[i] < c->node_cap) c->ntype[nodes[i]] = saved[i];
  free(saved);
  if (c->narm_facts >= c->carm_facts) {
    c->carm_facts = c->carm_facts ? c->carm_facts * 2 : 16;
    c->arm_facts = realloc(c->arm_facts, sizeof *c->arm_facts * (size_t)c->carm_facts);
    if (!c->arm_facts) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  }
  c->arm_facts[c->narm_facts++] = (ArmFact){ block, kind, len, nodes, types };
}

void an_arm_facts(Compiler *c) {
  const NodeTable *nt = c->nt;
  NT_FOREACH_KIND(nt, NK_CallNode, id) {
    const char *nm = nt_str(nt, id, "name");
    int block = nt_ref(nt, id, "block");
    int r = nt_ref(nt, id, "receiver");
    if (!nm || block < 0 || r < 0 || nt_kind(nt, block) != NK_BlockNode) continue;
    int kinds = arm_kinds_of(nm);
    if (!kinds) continue;
    /* the sites run in the arms of a dispatch over a boxed value, or over
       a boxed Array's elements */
    TyKind rt = c->ntype[r];
    if (rt != TY_POLY && rt != TY_POLY_ARRAY) continue;
    const char *p0 = block_param_name(c, block, 0);
    Scope *bs = p0 ? comp_scope_of(c, block) : NULL;
    LocalVar *lv = bs ? scope_local(bs, p0) : NULL;
    if (kinds & AK_POLY) arm_record(c, block, lv, TY_POLY);
    /* the receiver's own kind; a boxed one's arm is the boxed Array's */
    if ((kinds & AK_RECV) && rt != TY_UNKNOWN) arm_record(c, block, lv, rt == TY_POLY ? TY_POLY_ARRAY : rt);
    if (kinds & AK_STRING) arm_record(c, block, lv, TY_STRING);
  }
}
