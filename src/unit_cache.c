/* --incremental's native step (docs/internals/incremental-build.md).

   The generated C of an --incremental build carries `#pragma spinel unit`
   lines where each method, constructor, dispatcher and main begins. This
   file preprocesses that C with the build's own compile flags and hands the
   result to c_split_units (csplit.c), which cuts it at those lines into
   units that compile on their own against two shared headers.

   Splitting after the preprocessor rather than before keeps the runtime
   header out of the question: lib/spinel_rt.h defines file-scope objects
   and static functions in every unit that includes it, and the
   preprocessed text says, with its line markers, exactly which items came
   from it. The preprocessed text is also what a cached object depends on,
   headers and compiler-defined macros included, so a unit's text is the
   most of its cache key.

   With -c, the unit set is the output: written to a directory, nothing
   compiled. Otherwise the units are not compiled one by one yet: the
   caller is told to compile the single unit. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <dirent.h>
#include "unit_cache.h"
#include "csplit.h"
#include "timing.h"

/* Copy the generated C into the unit directory as program.c: the text the
   units came from, for reading next to them. */
static int inc_copy_file(const char *from, const char *to) {
  FILE *in = fopen(from, "rb");
  if (!in) return -1;
  FILE *out = fopen(to, "wb");
  if (!out) { fclose(in); return -1; }
  char buf[65536];
  size_t r;
  while ((r = fread(buf, 1, sizeof buf, in)) > 0) fwrite(buf, 1, r, out);
  int bad = ferror(in);
  fclose(in);
  return (bad | ferror(out) | (fclose(out) != 0)) ? -1 : 0;
}

/* A unit file a previous split wrote and this one did not: removed, so the
   directory holds the unit set units.txt lists and nothing else. Only when
   a units.txt was there before, which proves the directory is spinel's. */
static void inc_remove_stale(const char *dir, const CSplitResult *res) {
  DIR *d = opendir(dir);
  if (!d) return;
  struct dirent *e;
  while ((e = readdir(d)) != NULL) {
    size_t l = strlen(e->d_name);
    if (strncmp(e->d_name, "unit_", 5) != 0 || l < 7 || strcmp(e->d_name + l - 2, ".c") != 0) continue;
    int keep = 0;
    for (int k = 0; k < res->n && !keep; k++) {
      const char *b = strrchr(res->units[k].path, '/');
      keep = strcmp(b ? b + 1 : res->units[k].path, e->d_name) == 0;
    }
    if (keep) continue;
    char p[4200];
    snprintf(p, sizeof p, "%s/%s", dir, e->d_name);
    remove(p);
  }
  closedir(d);
}

/* -c --incremental: preprocess, split into out_dir, write program.c beside
   the units, stop. A decline is the failure here: there is no single unit
   to fall back to when the unit set was the thing asked for. */
static int inc_write_dir(const char *flags, const char *c_path, const IncrementalOpts *o) {
  const char *dir = o->out_dir;
  char pre[4200], manifest[4200], prog[4200];
  snprintf(pre, sizeof pre, "%s/pre.i", dir);
  snprintf(manifest, sizeof manifest, "%s/units.txt", dir);
  snprintf(prog, sizeof prog, "%s/program.c", dir);
  struct stat st;
  int had_manifest = stat(manifest, &st) == 0;
  size_t cl = strlen(flags) + strlen(c_path) + strlen(pre) + 64;
  char *c1 = malloc(cl);
  /* -E keeps the line markers: the split finds the runtime region by them
     and replays them, so a unit still says which lines are the .rb's */
  snprintf(c1, cl, "%s -E '%s' -o '%s'", flags, c_path, pre);
  double tm_pre = sp_timing_now();
  int rc = system(c1);
  free(c1);
  sp_timing_end(tm_pre, "cc_preprocess", "");
  if (rc != 0) {
    fprintf(stderr, "spinel: incremental: the preprocessor failed\n");
    remove(pre);
    return -1;
  }
  CSplitOpts so = { o->unit_bytes, o->want_g, getenv("SPINEL_UNIT_DROP_DECL") };
  CSplitResult res;
  double tm_split = sp_timing_now();
  rc = c_split_units(pre, dir, &so, &res);
  sp_timing_end(tm_split, "cc_split", "");
  remove(pre);
  if (rc != 0) {
    fprintf(stderr, "spinel: incremental: the unit split declined\n");
    return -1;
  }
  if (inc_copy_file(c_path, prog) != 0) {
    fprintf(stderr, "spinel: incremental: cannot write %s\n", prog);
    c_split_result_free(&res);
    return -1;
  }
  if (had_manifest) inc_remove_stale(dir, &res);
  fprintf(stderr, "Wrote %s (%d units)\n", dir, res.n);
  c_split_result_free(&res);
  return 0;
}

int cc_incremental_build(const char *cmd, size_t src_at, size_t src_end, const char *c_path, int jobs, const IncrementalOpts *o) {
  (void)src_end; (void)jobs;
  if (!o->out_dir) return -1;
  /* the flags before the source, however long: an ffi program's cflags
     have no bound */
  char *flags = malloc(src_at + 1);
  memcpy(flags, cmd, src_at);
  flags[src_at] = 0;
  int rc = inc_write_dir(flags, c_path, o);
  free(flags);
  return rc;
}
