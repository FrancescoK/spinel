/* --incremental's native step.

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
   headers and compiler-defined macros included, so a unit's text is most
   of its cache key.

   With -c, the unit set is the output: written to a directory, nothing
   compiled. Otherwise each unit's object is looked up in a cache under a
   key of everything the compiler consumed (the compiler's identity, the
   flags, both header hashes, the unit's hash), the misses compile in
   parallel, and the objects link in units.txt order, so a hit and a miss
   put the same bytes in the same place. A unit's object reaches the cache
   only after the build linked, by a rename of a complete file, so a
   concurrent build or a full disk can lose a store but never leave a
   short object under a key. Whatever goes wrong, the caller is told to
   compile the single unit, after a one-line notice that says why. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <time.h>
#include <unistd.h>
#include <utime.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <dirent.h>
#ifndef _WIN32
#include <sys/utsname.h>
#endif
#include "unit_cache.h"
#include "csplit.h"
#include "sha256.h"
#include "timing.h"

/* Copy a file; the number of bytes written, or -1. A caller that needs
   the whole file compares the count with the source's size: a short copy
   (a full disk) must not pass for an object. */
static long long inc_copy(const char *from, const char *to) {
  FILE *in = fopen(from, "rb");
  if (!in) return -1;
  FILE *out = fopen(to, "wb");
  if (!out) { fclose(in); return -1; }
  char buf[65536];
  size_t r;
  long long n = 0;
  while ((r = fread(buf, 1, sizeof buf, in)) > 0) n += (long long)fwrite(buf, 1, r, out);
  int bad = ferror(in);
  fclose(in);
  return (bad | ferror(out) | (fclose(out) != 0)) ? -1 : n;
}

/* The units.txt a previous split wrote, read before this one replaces it:
   NULL when there is none, or it is not spinel's. */
static char *inc_prior_manifest(const char *manifest) {
  if (!c_split_units_manifest(manifest)) return NULL;
  FILE *f = fopen(manifest, "rb");
  if (!f) return NULL;
  size_t cap = 4096, n = 0, r;
  char *t = malloc(cap);
  while ((r = fread(t + n, 1, cap - n - 1, f)) > 0)
    if ((n += r) == cap - 1) t = realloc(t, cap *= 2);
  fclose(f);
  t[n] = 0;
  return t;
}

/* A unit file the previous split listed and this one did not write:
   removed, so the directory holds the unit set units.txt lists. Only the
   files the previous units.txt named go; a unit_*.c of anyone else's
   beside them stays. */
static void inc_remove_stale(const char *dir, const char *prior, const CSplitResult *res) {
  const char *ln = prior;
  for (int row = 0; ln && *ln; row++) {
    const char *nl = strchr(ln, '\n');
    const char *f = row >= 2 ? strchr(ln, ' ') : NULL;   /* label file hash ... */
    if (f && (!nl || f < nl)) {
      f++;
      const char *fe = f;
      while (*fe && *fe != ' ' && *fe != '\n') fe++;
      char name[256];
      size_t l = (size_t)(fe - f);
      if (l >= 7 && l < sizeof name && !strncmp(f, "unit_", 5) && !memchr(f, '/', l)) {
        memcpy(name, f, l); name[l] = 0;
        int keep = 0;
        for (int k = 0; k < res->n && !keep; k++) {
          const char *b = strrchr(res->units[k].path, '/');
          keep = strcmp(b ? b + 1 : res->units[k].path, name) == 0;
        }
        if (!keep && !strcmp(name + l - 2, ".c")) {
          char p[4200];
          snprintf(p, sizeof p, "%s/%s", dir, name);
          remove(p);
        }
      }
    }
    ln = nl ? nl + 1 : NULL;
  }
}

/* Preprocess c_path with the build's flags and split it into dir. 0, or
   -1 with *why set to the notice's reason. */
static int inc_presplit(const char *flags, const char *c_path, const char *dir, const IncrementalOpts *o,
                        CSplitResult *res, const char **why) {
  char pre[4200];
  snprintf(pre, sizeof pre, "%s/pre.i", dir);
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
    *why = "the preprocessor failed";
    remove(pre);
    return -1;
  }
  CSplitOpts so = { o->unit_bytes, o->want_g, getenv("SPINEL_UNIT_DROP_DECL") };
  double tm_split = sp_timing_now();
  rc = c_split_units(pre, dir, &so, res);
  sp_timing_end(tm_split, "cc_split", "");
  /* a decline leaves -o DIR the text it declined, to look into */
  if (rc == 0 || !o->out_dir) remove(pre);
  if (rc != 0) *why = "the unit split declined";
  return rc;
}

/* -c --incremental: write program.c into out_dir, preprocess, split
   beside it, stop. program.c goes first, so that a decline leaves it in
   out_dir with pre.i, the text the split declined, to look into. A
   decline is the failure here: there is no single unit to fall back to
   when the unit set was the thing asked for. */
static int inc_write_dir(const char *flags, const char *c_path, const IncrementalOpts *o) {
  const char *dir = o->out_dir;
  char manifest[4200], prog[4200];
  snprintf(manifest, sizeof manifest, "%s/units.txt", dir);
  snprintf(prog, sizeof prog, "%s/program.c", dir);
  char *prior = inc_prior_manifest(manifest);
  if (inc_copy(c_path, prog) < 0) {
    fprintf(stderr, "spinel: incremental: cannot write %s\n", prog);
    free(prior);
    return -1;
  }
  CSplitResult res;
  const char *why = NULL;
  if (inc_presplit(flags, c_path, dir, o, &res, &why) != 0) {
    fprintf(stderr, "spinel: incremental: %s\n", why);
    free(prior);
    return -1;
  }
  if (prior) inc_remove_stale(dir, prior, &res);
  free(prior);
  fprintf(stderr, "Wrote %s (%d units)\n", dir, res.n);
  c_split_result_free(&res);
  return 0;
}

/* One build's state, from the split to the link. */
typedef struct {
  const IncrementalOpts *o;
  const char *flags;        /* cmd[0..src_at): the compile flags, verbatim */
  CSplitResult res;
  char work[4096];          /* the scratch directory the units are written to */
  char cache[4096];         /* the cache root, or "" when the cache is off */
  const char *off_why;      /* why it is off, for --cache-stats */
  char (*key)[65];          /* per unit: its cache key */
  char *hit;                /* per unit: 1 when its object came from the cache */
  int nhit, evicted;
  int store_errno;          /* the first failed store's errno, or 0 */
} IncBuild;

/* The cache root: SPINEL_CACHE_DIR, else the platform's cache directory.
   0, or -1 when nothing names one (the build then caches nothing). */
static int inc_cache_dir(char *out, size_t sz) {
  const char *e = getenv("SPINEL_CACHE_DIR");
  if (e && *e) { snprintf(out, sz, "%s", e); return 0; }
  e = getenv("XDG_CACHE_HOME");
  if (e && *e) { snprintf(out, sz, "%s/spinel", e); return 0; }
  e = getenv("HOME");
  if (e && *e) { snprintf(out, sz, "%s/.cache/spinel", e); return 0; }
#ifdef _WIN32
  e = getenv("LOCALAPPDATA");
  if (e && *e) { snprintf(out, sz, "%s/spinel", e); return 0; }
#endif
  return -1;
}

/* Hash what a probe command prints, with a separator so that two probes'
   outputs cannot run into each other. */
static void inc_hash_probe(Sha256 *s, const char *cmd) {
  FILE *p = popen(cmd, "r");
  if (p) {
    char buf[4096];
    size_t r;
    while ((r = fread(buf, 1, sizeof buf, p)) > 0) sha256_update(s, buf, r);
    pclose(p);
  }
  sha256_update(s, "\n--\n", 4);
}

/* The C compiler's identity, once per process. --version and -dumpmachine
   alone do not tell apart two builds of one gcc version configured
   differently (a default PIE, another install), and an object from one
   could be linked by the other; -v's `Configured with:` / `InstalledDir:`
   lines do. The host's system and machine are in it so that a cache shared
   across hosts does not hand one ISA's objects to another. */
static const char *inc_ccid(const char *cc_cmd) {
  static char id[65];
  if (id[0]) return id;
  Sha256 s;
  sha256_init(&s);
  const char *fmt[3] = { "%s --version 2>/dev/null", "%s -dumpmachine 2>/dev/null", "%s -v 2>&1" };
  for (int k = 0; k < 3; k++) {
    size_t l = strlen(cc_cmd) + 40;
    char *c = malloc(l);
    snprintf(c, l, fmt[k], cc_cmd);
    inc_hash_probe(&s, c);
    free(c);
  }
#ifndef _WIN32
  struct utsname u;
  if (uname(&u) == 0) {
    sha256_update(&s, u.sysname, strlen(u.sysname));
    sha256_update(&s, " ", 1);
    sha256_update(&s, u.machine, strlen(u.machine));
  }
#else
  const char *arch = getenv("PROCESSOR_ARCHITECTURE");
  sha256_update(&s, "Windows ", 8);
  if (arch) sha256_update(&s, arch, strlen(arch));
#endif
  unsigned char d[32];
  sha256_final(&s, d);
  for (int k = 0; k < 32; k++) snprintf(id + 2 * k, 3, "%02x", d[k]);
  return id;
}

/* A unit's key: every input of its cc -c. The unit hash covers its own
   text, the header hashes the headers it includes (an rt unit includes
   sp_rt.h only, so a program edit leaves its key alone), ccid the compiler
   and the flags how it was asked to compile. The flags the unit compile
   adds are constant or follow from the unit hash, so they are not in it.
   Under -g the object also records the directory cc ran in (spinel's
   own, against which the markers' relative paths resolve), so it is in
   the key: two checkouts building the same app.rb must not share one
   object whose debug info points at the other's sources. */
static void inc_key(const IncBuild *b, const CSplitUnit *u, char out[65]) {
  const char *ccid = inc_ccid(b->o->cc_cmd);
  char cwd[4096] = "";
  if (b->o->want_g && !getcwd(cwd, sizeof cwd)) cwd[0] = 0;
  size_t l = strlen(ccid) + strlen(b->flags) + strlen(cwd) + 4 * 65 + 64;
  char *rec = malloc(l);
  int n = snprintf(rec, l, "spinel-unit-1\n%s\n%s\n%s\n", ccid, b->flags, b->res.rt_hash);
  if (!u->is_rt) n += snprintf(rec + n, l - (size_t)n, "%s\n", b->res.program_hash);
  n += snprintf(rec + n, l - (size_t)n, "%s\n", u->hash);
  if (cwd[0]) n += snprintf(rec + n, l - (size_t)n, "cwd %s\n", cwd);
  sha256_hex(rec, (size_t)n, out);
  free(rec);
}

/* <cache>/objects/<key[0..2]>/<key[0..32]>.o: 256 directories, so that no
   one directory grows past what a filesystem lists quickly */
static void inc_obj_path(const IncBuild *b, const char *key, char *out, size_t sz) {
  snprintf(out, sz, "%s/objects/%.2s/%.32s.o", b->cache, key, key);
}

/* The work object of unit k: its .c with .o for .c. */
static void inc_unit_obj(const CSplitUnit *u, char *out, size_t sz) {
  snprintf(out, sz, "%s", u->path);
  size_t l = strlen(out);
  if (l >= 2) out[l - 1] = 'o';
}

/* Put a cached object in place as the unit's work object: linked, or
   copied whenever the link fails, as inc_store stores it. A mount without
   hard links may answer ENOTSUP, EACCES or ENOSYS as well as EXDEV or
   EPERM, and a cache that stores by copying must hit by copying. 1: a
   hit; a short copy is a miss. A zero-size object is what an interrupted
   copy outside spinel's care leaves; it is a miss and goes. The entry's
   mtime is refreshed, so the prune keeps what builds use. */
static int inc_lookup(const IncBuild *b, const char *key, const char *obj) {
  char cp[4300];
  inc_obj_path(b, key, cp, sizeof cp);
  struct stat st;
  if (stat(cp, &st) != 0) return 0;
  if (st.st_size == 0) { unlink(cp); return 0; }
  if (link(cp, obj) != 0) {
    if (inc_copy(cp, obj) != (long long)st.st_size) { unlink(obj); return 0; }
  }
  utime(cp, NULL);
  return 1;
}

/* Run cmds[0..n), up to `jobs` at a time, each through sh -c as the --jobs
   split does. Without fork (the Windows shim answers ENOSYS) a command
   runs through system() where it stood: serial, but the build completes.
   A failure starts nothing more; what is running drains. The index of the
   first command that failed, or -1. */
static int inc_pool_run(char **cmds, int n, int jobs) {
  pid_t *pid = calloc((size_t)(n > 0 ? n : 1), sizeof *pid);
  int next = 0, running = 0, failed = -1;
  while (running > 0 || (next < n && failed < 0)) {
    while (running < jobs && next < n && failed < 0) {
      int k = next++;
      fflush(NULL);
      pid_t p = fork();
      if (p == 0) { execl("/bin/sh", "sh", "-c", cmds[k], (char *)NULL); _exit(127); }
      if (p < 0) { if (system(cmds[k]) != 0) failed = k; continue; }
      pid[k] = p;
      running++;
    }
    if (running == 0) continue;
    int st = 0;
    pid_t w = waitpid(-1, &st, 0);
    if (w < 0) {
      if (errno == EINTR) continue;
      if (failed < 0) failed = next - 1;   /* children we cannot wait for: nothing is known to be built */
      break;
    }
    for (int k = 0; k < next; k++) {
      if (pid[k] != w) continue;
      pid[k] = 0;
      running--;
      if ((!WIFEXITED(st) || WEXITSTATUS(st) != 0) && failed < 0) failed = k;
    }
  }
  free(pid);
  return failed;
}

/* mkdir -p, for the cache's directory levels: the default root sits under
   a ~/.cache that may not exist yet. */
static int inc_mkdirs(const char *path) {
  char p[4300];
  snprintf(p, sizeof p, "%s", path);
  for (char *s = p + 1; *s; s++) {
    if (*s != '/') continue;
    *s = 0;
    mkdir(p, 0777);
    *s = '/';
  }
  if (mkdir(p, 0777) != 0 && errno != EEXIST) return -1;
  struct stat st;
  if (stat(p, &st) != 0) return -1;
  if (!S_ISDIR(st.st_mode)) { errno = ENOTDIR; return -1; }
  return 0;
}

/* Store a compiled unit's object under its key: link or copy it to a
   name of this process's own, then rename that over the key's name. The
   rename is atomic, so a reader sees no object or a whole one, and two
   builds storing the same key store the same bytes. A copy renames only
   when it is complete. 0, or an errno. */
static int inc_store(const IncBuild *b, const char *key, const char *obj) {
  char cp[4300], dir[4300], tmp[4400];
  inc_obj_path(b, key, cp, sizeof cp);
  snprintf(dir, sizeof dir, "%s/objects/%.2s", b->cache, key);
  if (inc_mkdirs(dir) != 0) return errno ? errno : EACCES;
  snprintf(tmp, sizeof tmp, "%s.tmp.%ld", cp, (long)getpid());
  unlink(tmp);
  if (link(obj, tmp) != 0) {
    struct stat st;
    if (stat(obj, &st) != 0) return errno;
    if (inc_copy(obj, tmp) != (long long)st.st_size) {
      int e = errno ? errno : ENOSPC;
      unlink(tmp);
      return e;
    }
  }
  if (rename(tmp, cp) != 0) {
    int e = errno;
    unlink(tmp);
    return e;
  }
  return 0;
}

/* The link: the compile flags again (the shape the --jobs split links
   with), every unit's object in units.txt order, then what followed the
   source in the single-unit command (the runtime archive, --link inputs,
   -lm, the section GC flag, -o). The order depends on the text alone, so a
   build that hit links the same inputs as one that compiled them all. */
static int inc_link(const IncBuild *b, const char *cmd, size_t src_end) {
  size_t ll = strlen(cmd) + (size_t)b->res.n * 4200 + 16;
  char *lk = malloc(ll);
  size_t w = (size_t)snprintf(lk, ll, "%s", b->flags);
  for (int k = 0; k < b->res.n; k++) {
    char obj[4096];
    inc_unit_obj(&b->res.units[k], obj, sizeof obj);
    w += (size_t)snprintf(lk + w, ll - w, "'%s' ", obj);
  }
  snprintf(lk + w, ll - w, "%s", cmd + src_end);
  int rc = system(lk);
  free(lk);
  return rc;
}

/* After a failed link every object this build took from the cache goes:
   one of them may be the corrupt or foreign object that failed it, and
   left in place it would fail every later build the same way. */
static void inc_evict(IncBuild *b) {
  for (int k = 0; k < b->res.n; k++) {
    if (!b->hit[k]) continue;
    char cp[4300];
    inc_obj_path(b, b->key[k], cp, sizeof cp);
    if (unlink(cp) == 0) b->evicted++;
  }
}

/* Remove in one cache subdirectory what has not been used for `days`
   days, and the stores that died a day ago or more. */
static void inc_prune_dir(const char *dir, time_t now, int days) {
  DIR *d = opendir(dir);
  if (!d) return;
  struct dirent *e;
  while ((e = readdir(d)) != NULL) {
    size_t l = strlen(e->d_name);
    int is_obj = l > 2 && strcmp(e->d_name + l - 2, ".o") == 0;
    int is_tmp = strstr(e->d_name, ".tmp.") != NULL;
    if (!is_obj && !is_tmp) continue;
    char p[4400];
    snprintf(p, sizeof p, "%s/%s", dir, e->d_name);
    struct stat st;
    if (stat(p, &st) != 0) continue;
    double age = difftime(now, st.st_mtime);
    if (age > (is_tmp ? 86400.0 : 86400.0 * days)) unlink(p);
  }
  closedir(d);
}

/* Once a day at most (the stamp objects/.pruned says when it last ran):
   drop objects no build has hit for SPINEL_CACHE_DAYS days (14). A hit
   refreshes its object's mtime, so what is in use stays. The stamp is
   written before the walk, and a cache where it cannot be written counts
   as pruned today: otherwise every build would walk it again. */
static void inc_prune(const IncBuild *b) {
  char objs[4200], stamp[4300];
  snprintf(objs, sizeof objs, "%s/objects", b->cache);
  snprintf(stamp, sizeof stamp, "%s/.pruned", objs);
  time_t now = time(NULL);
  struct stat st;
  if (stat(objs, &st) != 0) return;
  if (stat(stamp, &st) == 0 && difftime(now, st.st_mtime) < 86400.0) return;
  FILE *f = fopen(stamp, "w");
  if (!f || fclose(f) != 0) return;
  const char *e = getenv("SPINEL_CACHE_DAYS");
  int days = e && atoi(e) > 0 ? atoi(e) : 14;
  DIR *d = opendir(objs);
  if (!d) return;
  struct dirent *de;
  while ((de = readdir(d)) != NULL) {
    if (strlen(de->d_name) != 2 || de->d_name[0] == '.') continue;
    char sub[4300];
    snprintf(sub, sizeof sub, "%s/%s", objs, de->d_name);
    inc_prune_dir(sub, now, days);
  }
  closedir(d);
}

/* --cache-stats: the summary, whose `units=N hit=H miss=M` prefix the
   tests read, then one line per miss. */
static void inc_stats(const IncBuild *b) {
  int nk[3] = { 0, 0, 0 }, hk[3] = { 0, 0, 0 };
  for (int k = 0; k < b->res.n; k++) {
    const CSplitUnit *u = &b->res.units[k];
    int kind = u->is_rt ? 0 : u->label[0] == 'p' ? 1 : 2;
    nk[kind]++;
    hk[kind] += b->hit[k];
  }
  fprintf(stderr, "spinel: cache: units=%d hit=%d miss=%d rt=%d/%d program=%d/%d tagged=%d/%d dir=",
          b->res.n, b->nhit, b->res.n - b->nhit, hk[0], nk[0], hk[1], nk[1], hk[2], nk[2]);
  if (b->cache[0]) fprintf(stderr, "%s\n", b->cache);
  else fprintf(stderr, "off (%s)\n", b->off_why);
  for (int k = 0; k < b->res.n; k++) {
    if (b->hit[k]) continue;
    const CSplitUnit *u = &b->res.units[k];
    const char *f = strrchr(u->path, '/');
    fprintf(stderr, "spinel: cache: miss %s %s (%zu bytes)\n", u->label, f ? f + 1 : u->path, u->bytes);
  }
  if (b->evicted) fprintf(stderr, "spinel: cache: evicted %d objects\n", b->evicted);
  if (b->store_errno) fprintf(stderr, "spinel: cache: store failed (%s)\n", strerror(b->store_errno));
}

/* The work directory holds files only: the headers, the units, their
   objects, units.txt. */
static void inc_rm_work(const char *dir) {
  DIR *d = opendir(dir);
  if (d) {
    struct dirent *e;
    while ((e = readdir(d)) != NULL) {
      if (strcmp(e->d_name, ".") == 0 || strcmp(e->d_name, "..") == 0) continue;
      char p[4400];
      snprintf(p, sizeof p, "%s/%s", dir, e->d_name);
      unlink(p);
    }
    closedir(d);
  }
  rmdir(dir);
}

/* Keys and lookups, before anything compiles. */
static void inc_lookup_all(IncBuild *b) {
  double tm = sp_timing_now();
  for (int k = 0; k < b->res.n && b->cache[0]; k++) {
    char obj[4096];
    inc_key(b, &b->res.units[k], b->key[k]);
    inc_unit_obj(&b->res.units[k], obj, sizeof obj);
    b->hit[k] = (char)inc_lookup(b, b->key[k], obj);
    b->nhit += b->hit[k];
  }
  sp_timing_end(tm, "cache_lookup", "");
}

/* Compile the misses. The two -Werror flags turn a declaration the
   split's import scan missed into an error instead of an object that calls
   an int-returning guess (spinel compiles with -Wno-all, under which gcc
   says nothing about it). -frandom-seed fixes the one input gcc documents
   as random, so a unit compiles to the same bytes in every build; under -g
   the work directory's name is mapped away from the debug info. The label
   of the first unit that failed, or NULL. */
static const char *inc_compile(IncBuild *b, int jobs) {
  int nmiss = b->res.n - b->nhit, m = 0;
  char **cmds = malloc(sizeof(char *) * (size_t)(nmiss > 0 ? nmiss : 1));
  int *which = malloc(sizeof(int) * (size_t)(nmiss > 0 ? nmiss : 1));
  for (int k = 0; k < b->res.n; k++) {
    if (b->hit[k]) continue;
    const CSplitUnit *u = &b->res.units[k];
    char obj[4096], map[4200] = "";
    inc_unit_obj(u, obj, sizeof obj);
    if (b->o->want_g) snprintf(map, sizeof map, " '-fdebug-prefix-map=%s=spinel-units'", b->work);
    size_t l = strlen(b->flags) + strlen(map) + 2 * strlen(u->path) + 256;
    cmds[m] = malloc(l);
    snprintf(cmds[m], l, "%s -Werror=implicit-function-declaration -Werror=implicit-int -frandom-seed=%s%s -c '%s' -o '%s'",
             b->flags, u->hash, map, u->path, obj);
    which[m++] = k;
  }
  double tm = sp_timing_now();
  int failed = inc_pool_run(cmds, m, jobs);
  char ex[96];
  snprintf(ex, sizeof ex, " units=%d miss=%d jobs=%d", b->res.n, m, jobs);
  sp_timing_end(tm, "cc_compile", ex);
  for (int k = 0; k < m; k++) free(cmds[k]);
  free(cmds);
  const char *label = failed >= 0 ? b->res.units[which[failed]].label : NULL;
  free(which);
  return label;
}

/* Compile what missed, link, and store what was compiled. 0, or -1 with
   the notice's reason in why (buf holds it when it names a unit). */
static int inc_compile_link(IncBuild *b, const char *cmd, size_t src_end, int jobs, char *why, size_t wsz) {
  const char *bad = inc_compile(b, jobs);
  if (bad) {
    snprintf(why, wsz, "unit %s did not compile", bad);
    return -1;
  }
  double tm = sp_timing_now();
  int rc = inc_link(b, cmd, src_end);
  sp_timing_end(tm, "cc_link", "");
  if (rc != 0) {
    if (b->nhit && b->cache[0]) inc_evict(b);
    snprintf(why, wsz, "the link failed");
    return -1;
  }
  /* stored only once the build linked: nothing of a failed build reaches
     the cache */
  for (int k = 0; k < b->res.n && b->cache[0]; k++) {
    if (b->hit[k]) continue;
    char obj[4096];
    inc_unit_obj(&b->res.units[k], obj, sizeof obj);
    int e = inc_store(b, b->key[k], obj);
    if (e && !b->store_errno) b->store_errno = e;
  }
  if (b->cache[0]) inc_prune(b);
  return 0;
}

/* The build proper: a work directory, the split, lookups, the compile of
   the misses, the link. */
static int inc_build(IncBuild *b, const char *cmd, size_t src_end, const char *c_path, int jobs) {
  const IncrementalOpts *o = b->o;
  const char *tmpd = getenv("TMPDIR");
  char why[CS_LABEL_MAX + 64] = "";
  snprintf(b->work, sizeof b->work, "%s/spinel_inc_XXXXXX", tmpd && *tmpd ? tmpd : "/tmp");
  if (!mkdtemp(b->work)) {
    snprintf(why, sizeof why, "cannot create a work directory (%s)", strerror(errno));
  } else {
    const char *w = NULL;
    int rc = inc_presplit(b->flags, c_path, b->work, o, &b->res, &w);
    if (rc != 0) snprintf(why, sizeof why, "%s", w);
    else {
      int n = b->res.n > 0 ? b->res.n : 1;
      b->key = calloc((size_t)n, sizeof *b->key);
      b->hit = calloc((size_t)n, 1);
      if (getenv("SPINEL_NO_CACHE")) b->off_why = "SPINEL_NO_CACHE";
      else if (inc_cache_dir(b->cache, sizeof b->cache) != 0) b->off_why = "no cache directory";
      if (b->off_why) b->cache[0] = 0;
      inc_lookup_all(b);
      inc_compile_link(b, cmd, src_end, jobs, why, sizeof why);
      if (o->cache_stats) inc_stats(b);
      c_split_result_free(&b->res);
      free(b->key);
      free(b->hit);
    }
    if (getenv("SPINEL_KEEP_UNITS")) fprintf(stderr, "spinel: units kept at %s\n", b->work);
    else inc_rm_work(b->work);
  }
  if (!why[0]) return 0;
  fprintf(stderr, "spinel: incremental: %s; %s\n", why,
          getenv("SPINEL_INCREMENTAL_STRICT") ? "STRICT, failing" : "compiling as one unit");
  return -1;
}

int cc_incremental_build(const char *cmd, size_t src_at, size_t src_end, const char *c_path, int jobs, const IncrementalOpts *o) {
  /* the flags before the source, however long: an ffi program's cflags
     have no bound */
  char *flags = malloc(src_at + 1);
  memcpy(flags, cmd, src_at);
  flags[src_at] = 0;
  int rc;
  if (o->out_dir) rc = inc_write_dir(flags, c_path, o);
  else {
    if (jobs <= 0) {
      long nc = sysconf(_SC_NPROCESSORS_ONLN);
      jobs = nc > 16 ? 16 : nc > 1 ? (int)nc : 1;
    }
    if (jobs > 64) jobs = 64;
    IncBuild b;
    memset(&b, 0, sizeof b);
    b.o = o;
    b.flags = flags;
    rc = inc_build(&b, cmd, src_end, c_path, jobs);
  }
  free(flags);
  return rc;
}
