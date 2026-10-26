/* Compile-time values and the operations on them (ct_value.h). */
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ct_value.h"

static void *mv_alloc(void *p, size_t n) {
  void *r = realloc(p, n);
  if (!r) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  return r;
}

void mvb_putn(MvBuf *b, const char *s, size_t n) {
  if (b->len + n + 1 > b->cap) {
    b->cap = (b->len + n + 1) * 2 + 64;
    b->p = mv_alloc(b->p, b->cap);
  }
  memcpy(b->p + b->len, s, n);
  b->len += n;
  b->p[b->len] = 0;
}

void mvb_puts(MvBuf *b, const char *s) { mvb_putn(b, s, strlen(s)); }

Mv mv_nil(void) { Mv v; memset(&v, 0, sizeof v); v.k = MV_NIL; return v; }

Mv mv_str(const char *s, size_t n, MvKind k) {
  Mv v; memset(&v, 0, sizeof v); v.k = k;
  v.s = mv_alloc(NULL, n + 1); memcpy(v.s, s, n); v.s[n] = 0;
  return v;
}

int mv_truthy(Mv v) { return v.k != MV_NIL && v.k != MV_FALSE && v.k != MV_UNDEF; }

Mv mv_undef(void) { Mv v; memset(&v, 0, sizeof v); v.k = MV_UNDEF; return v; }

void mv_to_s(Mv v, MvBuf *b) {
  char tmp[32];
  switch (v.k) {
  case MV_NIL: break;
  case MV_TRUE: mvb_puts(b, "true"); break;
  case MV_FALSE: mvb_puts(b, "false"); break;
  case MV_INT: snprintf(tmp, sizeof tmp, "%lld", v.i); mvb_puts(b, tmp); break;
  case MV_STR: case MV_SYM: mvb_puts(b, v.s); break;
  default: break;
  }
}

int mv_sym_plain(const char *s) {
  if (!*s) return 0;
  if (!(isalpha((unsigned char)s[0]) || s[0] == '_')) return 0;
  for (const char *p = s; *p; p++) {
    if (isalnum((unsigned char)*p) || *p == '_') continue;
    if ((*p == '?' || *p == '!' || *p == '=') && p[1] == 0) continue;
    return 0;
  }
  return 1;
}

void mv_quote(const char *s, MvBuf *b) {
  mvb_puts(b, "\"");
  for (const char *p = s; *p; p++) {
    char e[8];
    unsigned char ch = (unsigned char)*p;
    if (ch == '"' || ch == '\\' || ch == '#') { e[0] = '\\'; e[1] = (char)ch; e[2] = 0; }
    else if (ch == '\n') strcpy(e, "\\n");
    else if (ch == '\t') strcpy(e, "\\t");
    else if (ch < 0x20) snprintf(e, sizeof e, "\\x%02x", ch);
    else { e[0] = (char)ch; e[1] = 0; }
    mvb_puts(b, e);
  }
  mvb_puts(b, "\"");
}

void mv_inspect(Mv v, MvBuf *b) {
  switch (v.k) {
  case MV_NIL: mvb_puts(b, "nil"); break;
  case MV_STR: mv_quote(v.s, b); break;
  case MV_SYM:
    mvb_puts(b, ":");
    if (mv_sym_plain(v.s)) mvb_puts(b, v.s); else mv_quote(v.s, b);
    break;
  case MV_ARR:
    mvb_puts(b, "[");
    for (int i = 0; i < v.n; i++) { if (i) mvb_puts(b, ", "); mv_inspect(v.a[i], b); }
    mvb_puts(b, "]");
    break;
  default: mv_to_s(v, b); break;
  }
}

/* It quotes for Ruby source (`"\#"`, `"\x1b"`), which reads back as the
   same value but is not the text CRuby prints, and quotes every operator
   Symbol (`:"+"`), so a value whose inspect becomes program DATA (output, a
   constant) is followed only when it is plain: printable ASCII Strings with
   nothing to escape, Symbols spelled as identifiers, integers, nil, booleans
   and Arrays of them. */
int mv_inspect_exact(Mv v) {
  switch (v.k) {
  case MV_NIL: case MV_TRUE: case MV_FALSE: case MV_INT: return 1;
  case MV_STR:
    for (const char *p = v.s; *p; p++) {
      unsigned char ch = (unsigned char)*p;
      if (ch < 0x20 || ch > 0x7e || ch == '"' || ch == '\\' || ch == '#') return 0;
    }
    return 1;
  case MV_SYM: return mv_sym_plain(v.s);
  case MV_ARR:
    for (int i = 0; i < v.n; i++) if (!mv_inspect_exact(v.a[i])) return 0;
    return 1;
  default: return 0;
  }
}

int mv_eq(Mv a, Mv b) {
  if (a.k != b.k) return 0;
  switch (a.k) {
  case MV_INT: return a.i == b.i;
  case MV_STR: case MV_SYM: return strcmp(a.s, b.s) == 0;
  case MV_ARR:
    if (a.n != b.n) return 0;
    for (int i = 0; i < a.n; i++) if (!mv_eq(a.a[i], b.a[i])) return 0;
    return 1;
  default: return 1;
  }
}

int mv_ascii(const char *s) {
  for (; *s; s++) if ((unsigned char)*s >= 0x80) return 0;
  return 1;
}

static int mv_pat_class(const char *p, const char *e, MvPat *pt) {
  /* p after the `[`; e the end of the pattern */
  int neg = 0;
  memset(pt->set, 0, sizeof pt->set);
  if (p < e && *p == '^') { neg = 1; p++; }
  int first = 1;
  while (p < e && (*p != ']' || first)) {
    unsigned char ch;
    if (*p == '\\') {
      if (p + 1 >= e || isalnum((unsigned char)p[1])) return -1;
      ch = (unsigned char)p[1]; p += 2;
    }
    else if (*p == '[' || (*p == '&' && p + 1 < e && p[1] == '&')) return -1;   /* nested, or an intersection */
    else ch = (unsigned char)*p++;
    if (ch >= 0x80) return -1;
    if (p + 1 < e && *p == '-' && p[1] != ']') {
      unsigned char hi;
      if (p[1] == '\\') {
        if (p + 2 >= e || isalnum((unsigned char)p[2])) return -1;
        hi = (unsigned char)p[2]; p += 3;
      }
      else { hi = (unsigned char)p[1]; p += 2; }
      if (hi < ch || hi >= 0x80) return -1;
      for (unsigned x = ch; x <= hi; x++) pt->set[x] = 1;
    }
    else pt->set[ch] = 1;
    first = 0;
  }
  if (p >= e) return -1;
  if (neg) for (int x = 0; x < 256; x++) pt->set[x] = !pt->set[x];
  return 0;
}

int mv_pat_regexp(const char *p, const char *e, MvPat *pt) {
  memset(pt, 0, sizeof *pt);
  if (p >= e) return 0;
  const char *q = NULL;
  if (*p == '[') {
    const char *r = p + 1;
    int first = 1;
    while (r < e && (*r != ']' || first)) { if (*r == '\\') r++; r++; first = 0; }
    if (r >= e) return 0;
    if (mv_pat_class(p + 1, e, pt) < 0) return 0;
    q = r + 1;
  }
  else if (*p == '\\' && p + 1 < e && !isalnum((unsigned char)p[1]) && (unsigned char)p[1] < 0x80) {
    pt->set[(unsigned char)p[1]] = 1; q = p + 2;
  }
  if (q) {
    if (q < e && *q == '+') { pt->plus = 1; q++; }
    return q == e;
  }
  /* a run of literal characters */
  for (const char *r = p; r < e; r++)
    if (strchr(".^$|()?*+{}[]\\/#", *r) || (unsigned char)*r >= 0x80) return 0;
  pt->lit = 1; pt->text = p; pt->tn = (size_t)(e - p);
  return 1;
}

size_t mv_pat_at(const MvPat *pt, const char *s) {
  if (pt->lit) return strncmp(s, pt->text, pt->tn) == 0 ? pt->tn : 0;
  size_t n = 0;
  while (s[n] && pt->set[(unsigned char)s[n]]) { n++; if (!pt->plus) break; }
  return n;
}
