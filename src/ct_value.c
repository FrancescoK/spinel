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
static void *mv_calloc(size_t n, size_t size) {
  void *r = calloc(n, size);
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

/* ---- the methods the evaluators run on a value ---- */

int mv_sub(Mv r, const MvPat *pt, const char *rep, int all, Mv *out) {
  if (r.k != MV_STR || !mv_ascii(r.s) || strchr(rep, '\\')) return 0;
  MvBuf b = {0};
  int did = 0;
  for (const char *p = r.s; *p; ) {
    size_t m = (all || !did) ? mv_pat_at(pt, p) : 0;
    if (m) { mvb_puts(&b, rep); p += m; did = 1; }
    else mvb_putn(&b, p++, 1);
  }
  *out = mv_str(b.p ? b.p : "", b.len, MV_STR); free(b.p);
  return 1;
}

typedef enum {
  MVOP_NIL_P, MVOP_NOT, MVOP_TO_S, MVOP_TO_SYM, MVOP_INSPECT, MVOP_CASE, MVOP_COMPACT, MVOP_REVERSE,
  MVOP_SIZE, MVOP_FIRST, MVOP_LAST, MVOP_JOIN, MVOP_CMP, MVOP_EQ, MVOP_ADD, MVOP_MUL, MVOP_POW, MVOP_SUB, MVOP_AREF
} MvOp;
static const struct { const char *name; int argc; MvOp op; } mv_ops[] = {
  { "nil?", 0, MVOP_NIL_P }, { "!", 0, MVOP_NOT }, { "to_s", 0, MVOP_TO_S }, { "to_sym", 0, MVOP_TO_SYM },
  { "inspect", 0, MVOP_INSPECT }, { "downcase", 0, MVOP_CASE }, { "upcase", 0, MVOP_CASE },
  { "capitalize", 0, MVOP_CASE }, { "compact", 0, MVOP_COMPACT }, { "reverse", 0, MVOP_REVERSE },
  { "size", 0, MVOP_SIZE }, { "length", 0, MVOP_SIZE }, { "first", 0, MVOP_FIRST }, { "last", 0, MVOP_LAST },
  { "join", 0, MVOP_JOIN }, { "join", 1, MVOP_JOIN },
  { "<", 1, MVOP_CMP }, { ">", 1, MVOP_CMP }, { "<=", 1, MVOP_CMP }, { ">=", 1, MVOP_CMP },
  { "==", 1, MVOP_EQ }, { "!=", 1, MVOP_EQ }, { "+", 1, MVOP_ADD }, { "*", 1, MVOP_MUL }, { "**", 1, MVOP_POW },
  { "-", 1, MVOP_SUB }, { "[]", 1, MVOP_AREF },
};

/* r's elements joined, with sep between them (NULL: none); 0 for a nested
   Array, which CRuby flattens */
static int mv_join(Mv r, const char *sep, Mv *out) {
  for (int i = 0; i < r.n; i++) if (r.a[i].k == MV_ARR) return 0;
  MvBuf b = {0};
  for (int i = 0; i < r.n; i++) {
    if (i && sep) mvb_puts(&b, sep);
    mv_to_s(r.a[i], &b);
  }
  *out = mv_str(b.p ? b.p : "", b.len, MV_STR); free(b.p);
  return 1;
}

int mv_call(const char *name, Mv r, int argc, Mv a0, Mv *out) {
  int op = -1;
  for (size_t i = 0; i < sizeof mv_ops / sizeof mv_ops[0] && op < 0; i++)
    if (mv_ops[i].argc == argc && strcmp(mv_ops[i].name, name) == 0) op = (int)mv_ops[i].op;
  switch (op) {
  case MVOP_NIL_P: *out = mv_nil(); out->k = r.k == MV_NIL ? MV_TRUE : MV_FALSE; return 1;
  case MVOP_NOT: *out = mv_nil(); out->k = mv_truthy(r) ? MV_FALSE : MV_TRUE; return 1;
  case MVOP_TO_S: {
    if (r.k == MV_ARR) return 0;
    if (r.k == MV_STR) { *out = r; return 1; }   /* String#to_s answers the String itself */
    MvBuf b = {0}; mv_to_s(r, &b); *out = mv_str(b.p ? b.p : "", b.len, MV_STR); free(b.p);
    return 1;
  }
  case MVOP_TO_SYM:
    if (r.k != MV_STR && r.k != MV_SYM) return 0;
    *out = r; out->k = MV_SYM; out->frozen = out->lit = 0;
    return 1;
  case MVOP_INSPECT: {
    if (!mv_inspect_exact(r)) return 0;
    MvBuf b = {0}; mv_inspect(r, &b); *out = mv_str(b.p ? b.p : "", b.len, MV_STR); free(b.p);
    return 1;
  }
  case MVOP_CASE:
    /* case mapping and length only over ASCII: CRuby's are by character,
       with Unicode case rules */
    if ((r.k != MV_STR && r.k != MV_SYM) || !mv_ascii(r.s)) return 0;
    *out = mv_str(r.s, strlen(r.s), r.k);
    for (char *p = out->s; *p; p++) {
      if (name[0] == 'd') *p = (char)tolower((unsigned char)*p);
      else if (name[0] == 'u') *p = (char)toupper((unsigned char)*p);
      else *p = (char)(p == out->s ? toupper((unsigned char)*p) : tolower((unsigned char)*p));
    }
    return 1;
  case MVOP_COMPACT: {
    if (r.k != MV_ARR) return 0;
    Mv v = r; v.a = mv_calloc((size_t)r.n + 1, sizeof(Mv)); v.n = 0;
    for (int i = 0; i < r.n; i++) if (r.a[i].k != MV_NIL) v.a[v.n++] = r.a[i];
    *out = v;
    return 1;
  }
  case MVOP_REVERSE: {
    if (r.k != MV_ARR) return 0;
    Mv v = r; v.a = mv_calloc((size_t)r.n + 1, sizeof(Mv));
    for (int i = 0; i < r.n; i++) v.a[i] = r.a[r.n - i - 1];
    *out = v;
    return 1;
  }
  case MVOP_SIZE:
    if (r.k == MV_NIL) return 0;
    *out = mv_nil(); out->k = MV_INT;
    out->i = r.k == MV_ARR ? r.n : (r.k == MV_STR || r.k == MV_SYM) ? (long long)strlen(r.s) : 0;
    return r.k == MV_ARR || ((r.k == MV_STR || r.k == MV_SYM) && mv_ascii(r.s));
  case MVOP_FIRST: case MVOP_LAST:
    if (r.k != MV_ARR) return 0;
    *out = r.n == 0 ? mv_nil() : r.a[op == MVOP_FIRST ? 0 : r.n - 1];
    return 1;
  case MVOP_JOIN:
    if (r.k != MV_ARR || (argc == 1 && a0.k != MV_STR && a0.k != MV_NIL)) return 0;
    return mv_join(r, argc == 1 && a0.k == MV_STR ? a0.s : NULL, out);
  case MVOP_CMP: {
    if (r.k != MV_INT || a0.k != MV_INT) return 0;
    int t = name[0] == '<' ? (name[1] ? r.i <= a0.i : r.i < a0.i) : (name[1] ? r.i >= a0.i : r.i > a0.i);
    *out = mv_nil(); out->k = t ? MV_TRUE : MV_FALSE;
    return 1;
  }
  case MVOP_EQ: {
    int eq = mv_eq(r, a0);
    *out = mv_nil(); out->k = (eq == (name[0] == '=')) ? MV_TRUE : MV_FALSE;
    return 1;
  }
  /* an Integer result past 64 bits is a Bignum in CRuby: not followed */
  case MVOP_ADD:
    if (r.k == MV_INT && a0.k == MV_INT) { *out = r; return !__builtin_add_overflow(r.i, a0.i, &out->i); }
    if (r.k == MV_STR && a0.k == MV_STR) {
      MvBuf b = {0}; mvb_puts(&b, r.s); mvb_puts(&b, a0.s);
      *out = mv_str(b.p, b.len, MV_STR); free(b.p);
      return 1;
    }
    if (r.k == MV_ARR && a0.k == MV_ARR) {
      Mv v = r; v.a = mv_calloc((size_t)r.n + (size_t)a0.n + 1, sizeof(Mv)); v.n = 0;
      for (int i = 0; i < r.n; i++) v.a[v.n++] = r.a[i];
      for (int i = 0; i < a0.n; i++) v.a[v.n++] = a0.a[i];
      *out = v;
      return 1;
    }
    return 0;
  case MVOP_MUL:
    if (r.k != MV_INT || a0.k != MV_INT) return 0;
    *out = r;
    return !__builtin_mul_overflow(r.i, a0.i, &out->i);
  case MVOP_POW: {
    if (r.k != MV_INT || a0.k != MV_INT || a0.i < 0 || a0.i >= 64) return 0;
    long long v = 1; int of = 0;
    for (long long q = 0; q < a0.i && !of; q++) of = __builtin_mul_overflow(v, r.i, &v);
    *out = r; out->i = v;
    return !of;
  }
  case MVOP_SUB:
    if (r.k != MV_INT || a0.k != MV_INT) return 0;
    *out = r;
    return !__builtin_sub_overflow(r.i, a0.i, &out->i);
  case MVOP_AREF: {
    if (r.k != MV_ARR || a0.k != MV_INT) return 0;
    long long ix = a0.i < 0 ? r.n + a0.i : a0.i;
    *out = (ix >= 0 && ix < r.n) ? r.a[ix] : mv_nil();
    return 1;
  }
  default: return 0;
  }
}
