/* builtin_ops.c -- the builtin method rows (see builtin_ops.h). */

#include <stdlib.h>
#include <string.h>
#include "builtin_ops.h"

/* Rows grouped by receiver kind. Within a kind the order does not matter:
   lookups go through the sorted index below. */
static const BuiltinOp bop_rows[] = {
  /* Process::Tms: four cumulative CPU times, all Float (#3044) */
  { TY_TMS, "utime",  0, 0, BF_ANY, TY_FLOAT, BOPE_STRUCT_FIELD },
  { TY_TMS, "stime",  0, 0, BF_ANY, TY_FLOAT, BOPE_STRUCT_FIELD },
  { TY_TMS, "cutime", 0, 0, BF_ANY, TY_FLOAT, BOPE_STRUCT_FIELD },
  { TY_TMS, "cstime", 0, 0, BF_ANY, TY_FLOAT, BOPE_STRUCT_FIELD },
};
#define BOP_NROWS ((int)(sizeof bop_rows / sizeof bop_rows[0]))

/* Row indices sorted by (receiver kind, name), built on first use. */
static int bop_index[BOP_NROWS];
static int bop_indexed;

static int bop_cmp_key(TyKind rt, const char *name, const BuiltinOp *r) {
  if (rt != r->recv) return rt < r->recv ? -1 : 1;
  return strcmp(name, r->name);
}

static int bop_sort_cmp(const void *a, const void *b) {
  const BuiltinOp *x = &bop_rows[*(const int *)a], *y = &bop_rows[*(const int *)b];
  int r = bop_cmp_key(x->recv, x->name, y);
  return r ? r : x->argc_min - y->argc_min;
}

static void bop_build_index(void) {
  for (int i = 0; i < BOP_NROWS; i++) bop_index[i] = i;
  qsort(bop_index, BOP_NROWS, sizeof bop_index[0], bop_sort_cmp);
  bop_indexed = 1;
}

static int bop_row_fits(const BuiltinOp *r, int argc, int has_block) {
  if (argc < r->argc_min || argc > r->argc_max) return 0;
  if (r->block == BF_NONE && has_block) return 0;
  if (r->block == BF_REQUIRED && !has_block) return 0;
  return 1;
}

const BuiltinOp *bop_find(TyKind rt, const char *name, int argc, int has_block) {
  if (!name) return NULL;
  if (!bop_indexed) bop_build_index();
  int lo = 0, hi = BOP_NROWS;
  while (lo < hi) {
    int mid = lo + (hi - lo) / 2;
    if (bop_cmp_key(rt, name, &bop_rows[bop_index[mid]]) > 0) lo = mid + 1;
    else hi = mid;
  }
  /* rows of one name differ by arity or block form: take the first that fits */
  for (int i = lo; i < BOP_NROWS; i++) {
    const BuiltinOp *r = &bop_rows[bop_index[i]];
    if (bop_cmp_key(rt, name, r) != 0) break;
    if (bop_row_fits(r, argc, has_block)) return r;
  }
  return NULL;
}

int bop_covers(TyKind rt) {
  for (int i = 0; i < BOP_NROWS; i++) if (bop_rows[i].recv == rt) return 1;
  return 0;
}
