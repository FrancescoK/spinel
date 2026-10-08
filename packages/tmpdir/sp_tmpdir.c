/* sp_tmpdir.c -- Dir.tmpdir / Dir.mktmpdir for the `tmpdir` spin package.

   CRuby-compatible name format: "parent/prefixYYYYMMDD-pid-random[suffix]"
   where random is 1-6 base-36 chars. On EEXIST, a "-N" counter is
   appended before the suffix and retried up to max_try times. */
#include "spinel/runtime.h"
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <errno.h>
#include <limits.h>
#include <time.h>
#include <stdio.h>

#define TMPDIR_RETRIES 10000
#define MAX_RANDOM_BYTES 4  /* 32 bits -> 0..36^6 */

/* Read up to n random bytes from /dev/urandom. Falls back to time+pid
   XOR if /dev/urandom is unavailable. Returns the number of bytes
   read. */
static int read_urandom(unsigned char *buf, int n) {
  int got = 0;
  FILE *f = fopen("/dev/urandom", "rb");
  if (!f) return 0;
  while (got < n) {
    int r = (int)fread(buf + got, 1, n - got, f);
    if (r <= 0) break;
    got += r;
  }
  fclose(f);
  return got;
}

/* Format a random base-36 string of up to 6 chars into `out`. Returns
   the number of chars written. The space is 36^6 = 2176782336 < 2^32,
   so we mask the random 32-bit value. */
static int format_random(char *out) {
  unsigned char buf[4] = {0};
  if (read_urandom(buf, 4) != 4) {
    /* Fallback: time + pid + counter. Not crypto-strong but unique
       enough for temp dirs. */
    static unsigned int fc = 0;
    unsigned int v = (unsigned int)(time(NULL) ^ (getpid() << 16) ^ fc++);
    buf[0] = v & 0xff;
    buf[1] = (v >> 8) & 0xff;
    buf[2] = (v >> 16) & 0xff;
    buf[3] = (v >> 24) & 0xff;
  }
  unsigned int v = ((unsigned int)buf[0]) |
                   ((unsigned int)buf[1] << 8) |
                   ((unsigned int)buf[2] << 16) |
                   ((unsigned int)buf[3] << 24);
  v = v % 2176782336u;  /* 36^6 */
  if (v == 0) v = 1;    /* avoid empty string */
  char tmp[7];
  int i = 0;
  while (v > 0 && i < 6) {
    unsigned int d = v % 36;
    tmp[i++] = (d < 10) ? ('0' + d) : ('a' + d - 10);
    v /= 36;
  }
  tmp[i] = '\0';
  /* Reverse into out. */
  for (int j = 0; j < i; j++) out[j] = tmp[i - 1 - j];
  return i;
}

static const char *tmpdir_mkdtemp(const char *prefix, const char *suffix,
                                  const char *parent, int max_try) {
  size_t pre_len = prefix ? strlen(prefix) : 0;
  size_t suf_len = suffix ? strlen(suffix) : 0;
  size_t par_len = strlen(parent);

  /* Format the date once, in local time, as CRuby's
     Time.now.strftime("%Y%m%d"): a year of four digits at least, then the
     month and day. The buffer holds any int year, so the name is never cut
     short; it is YYYYMMDD for years 1000 to 9999. */
  char date[40];
  time_t now = time(NULL);
  struct tm tm;
  localtime_r(&now, &tm);
  int date_len = snprintf(date, sizeof(date), "%04d%02d%02d",
                          tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday);

  /* Pre-format the constant middle: "-pid-". */
  char mid[32];
  int mid_len = snprintf(mid, sizeof(mid), "-%d-", (int)getpid());

  /* Build path pieces. The final path is:
     parent + "/" + prefix + date + mid + random [+ "-N"] + suffix
     Worst-case size: 4096 (parent) + 1 + 64 (prefix) + date_len +
                      32 (mid) + 6 (random) + 8 ("-NNNNNNN") + 64 (suffix) */
  char path[PATH_MAX];
  if (par_len + 1 + pre_len + (size_t)date_len + 32 + 6 + 8 + suf_len >= sizeof(path))
    sp_raise_cls("ArgumentError", "tmpdir path too long");

  for (int n = 0; n < max_try; n++) {
    char random[7];
    int random_len = format_random(random);

    int pos = 0;
    memcpy(path + pos, parent, par_len); pos += par_len;
    path[pos++] = '/';
    if (pre_len) { memcpy(path + pos, prefix, pre_len); pos += pre_len; }
    memcpy(path + pos, date, date_len); pos += date_len;
    memcpy(path + pos, mid, mid_len); pos += mid_len;
    memcpy(path + pos, random, random_len); pos += random_len;
    if (n > 0) {
      /* "-N" counter. */
      pos += snprintf(path + pos, sizeof(path) - pos, "-%d", n);
    }
    if (suf_len) { memcpy(path + pos, suffix, suf_len); pos += suf_len; }
    path[pos] = '\0';

    if (mkdir(path, 0700) == 0) {
      char *r = sp_str_alloc_raw(pos + 1);
      memcpy(r, path, pos);
      r[pos] = '\0';
      sp_str_set_len(r, pos);
      return r;
    }
    if (errno != EEXIST) {
      int saved = errno;
      const char *cls = "RuntimeError";
      switch (saved) {
        case EACCES:       cls = "Errno::EACCES"; break;
        case EFAULT:       cls = "Errno::EFAULT"; break;
        case ELOOP:        cls = "Errno::ELOOP"; break;
        case ENAMETOOLONG: cls = "Errno::ENAMETOOLONG"; break;
        case ENOENT:       cls = "Errno::ENOENT"; break;
        case ENOTDIR:      cls = "Errno::ENOTDIR"; break;
        case EROFS:        cls = "Errno::EROFS"; break;
      }
      sp_raise_cls(cls, strerror(saved));
    }
  }
  sp_raise_cls("Errno::EEXIST", "cannot generate temporary directory name");
  return sp_str_empty;  /* unreachable */
}

/* CRuby's Dir.tmpdir does not hand back $TMPDIR unseen: a directory that
   does not exist, is not a directory, or cannot be written and searched is
   not usable, and it falls back to /tmp. Returning it raw only moved the
   failure to the mkdir, with an error naming a path the program never
   chose. */
static int tmpdir_usable(const char *p) {
  struct stat st;
  if (stat(p, &st) != 0) return 0;
  if (!S_ISDIR(st.st_mode)) return 0;
  return access(p, W_OK | X_OK) == 0;
}

/* CRuby runs each candidate through File.expand_path before handing it
   back, so what the caller gets is absolute and lexically clean. macOS
   sets $TMPDIR in exactly the form that shows the difference --
   "/var/folders/.../T/" -- and returning it raw put that trailing
   separator into every path built on it. "/T//foo" opens the same file,
   but File.dirname of it is "/T/", which is not the string Dir.tmpdir
   answered, and that comparison is the one Dir.mktmpdir's own parent
   check makes. A relative $TMPDIR is worse than cosmetic: the answer
   stops naming the same directory the moment the process chdirs.

   The resolution is LEXICAL, which is what expand_path does: "a/../b" is
   "b" without asking the filesystem whether "a" was a symlink pointing
   somewhere else. `~` is the one form not expanded: a literal "~/tmp"
   becomes "<cwd>/~/tmp", which is not a directory that exists, so the
   usability check on the expanded path rejects it and the answer is the
   /tmp fallback. */
static const char *tmpdir_expand(const char *p) {
  char raw[PATH_MAX];
  size_t n = 0;
#if defined(_WIN32)
  if (!sp_file_path_root_len(p)) {
#else
  if (p[0] != '/') {
#endif
    if (!getcwd(raw, sizeof(raw)))
      sp_raise_cls("ArgumentError", "cannot expand a relative TMPDIR: getcwd failed");
    n = strlen(raw);
    if (n + 1 >= sizeof(raw)) sp_raise_cls("ArgumentError", "tmpdir path too long");
    raw[n++] = '/';
  }
  size_t pn = strlen(p);
  if (n + pn >= sizeof(raw)) sp_raise_cls("ArgumentError", "tmpdir path too long");
  memcpy(raw + n, p, pn);
  n += pn;
  raw[n] = '\0';

  /* Walk the components, dropping "" and "." and popping on "..". The
     output always starts at the root, so a ".." there is dropped rather
     than climbing above it -- "/.." is "/", as it is on the filesystem. */
  char out[PATH_MAX];
  size_t len = 0;
#if defined(_WIN32)
  /* a drive's root ("C:/") is kept: ".." stops at it, and the walk starts
     after it */
  size_t floor = 0, i0 = 0;
  if (sp_file_path_root_len(raw) == 3) { out[0] = raw[0]; out[1] = ':'; len = floor = 2; i0 = 2; }
  for (size_t i = i0; i < n; ) {
#else
  for (size_t i = 0; i < n; ) {
#endif
    while (i < n && raw[i] == '/') i++;
    size_t b = i;
    while (i < n && raw[i] != '/') i++;
    size_t clen = i - b;
    if (clen == 0) continue;
    if (clen == 1 && raw[b] == '.') continue;
    if (clen == 2 && raw[b] == '.' && raw[b + 1] == '.') {
#if defined(_WIN32)
      while (len > floor && out[len - 1] != '/') len--;
      if (len > floor) len--;   /* drop the separator too */
#else
      while (len > 0 && out[len - 1] != '/') len--;
      if (len > 0) len--;   /* drop the separator too */
#endif
      continue;
    }
    out[len++] = '/';
    memcpy(out + len, raw + b, clen);
    len += clen;
  }
#if defined(_WIN32)
  if (len == floor) out[len++] = '/';   /* every component cancelled: the root */
#else
  if (len == 0) out[len++] = '/';   /* every component cancelled: the root */
#endif

  char *r = sp_str_alloc_raw(len + 1);
  memcpy(r, out, len);
  r[len] = '\0';
  sp_str_set_len(r, len);
  return r;
}

const char *sp_Dir_tmpdir(void) {
  const char *env = getenv("TMPDIR");
  /* Expand BEFORE the usability check, on the path that is actually handed
     back. The expansion is lexical, so a `..` after a symlink names a
     different directory than the string the shell left: with $TMPDIR set to
     "<dir>/ro/ln/.." where ln points out of ro, the raw path is writable (it
     resolves through the link) while the expanded "<dir>/ro" is not, and
     checking the raw one answered a directory nothing can be created in --
     Dir.mktmpdir then raised where CRuby falls back to /tmp. CRuby runs
     File.expand_path on each candidate and stats THAT. */
  if (env && *env) {
    const char *ex = tmpdir_expand(env);
    if (tmpdir_usable(ex)) return ex;
  }
  char *r = sp_str_alloc_raw(5);
  memcpy(r, "/tmp", 4);
  r[4] = '\0';
  sp_str_set_len(r, 4);
  return r;
}

const char *sp_Dir_mktmpdir(const char *prefix) {
  const char *parent = sp_Dir_tmpdir();
  return tmpdir_mkdtemp(prefix, NULL, parent, TMPDIR_RETRIES);
}

const char *sp_Dir_mktmpdir_pps(const char *prefix, const char *parent,
                                const char *suffix, sp_int max_try) {
  return tmpdir_mkdtemp(prefix, suffix, parent,
                        max_try > 0 && max_try < TMPDIR_RETRIES ? (int)max_try
                                                                : TMPDIR_RETRIES);
}
