/* Splitting one generated translation unit into several (#4847 C1).

   A large program's generated C is one file, and cc compiles one file on one
   core: campfire's 10 MB took ~50 s while eleven cores sat idle. c_split
   takes the PREPROCESSED unit (cc -E -P) and writes a shared header plus N
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
   (returns -1), and the caller compiles the single unit as before. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "csplit.h"

typedef enum { IT_HDR, IT_FN, IT_VAR, IT_PROTO } ItemKind;
typedef struct {
  size_t st, en;        /* [st, en) in the text */
  ItemKind kind;
  size_t body;          /* IT_FN: offset of the body's `{` */
  char name[128];
  int keep_inline;      /* IT_FN: stays `static inline` in the header */
} Item;

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
      if (skip) {
        while (i < en && (t[i] == ' ' || t[i] == '\n' || t[i] == '\t')) i++;
        if (i < en && t[i] == '(') {
          int d = 0;
          for (; i < en; i++) {
            if (t[i] == '"' || t[i] == '\'') { i = skip_lit(t, en, i) - 1; continue; }
            if (t[i] == '(') d++;
            else if (t[i] == ')' && --d == 0) { i++; break; }
          }
        }
      }
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
    if (t[i] == '#') {   /* a directive line cc -E -P kept (#pragma) */
      while (i < n && t[i] != '\n') i++;
      x->en = i; x->kind = IT_HDR; nit++;
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
      size_t p = en - 1;   /* the `;` */
      while (p > x->st && (t[p - 1] == ' ' || t[p - 1] == '\n' || t[p - 1] == '\t')) p--;
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
      if (!x->name[0]) ident_before(t, x->st, lim, x->name, sizeof x->name);
      if (!x->name[0]) { ok = 0; break; }
    }
    nit++;
  }
  if (!ok) {
    if (getenv("SPINEL_SPLIT_DEBUG"))
      fprintf(stderr, "c_split: declined at item %d: %.200s\n", nit, nit < cap ? t + it[nit].st : "");
    free(t); free(it); return -1;
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
    if (it[k].kind == IT_FN && !it[k].keep_inline) { nfn++; fn_bytes += it[k].en - it[k].st; }
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
  for (int k = 0; k < nit; k++) {
    Item *x = &it[k];
    switch (x->kind) {
      case IT_HDR:
        fwrite(t + x->st, 1, x->en - x->st, h); fputc('\n', h);
        break;
      case IT_PROTO: {
        const char *key = x->name;
        int keep = bsearch(&key, inl, (size_t)ninl, sizeof *inl, cmpstr) != NULL;
        if (keep) fwrite(t + x->st, 1, x->en - x->st, h);
        else put_stripped(h, t, x->st, x->en, 1);
        fputc('\n', h);
        break;
      }
      case IT_VAR:
        put_vars(h, pf[0], t, x->st, x->en);
        break;
      case IT_FN:
        if (x->keep_inline) {
          fwrite(t + x->st, 1, x->en - x->st, h); fputc('\n', h);
        }
        else {
          put_stripped(h, t, x->st, x->body, 1);
          fputs(";\n", h);
          /* the storage words go from the declaration only: the body's own
             `static` locals stay static */
          put_stripped(pf[cur], t, x->st, x->body, 1);
          fwrite(t + x->body, 1, x->en - x->body, pf[cur]);
          fputc('\n', pf[cur]);
          acc += x->en - x->st;
          if (acc >= per * (size_t)(cur + 1) && cur < nparts - 1) cur++;
        }
        break;
    }
  }
  fclose(h);
  for (int p = 0; p < nparts; p++) fclose(pf[p]);
  free(pf); free(t); free(it); free(inl);
  return nparts;
}
