/* sp_json.c -- JSON.generate serialization, split out of spinel_rt.h.

   This is a standalone translation unit: it owns no typed-array/hash structs.
   It reaches the generated program's containers only through the generic hooks
   in sp_gc.h (sp_json_kind/len/aref/hpair + sp_sym_name_fn), which the generated
   TU installs at startup. Result strings are built in an off-heap scratch buffer
   and finalized onto the shared GC string heap (sp_alloc.h), so a nested
   allocation can't free a piece already copied in. */
#include "spinel/runtime.h"  /* sp_RbVal, SP_TAG_*, hooks, sp_str_alloc, sp_int_to_s, sp_float_to_s */
#include "sp_json.h"          /* this package's sp_json_str / sp_json_val API */
#include <string.h>
#include <stdlib.h>           /* strtoll, strtod */
#include <errno.h>            /* ERANGE past int64 */
#include <math.h>             /* isinf, isnan */
sp_Bigint *sp_bigint_new_str(const char *s, int base);   /* the runtime archive (sp_bigint.c) */

/* A 0xff-marked rodata literal, so sp_str_byte_len reads its length correctly
   (matches spinel_rt.h's SPL). Used for the fixed tokens true/false/null. */
#define JSPL(s) (&("\xff" s)[1])

/* Growable buffer, finalized into a right-sized GC string at the end.

   It starts off the GC heap, and it has to: the escaper below reads an
   unrooted source through it -- one that may be a rodata literal, whose [-1]
   is not a marker byte for the collector to read -- and that is only safe
   while nothing in here can collect.

   A document walk, though, does not always return through its frame. A user
   #to_json can raise, throw, or return from a proc, and every one of those
   longjmps over the frame, leaving a malloc'd block owned by nothing at all.
   So a walk MOVES its buffer onto the GC string heap before it calls user code
   (jb_to_heap), into a slot it has rooted, and from then on the collector owns
   it: the landing frame drops that root along with every other root the walk
   was holding, whichever way the walk was left. Once moved, growing the buffer
   allocates -- so an append whose source is a GC string roots that source too
   (jb_gcs). The move happens at most once per walk, and not at all for a
   document with no user objects in it, which is why it costs nothing to
   measure. */
typedef struct {
  char *p; size_t len, cap;
  char *heap;   /* NULL while p is malloc'd; == p once moved, and the rooted slot */
} jbuf;
/* A moved buffer's grow, out of line: jb_add is inlined into loops that append
   a byte at a time, and a second allocator inside its body stops that. With
   the grow written inline, nm gives jb_add a symbol of its own and the
   generate benchmark goes from 1.98 s to 2.58 s. */
SP_COLD static SP_NOINLINE void jb_grow_heap(jbuf *b, size_t cap) {
  char *q = sp_str_alloc(cap);   /* collects; b->heap is the walk's root */
  if (b->len) memcpy(q, b->p, b->len);
  b->p = b->heap = q;
  b->cap = cap;
}
static void jb_add(jbuf *b, const char *s, size_t n) {
  if (b->len + n + 1 > b->cap) {
    size_t cap = (b->len + n + 1) * 2;
    if (b->heap) jb_grow_heap(b, cap);
    else {
      b->p = (char *)realloc(b->p, cap);
      if (!b->p) sp_oom_die();
      b->cap = cap;
    }
  }
  memcpy(b->p + b->len, s, n);
  b->len += n;
}
static void jb_c(jbuf *b, char c) { jb_add(b, &c, 1); }
/* Hand the buffer to the collector before running code that may not come back.
   The allocation here can collect, and that is safe at exactly this moment:
   b->heap is still NULL, so the walk's root marks nothing, and what it is
   copying out of is a malloc'd block the collector cannot touch. */
static void jb_to_heap(jbuf *b) {
  if (b->heap) return;
  size_t cap = b->cap ? b->cap : 1;
  char *q = sp_str_alloc(cap);
  if (b->len) memcpy(q, b->p, b->len);
  free(b->p);
  b->p = b->heap = q;
  b->cap = cap;
}
/* Append a GC string to a buffer that has moved: growing it allocates now, and
   the source is held in nothing but this argument slot -- the same reason
   sp_json_parse roots its input. A source with no marker byte in front of it must not come through
   here: the collector reads that byte. Every caller's does -- a fresh heap
   string, sp_str_empty, or a JSPL literal. */
static void jb_gcs_rooted(jbuf *b, const char *s, size_t n) {
  SP_GC_ROOT_STR(s);
  jb_add(b, s, n);
}
/* Every GC string a walk appends comes through here, once per scalar and once
   per key. Before the buffer moves nothing in jb_add can collect, so no root
   is pushed; the push is in its own function above to keep the cleanup it
   declares out of the path that runs when there is nothing to root. */
static inline void jb_gcs(jbuf *b, const char *s, size_t n) {
  if (b->heap) { jb_gcs_rooted(b, s, n); return; }
  jb_add(b, s, n);
}
static const char *jb_finish(jbuf *b) {
  char *r = sp_str_alloc(b->len);
  if (b->len) memcpy(r, b->p, b->len);
  sp_str_set_len(r, b->len);
  if (!b->heap) free(b->p);
  return r;
}

/* An object's #to_s, the way sp_poly_to_s renders it: the class's own method
   through the generated dispatcher, and otherwise CRuby's default form. The
   generated TU's renderer is a static inline in spinel_rt.h, which this TU
   deliberately does not include (see the note at the top), so the two arms are
   reached through the hooks the generated program installs. */
static const char *sp_json_obj_to_s(sp_RbVal v) {
  if (v.cls_id >= 0 && sp_obj_to_s_fn) {
    const char *us = sp_obj_to_s_fn(v.cls_id, v.v.p);
    if (us) return us;
  }
  return sp_sprintf("#<%s:0x%016llx>",
                    sp_obj_cls_name_fn ? sp_obj_cls_name_fn(v.cls_id) : "Object",
                    (unsigned long long)(uintptr_t)v.v.p);
}

const char *sp_json_str(const char *s) {
  jbuf b; memset(&b, 0, sizeof b);
  jb_c(&b, '"');
  if (s) {
    for (const char *p = s; *p; p++) {
      unsigned char c = (unsigned char)*p;
      if (c == '"') jb_add(&b, "\\\"", 2);
      else if (c == '\\') jb_add(&b, "\\\\", 2);
      else if (c == '\n') jb_add(&b, "\\n", 2);
      else if (c == '\t') jb_add(&b, "\\t", 2);
      else if (c == '\r') jb_add(&b, "\\r", 2);
      else if (c == '\b') jb_add(&b, "\\b", 2);
      else if (c == '\f') jb_add(&b, "\\f", 2);
      else if (c < 0x20) { char u[8]; int n = snprintf(u, sizeof u, "\\u%04x", (unsigned)c); jb_add(&b, u, (size_t)n); }
      else jb_c(&b, (char)c);
    }
  }
  jb_c(&b, '"');
  return jb_finish(&b);
}

static const char *sp_json_key(sp_RbVal k) {
  if (k.tag == SP_TAG_STR)  return sp_json_str(k.v.s);
  if (k.tag == SP_TAG_SYM)  return sp_json_str(sp_sym_name_fn ? sp_sym_name_fn((sp_sym)k.v.i) : "");
  if (k.tag == SP_TAG_INT)  return sp_json_str(sp_int_to_s(k.v.i));
  if (k.tag == SP_TAG_BOOL) return sp_json_str(k.v.b ? "true" : "false");
  return sp_json_str("");
}

/* CRuby's json refuses to serialize past 100 levels of nesting, which is how
   it answers a structure that contains itself: `a << a; JSON.generate(a)` is a
   JSON::NestingError, not an endless document. The limit is on DEPTH, not on
   identity -- 100 levels of distinct arrays serialize and the 101st raises,
   whether or not anything repeats. */
#define SP_JSON_MAX_NESTING 100
SP_COLD static SP_NOINLINE SP_NORETURN void sp_json_too_deep(jbuf *b) {
  /* The walk's own raise, so the walk can hand it the buffer to release (#4355).
     One it has already moved onto the GC heap needs nothing: the collector
     takes that with the root the landing frame drops. */
  if (!b->heap) free(b->p);
  sp_raise_cls("JSON::NestingError",
               "nesting of 100 is too deep. Did you try to serialize objects with circular references?");
}
/* Everything but a container: the leaf arms, answering one GC string. */
static const char *sp_json_scalar(sp_RbVal v) {
  switch (v.tag) {
    case SP_TAG_INT:  return sp_int_to_s(v.v.i);
    case SP_TAG_BIGINT: return sp_bigint_to_s((sp_Bigint *)v.v.p);
    case SP_TAG_FLT:
      /* Infinity and NaN are not JSON: CRuby refuses them rather than write
         a document no parser reads back */
      if (isinf(v.v.f))
        sp_raise_cls("JSON::GeneratorError", v.v.f > 0 ? "Infinity not allowed in JSON" : "-Infinity not allowed in JSON");
      if (isnan(v.v.f)) sp_raise_cls("JSON::GeneratorError", "NaN not allowed in JSON");
      return sp_float_to_s(v.v.f);
    case SP_TAG_BOOL: return v.v.b ? JSPL("true") : JSPL("false");
    case SP_TAG_NIL:  return JSPL("null");
    case SP_TAG_STR:  return sp_json_str(v.v.s);
    case SP_TAG_SYM:  return sp_json_str(sp_sym_name_fn ? sp_sym_name_fn((sp_sym)v.v.i) : "");
    default: return JSPL("null");
  }
}
static void sp_json_val_b(jbuf *b, sp_RbVal v, int depth);
/* A compact document is appended into ONE buffer for the whole walk, as the
   pretty form below already does, so the walk has exactly one allocation to
   account for.

   That buffer is released whichever way the walk is left. Its own nesting
   error is handed it to free. The raises it cannot be handed -- a user
   #to_json that raises, throws or returns from a proc, and a #to_json answer
   that does not parse -- leave this frame without coming back to it, so the
   walk moves the buffer to the collector before it calls any of that code. */
const char *sp_json_val(sp_RbVal v) {
  if (v.tag != SP_TAG_OBJ) return sp_json_scalar(v);
  SP_GC_ROOT_RBVAL(v);   /* see sp_json_pretty below */
  jbuf b; memset(&b, 0, sizeof b);
  SP_GC_ROOT_STR(b.heap);
  sp_json_val_b(&b, v, 0);
  return jb_finish(&b);
}
/* `depth` counts the containers already entered, so a container reached at
   depth 100 would be the 101st level. */
static void sp_json_val_b(jbuf *b, sp_RbVal v, int depth) {
  if (v.tag != SP_TAG_OBJ) { const char *sc = sp_json_scalar(v); jb_gcs(b, sc, strlen(sc)); return; }
  int kind = sp_json_kind_fn ? sp_json_kind_fn(v) : 0;
  if (kind == 1) {  /* array */
    if (depth >= SP_JSON_MAX_NESTING) sp_json_too_deep(b);
    sp_int n = sp_json_len_fn(v);
    jb_c(b, '[');
    for (sp_int i = 0; i < n; i++) {
      if (i) jb_c(b, ',');
      sp_json_val_b(b, sp_json_aref_fn(v, i), depth + 1);
    }
    jb_c(b, ']');
    return;
  }
  if (kind == 2) {  /* hash */
    if (depth >= SP_JSON_MAX_NESTING) sp_json_too_deep(b);
    sp_int n = sp_json_len_fn(v);
    jb_c(b, '{');
    for (sp_int i = 0; i < n; i++) {
      if (i) jb_c(b, ',');
      sp_RbVal k, val;
      sp_json_hpair_fn(v, i, &k, &val);
      { const char *jk = sp_json_key(k); jb_gcs(b, jk, strlen(jk)); }
      jb_c(b, ':');
      sp_json_val_b(b, val, depth + 1);
    }
    jb_c(b, '}');
    return;
  }
  /* An object serializes the way CRuby's json does, and CRuby's json is method
     dispatch: `require "json"` mixes #to_json into Object and into each core
     class, and JSON.generate calls it. So a class with its own #to_json wins,
     and everything else lands on Object#to_json -- which is `to_s.to_json`, a
     JSON *string*. Struct has no override of its own there (the method's owner
     for a Struct is the Object module), which is why a Struct reads as
     "#<struct S x=1>" rather than as its members.

     Spinel reaches the same two answers by a different road, since it has no
     runtime method table to mix a module into: the user arm is the
     sp_obj_to_json_fn hook the generated program installs, and the fallback is
     sp_poly_to_s, which dispatches the class's own #to_s and otherwise renders
     the default #<Name:0x..>. The observable result is CRuby's for both.

     It used to reflect an object into a hash of its members here instead, so
     JSON.generate(Struct.new(:x).new(1)) answered {"x":1} where CRuby answers
     "#<struct S x=1>" -- and a plain object with no reflection answered null,
     which is not any Ruby's answer (#4387). */
  /* the answer is a Ruby String, appended by its own length: a NUL inside it
     is the user's to keep */
  if (sp_obj_to_json_fn) {
    jb_to_heap(b);   /* the user's method may raise, throw, or return past us */
    const char *uj = sp_obj_to_json_fn(v);
    if (uj) { jb_gcs(b, uj, (size_t)sp_str_byte_len(uj)); return; }
  }
  { jb_to_heap(b);   /* the class's own #to_s can raise or allocate */
    const char *js = sp_json_str(sp_json_obj_to_s(v));
    jb_gcs(b, js, (size_t)sp_str_byte_len(js)); }
}

/* ---------- JSON.pretty_generate ----------
   CRuby's pretty format: two-space indent per level, ": " key separator,
   containers multiline with the closer at the parent's indent; empty
   containers stay "{}" / "[]". Scalars delegate to the flat serializer. */

static void sp_json_indent(jbuf *b, int depth) {
  for (int i = 0; i < depth; i++) jb_add(b, "  ", 2);
}

static void sp_json_pretty_val(jbuf *b, sp_RbVal v, int depth) {
  if (v.tag == SP_TAG_OBJ) {
    int kind = sp_json_kind_fn ? sp_json_kind_fn(v) : 0;
    if (kind == 1) {  /* array */
      if (depth >= SP_JSON_MAX_NESTING) sp_json_too_deep(b);
      sp_int n = sp_json_len_fn(v);
      if (n == 0) { jb_add(b, "[]", 2); return; }
      jb_c(b, '[');
      for (sp_int i = 0; i < n; i++) {
        if (i) jb_c(b, ',');
        jb_c(b, '\n');
        sp_json_indent(b, depth + 1);
        sp_json_pretty_val(b, sp_json_aref_fn(v, i), depth + 1);
      }
      jb_c(b, '\n');
      sp_json_indent(b, depth);
      jb_c(b, ']');
      return;
    }
    if (kind == 2) {  /* hash */
      if (depth >= SP_JSON_MAX_NESTING) sp_json_too_deep(b);
      sp_int n = sp_json_len_fn(v);
      if (n == 0) { jb_add(b, "{}", 2); return; }
      jb_c(b, '{');
      for (sp_int i = 0; i < n; i++) {
        if (i) jb_c(b, ',');
        jb_c(b, '\n');
        sp_json_indent(b, depth + 1);
        sp_RbVal k, val;
        sp_json_hpair_fn(v, i, &k, &val);
        { const char *jk = sp_json_key(k); jb_gcs(b, jk, strlen(jk)); }
        jb_add(b, ": ", 2);
        sp_json_pretty_val(b, val, depth + 1);
      }
      jb_c(b, '\n');
      sp_json_indent(b, depth);
      jb_c(b, '}');
      return;
    }
    /* the user's #to_json answers a compact document; re-read it so it lays
       out with the surrounding indentation instead of on one line */
    if (sp_obj_to_json_fn) {
      jb_to_heap(b);   /* the user's method may raise, throw, or return past us */
      const char *uj = sp_obj_to_json_fn(v);
      if (uj) {
        /* the re-parsed document is this walk's only reference to it */
        sp_RbVal d = sp_json_parse(uj);
        SP_GC_ROOT_RBVAL(d);
        sp_json_pretty_val(b, d, depth);
        return;
      }
    }
    /* Same fallback as the flat walk: Object#to_json is to_s.to_json, and a
       JSON string has no interior structure for the pretty printer to lay out,
       so it renders identically either way. */
    { jb_to_heap(b);
      const char *js = sp_json_str(sp_json_obj_to_s(v));
      jb_gcs(b, js, (size_t)sp_str_byte_len(js)); }
    return;
  }
  { const char *sc = sp_json_val(v); jb_gcs(b, sc, strlen(sc)); }
}

/* The document is rooted for the walk, for the reason sp_json_parse roots its
   input and the reflection arms root theirs: a caller that hands over an
   expression -- JSON.generate(Foo.new) -- holds it in nothing but the C
   argument slot, and everything the walk reaches is reached through it. The
   walk allocates from its first escaped string onward, and moving the buffer
   to the heap allocates too, so an unrooted document is read after it is
   freed. */
const char *sp_json_pretty(sp_RbVal v) {
  SP_GC_ROOT_RBVAL(v);
  jbuf b; memset(&b, 0, sizeof b);
  SP_GC_ROOT_STR(b.heap);
  sp_json_pretty_val(&b, v, 0);
  return jb_finish(&b);
}

/* ---------- JSON.parse ----------
   A recursive-descent parser producing boxed poly values: scalars and arrays
   are built directly from the package ABI (sp_box_*, sp_PolyArray); objects use
   the installed hash-builder hooks (the generated TU owns the hash type). Each
   in-progress container is GC-rooted so a nested allocation can't collect it. */

#define JP_MAX_DEPTH 200

typedef struct { const char *p, *end; } jrd;

static SP_NORETURN void jp_err(const char *msg) {
  sp_raise_cls("JSON::ParserError", msg);
}
static void jp_ws(jrd *j) {
  while (j->p < j->end) {
    char c = *j->p;
    if (c == ' ' || c == '\t' || c == '\n' || c == '\r') j->p++;
    else break;
  }
}
static sp_RbVal jp_value(jrd *j, int depth);

static void jp_hex4(jrd *j, jbuf *b, unsigned *out) {
  if (j->end - j->p < 4) { free(b->p); jp_err("incomplete \\u escape"); }
  unsigned cp = 0;
  for (int i = 0; i < 4; i++) {
    char h = *j->p++;
    cp <<= 4;
    if (h >= '0' && h <= '9') cp |= (unsigned)(h - '0');
    else if (h >= 'a' && h <= 'f') cp |= (unsigned)(h - 'a' + 10);
    else if (h >= 'A' && h <= 'F') cp |= (unsigned)(h - 'A' + 10);
    else { free(b->p); jp_err("invalid \\u hex digit"); }
  }
  *out = cp;
}
static void jp_utf8(jbuf *b, unsigned cp) {
  if (cp < 0x80) jb_c(b, (char)cp);
  else if (cp < 0x800) { jb_c(b, (char)(0xC0 | (cp >> 6))); jb_c(b, (char)(0x80 | (cp & 0x3F))); }
  else if (cp < 0x10000) { jb_c(b, (char)(0xE0 | (cp >> 12))); jb_c(b, (char)(0x80 | ((cp >> 6) & 0x3F))); jb_c(b, (char)(0x80 | (cp & 0x3F))); }
  else { jb_c(b, (char)(0xF0 | (cp >> 18))); jb_c(b, (char)(0x80 | ((cp >> 12) & 0x3F))); jb_c(b, (char)(0x80 | ((cp >> 6) & 0x3F))); jb_c(b, (char)(0x80 | (cp & 0x3F))); }
}
/* Parse a "..." string (cursor at the opening quote) into a GC string. */
static const char *jp_string(jrd *j) {
  if (j->p >= j->end || *j->p != '"') jp_err("expected a string");
  j->p++;
  jbuf b; memset(&b, 0, sizeof b);
  while (j->p < j->end && *j->p != '"') {
    char c = *j->p++;
    /* RFC 8259 s7: control chars U+0000..U+001F must be escaped */
    if ((unsigned char)c < 0x20) { free(b.p); jp_err("unescaped control character in string"); }
    if (c != '\\') { jb_c(&b, c); continue; }
    if (j->p >= j->end) { free(b.p); jp_err("unterminated escape"); }
    char e = *j->p++;
    switch (e) {
      case '"': jb_c(&b, '"'); break;   case '\\': jb_c(&b, '\\'); break;
      case '/': jb_c(&b, '/'); break;   case 'n': jb_c(&b, '\n'); break;
      case 't': jb_c(&b, '\t'); break;  case 'r': jb_c(&b, '\r'); break;
      case 'b': jb_c(&b, '\b'); break;  case 'f': jb_c(&b, '\f'); break;
      case 'u': {
        unsigned cp; jp_hex4(j, &b, &cp);
        if (cp >= 0xD800 && cp <= 0xDBFF && j->end - j->p >= 2 && j->p[0] == '\\' && j->p[1] == 'u') {
          j->p += 2; unsigned lo; jp_hex4(j, &b, &lo);
          if (lo >= 0xDC00 && lo <= 0xDFFF) cp = 0x10000 + ((cp - 0xD800) << 10) + (lo - 0xDC00);
          else jp_utf8(&b, cp), cp = lo;   /* lone high surrogate: emit both raw */
        }
        jp_utf8(&b, cp);
        break;
      }
      default: free(b.p); jp_err("invalid escape");
    }
  }
  if (j->p >= j->end) { free(b.p); jp_err("unterminated string"); }
  j->p++;  /* closing quote */
  return jb_finish(&b);
}
static sp_RbVal jp_number(jrd *j) {
  const char *start = j->p;
  int is_float = 0;
  if (j->p < j->end && *j->p == '-') j->p++;
  /* integer part (RFC 8259 s6): a lone 0, or 1-9 then digits -- no leading zeros */
  if (j->p < j->end && *j->p == '0') {
    j->p++;
    if (j->p < j->end && *j->p >= '0' && *j->p <= '9') jp_err("leading zero in number");
  }
  else {
    const char *ds = j->p;
    while (j->p < j->end && *j->p >= '0' && *j->p <= '9') j->p++;
    if (j->p == ds) jp_err("expected a digit in number");
  }
  /* fraction: '.' then at least one digit */
  if (j->p < j->end && *j->p == '.') {
    is_float = 1; j->p++;
    const char *fs = j->p;
    while (j->p < j->end && *j->p >= '0' && *j->p <= '9') j->p++;
    if (j->p == fs) jp_err("expected a digit after '.'");
  }
  /* exponent: e/E, optional sign, then at least one digit */
  if (j->p < j->end && (*j->p == 'e' || *j->p == 'E')) {
    is_float = 1; j->p++;
    if (j->p < j->end && (*j->p == '+' || *j->p == '-')) j->p++;
    const char *es = j->p;
    while (j->p < j->end && *j->p >= '0' && *j->p <= '9') j->p++;
    if (j->p == es) jp_err("expected a digit in exponent");
  }
  size_t n = (size_t)(j->p - start);
  if (n == 0) jp_err("invalid number");
  /* the digits as a C string: a stack buffer for the usual width, the heap
     for an integer longer than that, which is a Bignum and has no limit */
  char stk[64];
  char *tmp = n < sizeof stk ? stk : (char *)malloc(n + 1);
  if (!tmp) jp_err("invalid number");
  memcpy(tmp, start, n); tmp[n] = 0;
  sp_RbVal r;
  if (is_float) r = sp_box_float(strtod(tmp, NULL));
  else {
    /* past int64 strtoll clamps with ERANGE and the value was answered
       clamped (9223372036854775808 read back as ...807); the digits
       themselves make the Bignum instead */
    errno = 0;
    long long v = strtoll(tmp, NULL, 10);
    if (errno == ERANGE) r = sp_box_bigint(sp_bigint_new_str(tmp, 10));
    else r = sp_box_i64((int64_t)v);   /* a Bignum past a 32-bit sp_int */
  }
  if (tmp != stk) free(tmp);
  return r;
}
static sp_RbVal jp_array(jrd *j, int depth) {
  j->p++;  /* '[' */
  sp_RbVal box = sp_box_poly_array(sp_PolyArray_new());
  SP_GC_ROOT_RBVAL(box);
  jp_ws(j);
  if (j->p < j->end && *j->p == ']') { j->p++; return box; }
  for (;;) {
    sp_RbVal v = jp_value(j, depth + 1);
    sp_PolyArray_push((sp_PolyArray *)box.v.p, v);
    jp_ws(j);
    if (j->p >= j->end) jp_err("unterminated array");
    if (*j->p == ',') { j->p++; continue; }
    if (*j->p == ']') { j->p++; break; }
    jp_err("expected ',' or ']' in array");
  }
  return box;
}
static sp_RbVal jp_object(jrd *j, int depth) {
  j->p++;  /* '{' */
  sp_RbVal box = sp_json_mk_hash_fn();
  SP_GC_ROOT_RBVAL(box);
  jp_ws(j);
  if (j->p < j->end && *j->p == '}') { j->p++; return box; }
  for (;;) {
    jp_ws(j);
    const char *key = jp_string(j);
    SP_GC_ROOT_STR(key);   /* survive the value parse; the hash stores the ptr */
    jp_ws(j);
    if (j->p >= j->end || *j->p != ':') jp_err("expected ':' in object");
    j->p++;
    sp_RbVal v = jp_value(j, depth + 1);
    sp_json_hash_set_fn(box, key, v);
    jp_ws(j);
    if (j->p >= j->end) jp_err("unterminated object");
    if (*j->p == ',') { j->p++; continue; }
    if (*j->p == '}') { j->p++; break; }
    jp_err("expected ',' or '}' in object");
  }
  return box;
}
static sp_RbVal jp_value(jrd *j, int depth) {
  if (depth > JP_MAX_DEPTH) jp_err("nesting too deep");
  jp_ws(j);
  if (j->p >= j->end) jp_err("unexpected end of input");
  char c = *j->p;
  if (c == '{') return jp_object(j, depth);
  if (c == '[') return jp_array(j, depth);
  if (c == '"') return sp_box_str(jp_string(j));
  if (c == 't') { if (j->end - j->p >= 4 && !memcmp(j->p, "true", 4))  { j->p += 4; return sp_box_bool(1); } jp_err("expected 'true'"); }
  if (c == 'f') { if (j->end - j->p >= 5 && !memcmp(j->p, "false", 5)) { j->p += 5; return sp_box_bool(0); } jp_err("expected 'false'"); }
  if (c == 'n') { if (j->end - j->p >= 4 && !memcmp(j->p, "null", 4))  { j->p += 4; return sp_box_nil(); } jp_err("expected 'null'"); }
  if (c == '-' || (c >= '0' && c <= '9')) return jp_number(j);
  jp_err("unexpected character");
}

sp_RbVal sp_json_parse(const char *s) {
  /* The reader walks `s` in place while the parse allocates every container
     and string it builds, so the input has to stay rooted for the whole walk:
     a caller passing it straight in (`JSON.parse File.read path`) holds it in
     nothing but the C argument slot, and the first collection under it leaves
     the cursor reading freed memory -- a parse error whose message varies by
     run on a small document, a segfault on a large one. */
  SP_GC_ROOT_STR(s);
  jrd j;
  j.p = s ? s : "";
  j.end = j.p + (s ? sp_str_byte_len(s) : 0);
  sp_RbVal v = jp_value(&j, 0);
  jp_ws(&j);
  if (j.p != j.end) jp_err("unexpected trailing characters");
  return v;
}
