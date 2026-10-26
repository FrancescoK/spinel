/* Splitting one generated translation unit into several (#4847 C1).

   A large program's generated C is one file, and cc compiles one file on one
   core: campfire's 10 MB took ~50 s while eleven cores sat idle. c_split
   takes the PREPROCESSED unit (cc -E) and writes a shared header plus N
   part files that compile in parallel and link to the same program:

   - types, typedefs, extern declarations and `static inline` functions go to
     the header, as they were, in their original order;
   - every other function keeps one definition, in one part, and loses
     `static`; the header declares it where the definition stood;
   - every file-scope variable is defined once, in part 0, without `static`;
     the header declares it `extern` where the definition stood.

   The header keeps the unit's own order, with each definition replaced by its
   declaration, so everything a later item names is declared before it, as it
   was in the single file. An inline function with a `static` local keeps one
   copy of that local only if it has one definition, so it is demoted to a
   plain function. Anything this reader does not recognise makes it decline
   (returns -1), and the caller compiles the single unit as before.

   The unit keeps the preprocessor's line markers (`# N "file" flags`), and
   each item goes out under the marker in effect where it stood, so a part
   still says which lines came from a system header and which from the .rb.
   Without them every warning cc silences in system headers fires on the
   SDK's declarations in every part (#8579: Apple clang's
   -Wnullability-completeness, 10,000 lines of log for a five-line program),
   and an error in a part names the part instead of the program. The
   markers' include-stack flags (1 and 2) are not replayed, only the
   system-header ones (3 and 4): the items leave the unit's order, and a
   stack that does not match is worth a warning of its own. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "csplit.h"

typedef enum { IT_HDR, IT_FN, IT_VAR, IT_PROTO, IT_MARK } ItemKind;
typedef struct {
  size_t st, en;        /* [st, en) in the text */
  ItemKind kind;
  size_t body;          /* IT_FN: offset of the body's `{` */
  char name[128];
  int keep_inline;      /* IT_FN: stays `static inline` in the header */
  size_t mfile;         /* the line marker in effect at st: its "file" (with
                           the quotes), or 0 when the unit has none */
  size_t mflen;
  int msys;             /* its system-header flags: bit 0 = 3, bit 1 = 4 */
  long mline;           /* the line st is on, as the marker counts */
} Item;

/* Is t[i..] a line marker `# N "file" ...`? (a `#` at the start of a line) */
static int is_marker(const char *t, size_t i, size_t n) {
  if (i >= n || t[i] != '#') return 0;
  i++;
  while (i < n && (t[i] == ' ' || t[i] == '\t')) i++;
  return i < n && t[i] >= '0' && t[i] <= '9';
}

static size_t skip_lit(const char *t, size_t n, size_t i);

/* Read the marker at t[i..] (is_marker said yes) into the current position:
   the file and flags it names, and the line the NEXT line has. Returns the
   offset of the newline ending the marker line (or n). */
static size_t read_marker(const char *t, size_t i, size_t n, size_t *mfile, size_t *mflen, int *msys, long *ln) {
  size_t e = i;
  while (e < n && t[e] != '\n') e++;
  size_t p = i + 1;
  while (p < e && (t[p] == ' ' || t[p] == '\t')) p++;
  long v = 0;
  while (p < e && t[p] >= '0' && t[p] <= '9') v = v * 10 + (t[p++] - '0');
  while (p < e && t[p] == ' ') p++;
  if (p < e && t[p] == '"') {
    size_t q = skip_lit(t, e, p);
    *mfile = p; *mflen = q - p;
    int sys = 0;
    for (size_t r = q; r < e; r++) {
      if (t[r] == '3' && (r + 1 >= e || t[r + 1] == ' ')) sys |= 1;
      else if (t[r] == '4' && (r + 1 >= e || t[r + 1] == ' ')) sys |= 2;
    }
    *msys = sys;
  }
  *ln = v;
  return e;
}

/* Where each item's text goes, with the marker its last line left in
   effect, so a marker is written only where the next item would otherwise
   be claimed by the wrong file or line.
   A system header's items go to a file of their own, included where they
   stood (out_sync). Apple clang's -Wnullability-completeness is decided per
   file, not per marker: once a file holds one pointer with a nullability
   qualifier (the SDK's), every pointer of the file outside a system header
   is warned about, the program's included, and the parts of a large program
   wrote hundreds of MB of those warnings, most of the cc time (#8579). */
typedef struct {
  FILE *f;              /* where the next item goes: main, or side */
  FILE *main, *side;    /* side: the system-header file now open, or NULL */
  const char *dir, *tag;
  int nside, bad;
  size_t mfile, mflen;
  int msys;
  long line;            /* the line the next output line claims, or -1 */
} Out;

static void out_init(Out *o, FILE *f, const char *dir, const char *tag) {
  memset(o, 0, sizeof *o);
  o->f = o->main = f; o->dir = dir; o->tag = tag; o->line = -1;
}

/* Close the system-header file now open: the next item goes to main again */
static void out_side_end(Out *o) {
  if (!o->side) return;
  if (ferror(o->side) | (fclose(o->side) != 0)) o->bad = 1;
  o->side = NULL; o->f = o->main;
  o->mfile = 0; o->line = -1;
}

static void out_sync(Out *o, const char *t, const Item *x) {
  if (!x->mfile) return;   /* a unit without markers: nothing to keep */
  if (x->msys && !o->side && !o->bad) {
    char nm[64], path[4200];
    snprintf(nm, sizeof nm, "sp_sys_%s%d.h", o->tag, o->nside++);
    snprintf(path, sizeof path, "%s/%s", o->dir, nm);
    o->side = fopen(path, "wb");
    if (!o->side) o->bad = 1;
    else {
      fprintf(o->main, "#include \"%s\"\n", nm);
      o->f = o->side; o->mfile = 0; o->line = -1;
    }
  }
  else if (!x->msys && o->side) out_side_end(o);
  if (o->mfile && o->mflen == x->mflen && memcmp(t + o->mfile, t + x->mfile, x->mflen) == 0 &&
      o->msys == x->msys && o->line == x->mline)
    return;
  fprintf(o->f, "# %ld %.*s%s%s\n", x->mline, (int)x->mflen, t + x->mfile,
          (x->msys & 1) ? " 3" : "", (x->msys & 2) ? " 4" : "");
  o->mfile = x->mfile; o->mflen = x->mflen; o->msys = x->msys;
  o->line = x->mline;
}

/* After writing [st, en) of the text plus `extra` newlines: the output's
   line count moved by the range's newlines, unless the range holds a marker
   of its own (a marker inside a declaration, as the preprocessor writes
   where it dropped more than eight blank lines), which puts the count out of
   reach; -1 then makes the next item write its marker. */
static void out_advance(Out *o, const char *t, size_t st, size_t en, int extra) {
  if (o->line < 0) return;
  long nl = 0;
  for (size_t i = st; i < en; i++) {
    if (t[i] != '\n') continue;
    nl++;
    if (is_marker(t, i + 1, en)) { o->line = -1; return; }
  }
  o->line += nl + extra;
}

static int is_idch(char ch) {
  return ch == '_' || (ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || ch == '$';
}

/* skip a string or char literal starting at t[i]; returns the index after it */
static size_t skip_lit(const char *t, size_t n, size_t i) {
  char q = t[i++];
  while (i < n && t[i] != q) { if (t[i] == '\\') i++; i++; }
  return i < n ? i + 1 : n;
}

/* Does [st, en) contain the word `w` outside literals? */
static int has_word(const char *t, size_t st, size_t en, const char *w) {
  size_t wl = strlen(w);
  for (size_t i = st; i < en; ) {
    char ch = t[i];
    if (ch == '"' || ch == '\'') { i = skip_lit(t, en, i); continue; }
    if (is_idch(ch)) {
      size_t s = i;
      while (i < en && is_idch(t[i])) i++;
      if (i - s == wl && memcmp(t + s, w, wl) == 0) return 1;
      continue;
    }
    i++;
  }
  return 0;
}

static size_t skip_group(const char *t, size_t i, size_t en) {
  while (i < en && (t[i] == ' ' || t[i] == '\n' || t[i] == '\t')) i++;
  if (i >= en || t[i] != '(') return i;
  for (int d = 0; i < en; i++) {
    if (t[i] == '"' || t[i] == '\'') { i = skip_lit(t, en, i) - 1; continue; }
    if (t[i] == '(') d++;
    else if (t[i] == ')' && --d == 0) return i + 1;
  }
  return i;
}

/* The first `(` at depth 0 in [st, en) that is not an attribute's or a
   __typeof__'s, or `en`. */
static size_t first_paren(const char *t, size_t st, size_t en) {
  for (size_t i = st; i < en; ) {
    char ch = t[i];
    if (ch == '"' || ch == '\'') { i = skip_lit(t, en, i); continue; }
    if (is_idch(ch)) {
      size_t s = i;
      while (i < en && is_idch(t[i])) i++;
      size_t wl = i - s;
      int skip = (wl == 13 && memcmp(t + s, "__attribute__", 13) == 0) ||
                 (wl == 10 && memcmp(t + s, "__typeof__", 10) == 0) ||
                 (wl == 6 && memcmp(t + s, "typeof", 6) == 0) ||
                 (wl == 7 && memcmp(t + s, "__asm__", 7) == 0) ||
                 (wl == 8 && memcmp(t + s, "_Alignas", 8) == 0);
      if (skip) i = skip_group(t, i, en);
      continue;
    }
    if (ch == '(') return i;
    if (ch == '{' || ch == '=') return en;
    i++;
  }
  return en;
}

/* the identifier ending just before `p` (skipping spaces) */
static void ident_before(const char *t, size_t lo, size_t p, char *out, size_t osz) {
  out[0] = 0;
  while (p > lo && (t[p - 1] == ' ' || t[p - 1] == '\n' || t[p - 1] == '\t')) p--;
  size_t e = p;
  while (p > lo && is_idch(t[p - 1])) p--;
  size_t l = e - p;
  if (l == 0 || l >= osz) return;
  memcpy(out, t + p, l); out[l] = 0;
}

/* Does the word at [w, w+wl) introduce a trailing attribute group? */
static int is_attr_word(const char *w, size_t wl) {
  return (wl == 13 && memcmp(w, "__attribute__", 13) == 0) ||
         (wl == 7 && memcmp(w, "__asm__", 7) == 0) ||
         (wl == 5 && memcmp(w, "__asm", 5) == 0) ||
         (wl == 3 && memcmp(w, "asm", 3) == 0);
}

/* The end of [st, en) with any trailing attribute groups -- `__attribute__
   ((...))`, `__asm__ (...)` -- and the whitespace around them dropped, so
   what is left ends at the declaration's own last character. The system
   headers a program reaches through put a trailing attribute in both places
   this reader decides something from the last character: macOS spells a
   constant `static const uuid_t UUID_NULL __attribute__ ((unused)) = {...}`
   (<uuid/uuid.h>, via <pwd.h>) and a tag `struct __darwin_arm_sve_z_state
   {...} __attribute__((aligned(4)))` (<mach/machine/_structs.h>). Scanned
   forwards, so a `(` inside a string literal is not a paren (#4847). */
static size_t trim_trailing_attrs(const char *t, size_t st, size_t en) {
  size_t keep = st;
  for (size_t i = st; i < en; ) {
    char ch = t[i];
    if (ch == '"' || ch == '\'') { i = skip_lit(t, en, i); keep = i; continue; }
    if (!is_idch(ch)) {
      i++;
      if (ch != ' ' && ch != '\n' && ch != '\t' && ch != '\r') keep = i;
      continue;
    }
    size_t s = i;
    while (i < en && is_idch(t[i])) i++;
    if (is_attr_word(t + s, i - s)) {
      i = skip_group(t, i, en);
      continue;   /* an attribute is not the declaration's own content */
    }
    keep = i;
  }
  return keep;
}

/* The item's leading words, past __extension__. */
static int starts_with_word(const char *t, size_t st, size_t en, const char *w) {
  size_t i = st;
  for (;;) {
    while (i < en && (t[i] == ' ' || t[i] == '\n' || t[i] == '\t')) i++;
    size_t s = i;
    while (i < en && is_idch(t[i])) i++;
    if (i - s == 13 && memcmp(t + s, "__extension__", 13) == 0) continue;
    size_t wl = strlen(w);
    return i - s == wl && memcmp(t + s, w, wl) == 0;
  }
}

/* Emit [st, en) without the storage words `static` (and, with no_inline, the
   inline words), outside literals. */
static void put_stripped(FILE *f, const char *t, size_t st, size_t en, int no_inline) {
  for (size_t i = st; i < en; ) {
    char ch = t[i];
    if (ch == '"' || ch == '\'') { size_t j = skip_lit(t, en, i); fwrite(t + i, 1, j - i, f); i = j; continue; }
    if (is_idch(ch)) {
      size_t s = i;
      while (i < en && is_idch(t[i])) i++;
      size_t wl = i - s;
      int drop = (wl == 6 && memcmp(t + s, "static", 6) == 0);
      if (no_inline)
        drop = drop || (wl == 6 && memcmp(t + s, "inline", 6) == 0) ||
               (wl == 10 && memcmp(t + s, "__inline__", 10) == 0) ||
               (wl == 8 && memcmp(t + s, "__inline", 8) == 0);
      if (no_inline && wl == 13 && memcmp(t + s, "always_inline", 13) == 0) {
        fputs("noinline", f);   /* keep the attribute list well-formed */
        continue;
      }
      if (no_inline && wl == 16 && memcmp(t + s, "SP_ALWAYS_INLINE", 16) == 0) {
        fputs("SP_NOINLINE", f);   /* the sp_compat.h spelling of the same */
        continue;
      }
      if (!drop) fwrite(t + s, 1, wl, f);
      continue;
    }
    fputc(ch, f); i++;
  }
}

/* A declaration's text up to its top-level `=` (the initializer's start), or
   its end. Declines (-1) when it declares more than one name. */
static long decl_cut(const char *t, size_t st, size_t en) {
  int d = 0;
  for (size_t i = st; i < en; ) {
    char ch = t[i];
    if (ch == '"' || ch == '\'') { i = skip_lit(t, en, i); continue; }
    if (ch == '(' || ch == '[' || ch == '{') d++;
    else if (ch == ')' || ch == ']' || ch == '}') d--;
    else if (d == 0 && ch == '=') return (long)i;
    else if (d == 0 && ch == ',') return -1;
    i++;
  }
  return (long)en;
}

/* the first top-level `,` in [st, en), or en */
static size_t top_comma(const char *t, size_t st, size_t en) {
  int d = 0;
  for (size_t i = st; i < en; ) {
    char ch = t[i];
    if (ch == '"' || ch == '\'') { i = skip_lit(t, en, i); continue; }
    if (ch == '(' || ch == '[' || ch == '{') d++;
    else if (ch == ')' || ch == ']' || ch == '}') d--;
    else if (d == 0 && ch == ',') return i;
    i++;
  }
  return en;
}

/* the top-level `=` in [st, en), or en */
static size_t top_eq(const char *t, size_t st, size_t en) {
  int d = 0;
  for (size_t i = st; i < en; ) {
    char ch = t[i];
    if (ch == '"' || ch == '\'') { i = skip_lit(t, en, i); continue; }
    if (ch == '(' || ch == '[' || ch == '{') d++;
    else if (ch == ')' || ch == ']' || ch == '}') d--;
    else if (d == 0 && ch == '=') return i;
    i++;
  }
  return en;
}

/* A file-scope variable declaration [st, en) (ending in `;`), possibly of
   several names: each becomes `extern` in the header and one definition in
   the part, the shared specifiers repeated for every declarator. */
static void put_vars(FILE *h, FILE *part, const char *t, size_t st, size_t en) {
  size_t end = en - 1;   /* before the `;` */
  size_t c1 = top_comma(t, st, end);
  if (c1 >= end) {   /* one declarator, whatever its shape */
    /* An untagged struct or union type is a different type in every
       declaration that spells it: the header's extern and the part's
       definition would disagree. Tag it, define it in the header, and have
       the part name it by the tag. */
    size_t eq = top_eq(t, st, end);
    for (size_t q = st; q < eq; ) {
      if (!is_idch(t[q])) { q++; continue; }
      size_t ws = q;
      while (q < eq && is_idch(t[q])) q++;
      size_t wl = q - ws;
      if (!((wl == 6 && memcmp(t + ws, "struct", 6) == 0) || (wl == 5 && memcmp(t + ws, "union", 5) == 0))) continue;
      size_t r = q;
      while (r < eq && (t[r] == ' ' || t[r] == '\n')) r++;
      if (r >= eq || t[r] != '{') break;   /* tagged: nothing to do */
      int bd = 0; size_t bc = r;
      for (; bc < eq; bc++) { if (t[bc] == '{') bd++; else if (t[bc] == '}' && --bd == 0) break; }
      if (bc >= eq) break;
      static int anon_n = 0;
      int k = anon_n++;
      fputs("extern ", h);
      put_stripped(h, t, st, q, 0); fprintf(h, " sp__csplit_anon%d ", k);
      put_stripped(h, t, r, eq, 0); fputs(";\n", h);
      put_stripped(part, t, st, q, 0); fprintf(part, " sp__csplit_anon%d ", k);
      put_stripped(part, t, bc + 1, en, 0); fputc('\n', part);
      return;
    }
    fputs("extern ", h);
    put_stripped(h, t, st, top_eq(t, st, end), 0);
    fputs(";\n", h);
    put_stripped(part, t, st, en, 0);
    fputc('\n', part);
    return;
  }
  /* the first declarator starts at its name, or at the `*`/`(` before it */
  size_t nm_end = top_eq(t, st, c1);
  { int dd = 0; for (size_t q = st; q < nm_end; q++) {
      if (t[q] == '(') dd++; else if (t[q] == ')') dd--;
      else if (t[q] == '[' && dd == 0) { nm_end = q; break; } } }
  while (nm_end > st && (t[nm_end - 1] == ' ' || t[nm_end - 1] == '\n')) nm_end--;
  size_t ds = nm_end;
  while (ds > st && is_idch(t[ds - 1])) ds--;
  while (ds > st && (t[ds - 1] == '*' || t[ds - 1] == ' ' || t[ds - 1] == '(')) {
    if (t[ds - 1] == ' ') { size_t b = ds - 1; while (b > st && t[b - 1] == ' ') b--; if (b > st && (t[b - 1] == '*' || t[b - 1] == '(')) { ds = b; continue; } break; }
    ds--;
  }
  size_t ps = ds;   /* the specifiers are [st, ps) */
  size_t a = ds;
  for (;;) {
    size_t b = top_comma(t, a, end);
    size_t e = top_eq(t, a, b);
    fputs("extern ", h);
    put_stripped(h, t, st, ps, 0); fputc(' ', h);
    fwrite(t + a, 1, e - a, h); fputs(";\n", h);
    put_stripped(part, t, st, ps, 0); fputc(' ', part);
    fwrite(t + a, 1, b - a, part); fputs(";\n", part);
    if (b >= end) break;
    a = b + 1;
  }
}

/* A function's share of the parts' work: its bytes without the line markers
   and blank lines, which the preprocessor writes in proportion to the
   statements (one marker per statement from the .rb) rather than to the
   code. Counted with them, a statement-dense main body outweighed the rest
   and the parts came out uneven, one of them near empty. */
static size_t fn_weight(const char *t, size_t st, size_t en) {
  size_t w = 0;
  for (size_t i = st; i < en; ) {
    size_t e = i;
    while (e < en && t[e] != '\n') e++;
    if (e > i && !is_marker(t, i, en)) w += e - i + 1;
    i = e + 1;
  }
  return w;
}

static int cmpstr(const void *a, const void *b) {
  return strcmp(*(const char *const *)a, *(const char *const *)b);
}

int c_split(const char *pre_path, const char *out_dir, int nparts,
            char (*part_paths)[4096], char *hdr_path, size_t hdr_sz) {
  FILE *in = fopen(pre_path, "rb");
  if (!in) return -1;
  fseek(in, 0, SEEK_END);
  long fl = ftell(in);
  fseek(in, 0, SEEK_SET);
  if (fl <= 0) { fclose(in); return -1; }
  char *t = malloc((size_t)fl + 1);
  size_t n = fread(t, 1, (size_t)fl, in);
  fclose(in);
  t[n] = 0;

  Item *it = NULL; int nit = 0, cap = 0;
  int ok = 1;
  size_t i = 0;
  while (i < n && ok) {
    while (i < n && (t[i] == ' ' || t[i] == '\n' || t[i] == '\t' || t[i] == '\r')) i++;
    if (i >= n) break;
    if (nit == cap) { cap = cap ? cap * 2 : 4096; it = realloc(it, sizeof *it * (size_t)cap); }
    Item *x = &it[nit];
    memset(x, 0, sizeof *x);
    x->st = i;
    if (t[i] == '#') {   /* a line marker, or a directive line cc -E kept (#pragma) */
      int mark = is_marker(t, i, n);
      while (i < n && t[i] != '\n') i++;
      x->en = i; x->kind = mark ? IT_MARK : IT_HDR; nit++;
      continue;
    }
    int d = 0;
    size_t en = 0, body = 0;
    for (; i < n; ) {
      char ch = t[i];
      if (ch == '"' || ch == '\'') { i = skip_lit(t, n, i); continue; }
      if (ch == '(' || ch == '[') d++;
      else if (ch == ')' || ch == ']') d--;
      else if (ch == '{') {
        if (d == 0 && !body) {
          size_t p = i;
          while (p > x->st && (t[p - 1] == ' ' || t[p - 1] == '\n' || t[p - 1] == '\t')) p--;
          if (p > x->st && t[p - 1] == ')' && first_paren(t, x->st, i) < i &&
              !starts_with_word(t, x->st, i, "typedef") && !starts_with_word(t, x->st, i, "struct") &&
              !starts_with_word(t, x->st, i, "union") && !starts_with_word(t, x->st, i, "enum")) {
            /* a function body: through its matching brace */
            body = i;
            int bd = 0;
            for (; i < n; ) {
              char c2 = t[i];
              if (c2 == '"' || c2 == '\'') { i = skip_lit(t, n, i); continue; }
              if (c2 == '{') bd++;
              else if (c2 == '}' && --bd == 0) { i++; break; }
              i++;
            }
            en = i;
            break;
          }
        }
        d++;
      }
      else if (ch == '}') d--;
      else if (ch == ';' && d == 0) { i++; en = i; break; }
      i++;
    }
    if (!en) { ok = 0; break; }
    x->en = en;
    x->kind = IT_PROTO;   /* a declaration, sorted below, unless named here */
    if (body) {
      x->kind = IT_FN; x->body = body;
      size_t fp = first_paren(t, x->st, body);
      ident_before(t, x->st, fp, x->name, sizeof x->name);
      if (!x->name[0]) { ok = 0; break; }
      int inl = has_word(t, x->st, fp, "inline") || has_word(t, x->st, fp, "__inline__") ||
                has_word(t, x->st, fp, "__inline") || has_word(t, x->st, body, "always_inline") ||
                has_word(t, x->st, body, "SP_ALWAYS_INLINE");
      /* a static local needs the single definition; 2 marks it */
      x->keep_inline = has_word(t, body, en, "static") ? 2 : inl;
    }
    else if (starts_with_word(t, x->st, en, "typedef") || starts_with_word(t, x->st, en, "extern") ||
             starts_with_word(t, x->st, en, "_Static_assert")) {
      x->kind = IT_HDR;
    }
    else if (starts_with_word(t, x->st, en, "struct") || starts_with_word(t, x->st, en, "union") ||
             starts_with_word(t, x->st, en, "enum")) {
      /* `struct X { ... };` or `struct X;` declares a tag; anything with a
         declarator after it (`struct X x;`) is a variable */
      size_t p = trim_trailing_attrs(t, x->st, en - 1);   /* before the `;` */
      int words = 0;
      for (size_t q = x->st; q < en; ) {
        if (t[q] == '"' || t[q] == '\'') { q = skip_lit(t, en, q); continue; }
        if (is_idch(t[q])) { words++; while (q < en && is_idch(t[q])) q++; }
        else q++;
      }
      if ((p > x->st && t[p - 1] == '}') || words <= 2) x->kind = IT_HDR;
      else x->kind = IT_PROTO;   /* sorted below: a prototype or a variable */
    }
    if (!body && x->kind == IT_PROTO) {
      size_t fp = first_paren(t, x->st, en);
      size_t q = fp + 1;
      while (q < en && (t[q] == ' ' || t[q] == '\n')) q++;
      long cut = decl_cut(t, x->st, en);
      if (fp < en && (cut < 0 || (size_t)cut == en) && t[q] != '*') x->kind = IT_PROTO;
      else x->kind = IT_VAR;
    }
    if (x->kind == IT_PROTO) {
      size_t fp = first_paren(t, x->st, en);
      ident_before(t, x->st, fp, x->name, sizeof x->name);
      /* a prototype that says inline makes the function inline wherever it
         is defined (keep_inline here: "declared inline") */
      x->keep_inline = has_word(t, x->st, en, "inline") || has_word(t, x->st, en, "__inline__") ||
                       has_word(t, x->st, en, "__inline") || has_word(t, x->st, en, "always_inline") ||
                       has_word(t, x->st, en, "SP_ALWAYS_INLINE");
    }
    if (x->kind == IT_VAR && !x->name[0]) {
      long cut = decl_cut(t, x->st, en);
      if (cut < 0) cut = (long)top_comma(t, x->st, en);   /* the first of several */
      /* the declarator's name: the last identifier before `[`, `=` or `;` */
      size_t lim = (size_t)cut;
      int dd = 0;
      for (size_t q = x->st; q < lim; q++) {
        if (t[q] == '(' ) dd++;
        else if (t[q] == ')') dd--;
        else if (t[q] == '[' && dd == 0) { lim = q; break; }
      }
      if (lim > x->st && t[lim - 1] == ';') lim--;
      /* a pointer to function names itself inside `(*name)` */
      for (size_t q = x->st; q + 1 < lim; q++) {
        if (t[q] != '(' || t[q + 1] != '*') continue;
        size_t r = q + 2;
        while (r < lim && (t[r] == ' ' || t[r] == '*')) r++;
        size_t e = r;
        while (e < lim && is_idch(t[e])) e++;
        if (e > r && e - r < sizeof x->name) { memcpy(x->name, t + r, e - r); x->name[e - r] = 0; }
        break;
      }
      if (!x->name[0]) ident_before(t, x->st, trim_trailing_attrs(t, x->st, lim), x->name, sizeof x->name);
      if (!x->name[0]) { ok = 0; break; }
    }
    nit++;
  }
  if (!ok) {
    free(t); free(it); return -1;
  }

  /* The line marker in effect at each item's start: one walk over the text,
     counting lines and reading each marker where it stands (a marker names
     the line that follows it). */
  {
    size_t mfile = 0, mflen = 0, pos = 0;
    int msys = 0;
    long ln = 1;
    if (is_marker(t, 0, n)) { pos = read_marker(t, 0, n, &mfile, &mflen, &msys, &ln); if (pos < n) pos++; }
    for (int k = 0; k < nit; k++) {
      while (pos < it[k].st) {
        if (t[pos] == '\n') {
          ln++; pos++;
          if (is_marker(t, pos, n)) { pos = read_marker(t, pos, n, &mfile, &mflen, &msys, &ln); if (pos < n) pos++; }
          continue;
        }
        pos++;
      }
      it[k].mfile = mfile; it[k].mflen = mflen; it[k].msys = msys; it[k].mline = ln;
    }
  }

  /* A function is inline when its definition or any prototype says so,
     unless a static local needs its one definition. */
  {
    int np2 = 0;
    const char **pin = malloc(sizeof(char *) * (size_t)(nit + 1));
    for (int k = 0; k < nit; k++) if (it[k].kind == IT_PROTO && it[k].keep_inline) pin[np2++] = it[k].name;
    qsort(pin, (size_t)np2, sizeof *pin, cmpstr);
    for (int k = 0; k < nit; k++) {
      if (it[k].kind != IT_FN) continue;
      if (it[k].keep_inline == 2) { it[k].keep_inline = 0; continue; }
      const char *key = it[k].name;
      if (!it[k].keep_inline && bsearch(&key, pin, (size_t)np2, sizeof *pin, cmpstr)) it[k].keep_inline = 1;
    }
    free(pin);
  }
  /* A name kept static inline keeps its prototypes as written; every other
     function's prototypes lose `static` and any inline word. */
  int nfn = 0; size_t fn_bytes = 0;
  for (int k = 0; k < nit; k++)
    if (it[k].kind == IT_FN && !it[k].keep_inline) { nfn++; fn_bytes += fn_weight(t, it[k].st, it[k].en); }
  /* sorted names of the inline-kept functions, for the prototype rule */
  int ninl = 0;
  const char **inl = malloc(sizeof(char *) * (size_t)(nit + 1));
  for (int k = 0; k < nit; k++) if (it[k].kind == IT_FN && it[k].keep_inline) inl[ninl++] = it[k].name;
  qsort(inl, (size_t)ninl, sizeof *inl, cmpstr);

  snprintf(hdr_path, hdr_sz, "%s/sp_split.h", out_dir);
  FILE *h = fopen(hdr_path, "wb");
  if (!h) { free(t); free(it); free(inl); return -1; }
  FILE **pf = calloc((size_t)nparts, sizeof(FILE *));
  for (int p = 0; p < nparts; p++) {
    snprintf(part_paths[p], 4096, "%s/sp_part%d.c", out_dir, p);
    pf[p] = fopen(part_paths[p], "wb");
    if (!pf[p]) { ok = 0; break; }
    fprintf(pf[p], "#include \"sp_split.h\"\n");
  }
  if (!ok) {
    fclose(h);
    for (int p = 0; p < nparts; p++) if (pf[p]) fclose(pf[p]);
    free(pf); free(t); free(it); free(inl);
    return -1;
  }
  size_t per = fn_bytes / (size_t)nparts + 1, acc = 0;
  int cur = 0;
  Out oh;
  out_init(&oh, h, out_dir, "h");
  Out *op = calloc((size_t)nparts, sizeof(Out));
  char (*ptag)[16] = calloc((size_t)nparts, sizeof *ptag);
  for (int p = 0; p < nparts; p++) {
    snprintf(ptag[p], sizeof ptag[p], "p%d_", p);
    out_init(&op[p], pf[p], out_dir, ptag[p]);
  }
  for (int k = 0; k < nit; k++) {
    Item *x = &it[k];
    switch (x->kind) {
      case IT_MARK:
        break;   /* replayed where the items it covered go out */
      case IT_HDR:
        out_sync(&oh, t, x);
        fwrite(t + x->st, 1, x->en - x->st, oh.f); fputc('\n', oh.f);
        out_advance(&oh, t, x->st, x->en, 1);
        break;
      case IT_PROTO: {
        const char *key = x->name;
        int keep = bsearch(&key, inl, (size_t)ninl, sizeof *inl, cmpstr) != NULL;
        out_sync(&oh, t, x);
        if (keep) fwrite(t + x->st, 1, x->en - x->st, oh.f);
        else put_stripped(oh.f, t, x->st, x->en, 1);
        fputc('\n', oh.f);
        out_advance(&oh, t, x->st, x->en, 1);
        break;
      }
      case IT_VAR:
        out_sync(&oh, t, x);
        out_sync(&op[0], t, x);
        put_vars(oh.f, op[0].f, t, x->st, x->en);
        oh.line = -1; op[0].line = -1;   /* rewritten: the line count is not the text's */
        break;
      case IT_FN:
        if (x->keep_inline) {
          out_sync(&oh, t, x);
          fwrite(t + x->st, 1, x->en - x->st, oh.f); fputc('\n', oh.f);
          out_advance(&oh, t, x->st, x->en, 1);
        }
        else {
          out_sync(&oh, t, x);
          put_stripped(oh.f, t, x->st, x->body, 1);
          fputs(";\n", oh.f);
          out_advance(&oh, t, x->st, x->body, 1);
          /* the storage words go from the declaration only: the body's own
             `static` locals stay static */
          out_sync(&op[cur], t, x);
          put_stripped(op[cur].f, t, x->st, x->body, 1);
          fwrite(t + x->body, 1, x->en - x->body, op[cur].f);
          fputc('\n', op[cur].f);
          out_advance(&op[cur], t, x->st, x->en, 1);
          acc += fn_weight(t, x->st, x->en);
          if (acc >= per * (size_t)(cur + 1) && cur < nparts - 1) cur++;
        }
        break;
    }
  }
  /* a write that failed (a full disk) leaves a truncated header or part,
     which would compile into errors that name no cause: the split is
     abandoned instead, saying why (#9267) */
  out_side_end(&oh);
  int bad = oh.bad | ferror(h) | (fclose(h) != 0);
  const char *bad_path = bad ? hdr_path : NULL;
  for (int p = 0; p < nparts; p++) {
    out_side_end(&op[p]);
    if ((op[p].bad | ferror(pf[p]) | (fclose(pf[p]) != 0)) && !bad_path) bad_path = part_paths[p];
  }
  free(op); free(ptag); free(pf); free(t); free(it); free(inl);
  if (bad_path) {
    fprintf(stderr, "spinel: writing %s failed (%s); compiling the C as one unit instead\n", bad_path, strerror(errno));
    return -1;
  }
  return nparts;
}
