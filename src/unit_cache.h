#ifndef SPINEL_UNIT_CACHE_H
#define SPINEL_UNIT_CACHE_H
#include <stddef.h>

/* --incremental's native step: preprocess the generated C, split it into
   units (csplit.c's c_split_units), take each unit's object from the cache
   or compile it, and link; with -c, write the unit set to a directory
   instead of building. See unit_cache.c. */
typedef struct {
  size_t unit_bytes;        /* --unit-bytes */
  int cache_stats;          /* --cache-stats */
  int want_g;               /* -g / --debug: keep markers in the hash, add -fdebug-prefix-map */
  const char *cc_cmd;       /* for the ccid probes */
  const char *out_dir;      /* -c --incremental: write the unit set here and stop; NULL otherwise */
} IncrementalOpts;

/* 0: the binary is built (or the directory written). -1: a notice was printed
   and the caller may run the single-unit command. `cmd` is the whole
   single-unit command; the source sits at [src_at, src_end) in it, the
   compile flags before it and the link inputs after it. */
int cc_incremental_build(const char *cmd, size_t src_at, size_t src_end, const char *c_path, int jobs, const IncrementalOpts *o);

#endif
