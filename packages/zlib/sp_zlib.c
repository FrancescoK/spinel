/* sp_zlib.c -- DEFLATE (RFC 1951), zlib (RFC 1950) and gzip (RFC 1952) for
   the `zlib` spin package (Path B carried C), linked on demand when
   `require "zlib"` appears.

   WHY THIS IS NOT A BINDING TO THE SYSTEM libz. packages/openssl is glue over
   the system libssl on purpose: TLS has trust anchors and a protocol clock,
   and both belong to the distribution. Decompression has neither. What it has
   instead is a host problem: a machine with libz.so.1 and no zlib.h -- an
   ordinary developer box without the -dev package, which is where this was
   written -- would fail the availability probe, drop the package, and give a
   green `make test` that never ran a line of it. That is the exact failure
   the openssl probe's comment is about. spinel already carries its own regexp
   engine and bigint rather than depending on the host's; this is the same
   answer for the same reason.

   Inflate is complete: stored, fixed-Huffman and dynamic-Huffman blocks, with
   the zlib and gzip wrappers and their checksums. Deflate is LZ77 with a hash
   chain emitting fixed-Huffman blocks -- a valid stream any inflater reads,
   at a ratio below zlib's own, which builds dynamic tables per block. Both
   directions are one-shot: a whole input in, a whole output back. The Ruby
   side accumulates for the incremental spellings.

   Binary safe throughout: input length comes from the string header
   (sp_str_byte_len), output is a length-set BINARY string on the GC heap.

   Every symbol here carries the full package prefix, including the static
   helpers, and that is not tidiness. The build derives its reserved-identifier
   list from the FIRST underscore component of every runtime name in lib/ and
   packages/, so a helper whose component was "z" reserved that letter and
   renamed a user method called `z` in every program that never heard of this
   package. The generated-C sweep is what showed it: two unrelated tests moved
   to the escaped spelling. One prefix in, one prefix claimed.

   The same rule is why no identifier is spelled out in this comment: the
   extraction greps the file, comments and all, so naming an example here
   would reserve the example. */
#include "spinel/runtime.h"
#include <string.h>
#include <stdlib.h>

/* ---------------------------------------------------------------- checksums */

static uint32_t sp_zlib_crc_table[256];
static int sp_zlib_crc_ready = 0;

static void sp_zlib_crc_init(void) {
  if (sp_zlib_crc_ready) return;
  for (uint32_t i = 0; i < 256; i++) {
    uint32_t c = i;
    for (int k = 0; k < 8; k++) c = (c & 1) ? (0xEDB88320u ^ (c >> 1)) : (c >> 1);
    sp_zlib_crc_table[i] = c;
  }
  sp_zlib_crc_ready = 1;
}

static uint32_t sp_zlib_crc32(uint32_t crc, const unsigned char *p, size_t n) {
  sp_zlib_crc_init();
  crc = ~crc;
  for (size_t i = 0; i < n; i++) crc = sp_zlib_crc_table[(crc ^ p[i]) & 0xff] ^ (crc >> 8);
  return ~crc;
}

static uint32_t sp_zlib_adler32(uint32_t adler, const unsigned char *p, size_t n) {
  uint32_t a = adler & 0xffff, b = (adler >> 16) & 0xffff;
  /* 5552 is the largest run of bytes that cannot overflow b before the
     modulo, which is why the loop is chunked rather than reducing per byte. */
  while (n) {
    size_t k = n < 5552 ? n : 5552;
    n -= k;
    while (k--) { a += *p++; b += a; }
    a %= 65521; b %= 65521;
  }
  return (b << 16) | a;
}

/* -------------------------------------------------------------- output sink */

typedef struct { unsigned char *p; size_t len, cap; int err; } sp_zlib_out;

static int sp_zlib_out_reserve(sp_zlib_out *o, size_t extra) {
  if (o->err) return 0;
  if (o->len + extra <= o->cap) return 1;
  size_t cap = o->cap ? o->cap : 4096;
  while (cap < o->len + extra) {
    if (cap > (SIZE_MAX >> 8)) { o->err = 1; return 0; }   /* refuse to spiral (`1 << 40` is 0 in a 32-bit size_t) */
    cap *= 2;
  }
  unsigned char *np = (unsigned char *)realloc(o->p, cap);
  if (!np) { o->err = 1; return 0; }
  o->p = np; o->cap = cap;
  return 1;
}

static void sp_zlib_out_byte(sp_zlib_out *o, unsigned char c) {
  if (!sp_zlib_out_reserve(o, 1)) return;
  o->p[o->len++] = c;
}

static void sp_zlib_out_write(sp_zlib_out *o, const unsigned char *src, size_t n) {
  if (!sp_zlib_out_reserve(o, n)) return;
  memcpy(o->p + o->len, src, n);
  o->len += n;
}

/* An LZ77 back-reference may overlap its own output (`dist` 1 repeats one
   byte `len` times), so this copies forward one byte at a time rather than
   memcpy'ing a region that is still being written. */
static void sp_zlib_out_repeat(sp_zlib_out *o, size_t dist, size_t len) {
  if (dist == 0 || dist > o->len) { o->err = 1; return; }
  if (!sp_zlib_out_reserve(o, len)) return;
  size_t from = o->len - dist;
  for (size_t i = 0; i < len; i++) o->p[o->len + i] = o->p[from + i];
  o->len += len;
}

/* ------------------------------------------------------------- bit reader */

typedef struct {
  const unsigned char *src;
  size_t len, pos;
  uint32_t bitbuf;
  int bitcnt;
  int err;
} sp_zlib_in;

/* DEFLATE packs bits low-order first within each byte. -1 means the stream
   ended mid-code, which is a truncated input rather than a malformed one; the
   caller cannot tell them apart and neither can zlib. */
static int sp_zlib_in_bits(sp_zlib_in *s, int need) {
  while (s->bitcnt < need) {
    if (s->pos >= s->len) { s->err = 1; return -1; }
    s->bitbuf |= (uint32_t)s->src[s->pos++] << s->bitcnt;
    s->bitcnt += 8;
  }
  int v = (int)(s->bitbuf & ((1u << need) - 1));
  s->bitbuf >>= need;
  s->bitcnt -= need;
  return v;
}

/* ------------------------------------------------------------ Huffman codes */

/* Canonical Huffman, decoded by walking code lengths: `counts[l]` is how many
   symbols have length l, `symbols` lists them in that order. Decoding one
   symbol walks lengths 1..15 accumulating bits, which is small and needs no
   table build beyond a prefix sum. */
typedef struct { int counts[16]; int symbols[288]; } sp_zlib_huff;

static int sp_zlib_huff_build(sp_zlib_huff *h, const unsigned char *lengths, int n) {
  for (int i = 0; i < 16; i++) h->counts[i] = 0;
  for (int i = 0; i < n; i++) h->counts[lengths[i]]++;
  if (h->counts[0] == n) return 0;   /* no codes at all: caller decides */
  /* Reject an over-subscribed set: more codes at some length than the tree
     can hold. An incomplete set is legal (a single distance code is), so only
     the over-subscribed direction is an error. */
  int left = 1;
  for (int l = 1; l < 16; l++) {
    left <<= 1;
    left -= h->counts[l];
    if (left < 0) return -1;
  }
  int offs[16];
  offs[1] = 0;
  for (int l = 1; l < 15; l++) offs[l + 1] = offs[l] + h->counts[l];
  for (int i = 0; i < n; i++)
    if (lengths[i]) h->symbols[offs[lengths[i]]++] = i;
  return 0;
}

static int sp_zlib_huff_decode(sp_zlib_in *s, const sp_zlib_huff *h) {
  int code = 0, first = 0, index = 0;
  for (int l = 1; l < 16; l++) {
    int b = sp_zlib_in_bits(s, 1);
    if (b < 0) return -1;
    code |= b;
    int count = h->counts[l];
    if (code - first < count) return h->symbols[index + (code - first)];
    index += count;
    first += count;
    first <<= 1;
    code <<= 1;
  }
  s->err = 1;
  return -1;
}

/* ------------------------------------------------------------ length tables */

static const unsigned short SP_Z_LEN_BASE[29] = {
  3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31, 35, 43, 51, 59,
  67, 83, 99, 115, 131, 163, 195, 227, 258
};
static const unsigned char SP_Z_LEN_EXTRA[29] = {
  0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3,
  4, 4, 4, 4, 5, 5, 5, 5, 0
};
static const unsigned short SP_Z_DIST_BASE[30] = {
  1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193, 257, 385, 513,
  769, 1025, 1537, 2049, 3073, 4097, 6145, 8193, 12289, 16385, 24577
};
static const unsigned char SP_Z_DIST_EXTRA[30] = {
  0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8,
  9, 9, 10, 10, 11, 11, 12, 12, 13, 13
};

/* --------------------------------------------------------------- inflate */

static int sp_zlib_block_stored(sp_zlib_in *s, sp_zlib_out *o) {
  s->bitbuf = 0; s->bitcnt = 0;              /* stored blocks start byte-aligned */
  if (s->pos + 4 > s->len) { s->err = 1; return -1; }
  unsigned len  = (unsigned)s->src[s->pos] | ((unsigned)s->src[s->pos + 1] << 8);
  unsigned nlen = (unsigned)s->src[s->pos + 2] | ((unsigned)s->src[s->pos + 3] << 8);
  s->pos += 4;
  if ((len ^ 0xffff) != nlen) { s->err = 1; return -1; }
  if (s->pos + len > s->len) { s->err = 1; return -1; }
  sp_zlib_out_write(o, s->src + s->pos, len);
  s->pos += len;
  return o->err ? -1 : 0;
}

static int sp_zlib_block_codes(sp_zlib_in *s, sp_zlib_out *o,
                            const sp_zlib_huff *lit, const sp_zlib_huff *dist) {
  for (;;) {
    int sym = sp_zlib_huff_decode(s, lit);
    if (sym < 0) return -1;
    if (sym < 256) { sp_zlib_out_byte(o, (unsigned char)sym); if (o->err) return -1; continue; }
    if (sym == 256) return 0;                     /* end of block */
    sym -= 257;
    if (sym >= 29) { s->err = 1; return -1; }
    int extra = sp_zlib_in_bits(s, SP_Z_LEN_EXTRA[sym]);
    if (extra < 0) return -1;
    size_t len = (size_t)SP_Z_LEN_BASE[sym] + (size_t)extra;
    int dsym = sp_zlib_huff_decode(s, dist);
    if (dsym < 0) return -1;
    if (dsym >= 30) { s->err = 1; return -1; }
    int dextra = sp_zlib_in_bits(s, SP_Z_DIST_EXTRA[dsym]);
    if (dextra < 0) return -1;
    size_t d = (size_t)SP_Z_DIST_BASE[dsym] + (size_t)dextra;
    sp_zlib_out_repeat(o, d, len);
    if (o->err) return -1;
  }
}

static void sp_zlib_fixed_tables(sp_zlib_huff *lit, sp_zlib_huff *dist) {
  unsigned char l[288], d[30];
  int i = 0;
  for (; i < 144; i++) l[i] = 8;
  for (; i < 256; i++) l[i] = 9;
  for (; i < 280; i++) l[i] = 7;
  for (; i < 288; i++) l[i] = 8;
  for (i = 0; i < 30; i++) d[i] = 5;
  sp_zlib_huff_build(lit, l, 288);
  sp_zlib_huff_build(dist, d, 30);
}

/* The order the dynamic-block header lists code-length code lengths in. */
static const unsigned char SP_Z_CLEN_ORDER[19] = {
  16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15
};

static int sp_zlib_block_dynamic(sp_zlib_in *s, sp_zlib_out *o) {
  int hlit  = sp_zlib_in_bits(s, 5); if (hlit  < 0) return -1;
  int hdist = sp_zlib_in_bits(s, 5); if (hdist < 0) return -1;
  int hclen = sp_zlib_in_bits(s, 4); if (hclen < 0) return -1;
  int nlen = hlit + 257, ndist = hdist + 1, ncode = hclen + 4;
  if (nlen > 286 || ndist > 30) { s->err = 1; return -1; }

  unsigned char clens[19];
  memset(clens, 0, sizeof clens);
  for (int i = 0; i < ncode; i++) {
    int v = sp_zlib_in_bits(s, 3);
    if (v < 0) return -1;
    clens[SP_Z_CLEN_ORDER[i]] = (unsigned char)v;
  }
  sp_zlib_huff clh;
  if (sp_zlib_huff_build(&clh, clens, 19) < 0) { s->err = 1; return -1; }

  unsigned char lengths[288 + 30];
  memset(lengths, 0, sizeof lengths);
  int n = 0;
  while (n < nlen + ndist) {
    int sym = sp_zlib_huff_decode(s, &clh);
    if (sym < 0) return -1;
    if (sym < 16) { lengths[n++] = (unsigned char)sym; continue; }
    int rep = 0;
    unsigned char val = 0;
    if (sym == 16) {
      if (n == 0) { s->err = 1; return -1; }   /* nothing to repeat */
      val = lengths[n - 1];
      int e = sp_zlib_in_bits(s, 2); if (e < 0) return -1;
      rep = 3 + e;
    }
    else if (sym == 17) { int e = sp_zlib_in_bits(s, 3); if (e < 0) return -1; rep = 3 + e; }
    else                { int e = sp_zlib_in_bits(s, 7); if (e < 0) return -1; rep = 11 + e; }
    if (n + rep > nlen + ndist) { s->err = 1; return -1; }
    while (rep--) lengths[n++] = val;
  }
  if (lengths[256] == 0) { s->err = 1; return -1; }   /* no end-of-block code */

  sp_zlib_huff lit, dist;
  if (sp_zlib_huff_build(&lit, lengths, nlen) < 0) { s->err = 1; return -1; }
  if (sp_zlib_huff_build(&dist, lengths + nlen, ndist) < 0) { s->err = 1; return -1; }
  return sp_zlib_block_codes(s, o, &lit, &dist);
}

static int sp_zlib_inflate_raw(sp_zlib_in *s, sp_zlib_out *o) {
  for (;;) {
    int final = sp_zlib_in_bits(s, 1); if (final < 0) return -1;
    int type  = sp_zlib_in_bits(s, 2); if (type  < 0) return -1;
    int rc;
    if (type == 0) rc = sp_zlib_block_stored(s, o);
    else if (type == 1) {
      sp_zlib_huff lit, dist;
      sp_zlib_fixed_tables(&lit, &dist);
      rc = sp_zlib_block_codes(s, o, &lit, &dist);
    }
    else if (type == 2) rc = sp_zlib_block_dynamic(s, o);
    else { s->err = 1; return -1; }
    if (rc < 0) return -1;
    if (final) return 0;
  }
}

/* ------------------------------------------------------------- the wrappers */

/* window_bits, spelled as zlib spells it: 8..15 a zlib stream, negative raw
   deflate, +16 gzip, +32 accept either. */
#define SP_Z_RAW  0
#define SP_Z_ZLIB 1
#define SP_Z_GZIP 2
#define SP_Z_AUTO 3

static int sp_zlib_wrap_kind(int window_bits) {
  if (window_bits < 0) return SP_Z_RAW;
  if (window_bits >= 40) return SP_Z_AUTO;
  if (window_bits >= 24) return SP_Z_GZIP;
  return SP_Z_ZLIB;
}

static SP_TLS const char *sp_zlib_err = NULL;

const char *sp_zlib_last_error(void) { return sp_zlib_err ? sp_zlib_err : ""; }

/* Skip a gzip header, answering the offset of the deflate data or -1. */
static long sp_zlib_gzip_header(const unsigned char *p, size_t n) {
  if (n < 10 || p[0] != 0x1f || p[1] != 0x8b || p[2] != 8) return -1;
  unsigned flg = p[3];
  size_t i = 10;
  if (flg & 4) {                                    /* FEXTRA */
    if (i + 2 > n) return -1;
    size_t xlen = (size_t)p[i] | ((size_t)p[i + 1] << 8);
    i += 2 + xlen;
    if (i > n) return -1;
  }
  if (flg & 8)  { while (i < n && p[i]) i++; if (i >= n) return -1; i++; }   /* FNAME */
  if (flg & 16) { while (i < n && p[i]) i++; if (i >= n) return -1; i++; }   /* FCOMMENT */
  if (flg & 2)  { i += 2; if (i > n) return -1; }   /* FHCRC */
  return (long)i;
}

/* Zlib.inflate / Zlib::Inflate#inflate. Returns NULL on a malformed stream;
   the Ruby side turns that into Zlib::DataError with sp_zlib_last_error. */
const char *sp_zlib_inflate(const char *src, sp_int window_bits) {SP_GC_ROOT_STR(src);
  sp_zlib_err = NULL;
  size_t n = src ? sp_str_byte_len(src) : 0;
  const unsigned char *p = (const unsigned char *)src;
  int kind = sp_zlib_wrap_kind((int)window_bits);
  size_t off = 0;
  uint32_t want = 0;
  int check = 0;   /* 0 none, 1 adler32, 2 crc32 */

  if (kind == SP_Z_AUTO) {
    if (n >= 2 && p[0] == 0x1f && p[1] == 0x8b) kind = SP_Z_GZIP;
    else kind = SP_Z_ZLIB;
  }
  if (kind == SP_Z_ZLIB) {
    /* CMF/FLG: low nibble of CMF must be 8 (deflate) and the pair must be a
       multiple of 31, which is the whole of the zlib header's self-check. */
    if (n < 2 || (p[0] & 0x0f) != 8 || ((p[0] << 8) | p[1]) % 31 != 0) {
      sp_zlib_err = "incorrect header check";
      return NULL;
    }
    if (p[1] & 0x20) { sp_zlib_err = "preset dictionary not supported"; return NULL; }
    off = 2;
    if (n >= 6) {
      want = ((uint32_t)p[n - 4] << 24) | ((uint32_t)p[n - 3] << 16) |
             ((uint32_t)p[n - 2] << 8) | (uint32_t)p[n - 1];
      check = 1;
    }
  }
  else if (kind == SP_Z_GZIP) {
    long h = sp_zlib_gzip_header(p, n);
    if (h < 0) { sp_zlib_err = "not in gzip format"; return NULL; }
    off = (size_t)h;
    if (n >= off + 8) {
      want = (uint32_t)p[n - 8] | ((uint32_t)p[n - 7] << 8) |
             ((uint32_t)p[n - 6] << 16) | ((uint32_t)p[n - 5] << 24);
      check = 2;
    }
  }

  sp_zlib_in s;
  s.src = p + off; s.len = n - off; s.pos = 0;
  s.bitbuf = 0; s.bitcnt = 0; s.err = 0;
  sp_zlib_out o;
  o.p = NULL; o.len = 0; o.cap = 0; o.err = 0;

  if (sp_zlib_inflate_raw(&s, &o) < 0) {
    free(o.p);
    sp_zlib_err = o.err ? "out of memory" : "invalid or incomplete deflate data";
    return NULL;
  }
  if (check == 1 && sp_zlib_adler32(1, o.p, o.len) != want) {
    free(o.p); sp_zlib_err = "invalid stored block lengths"; return NULL;
  }
  if (check == 2 && sp_zlib_crc32(0, o.p, o.len) != want) {
    free(o.p); sp_zlib_err = "invalid compressed data -- crc error"; return NULL;
  }

  char *r = sp_str_alloc_raw(o.len + 1);
  if (o.len) memcpy(r, o.p, o.len);
  r[o.len] = 0;
  sp_str_set_len(r, o.len);
  sp_str_mark_binary(r);
  free(o.p);
  return r;
}

/* --------------------------------------------------------------- deflate */

/* Bit writer, low-order first, matching the reader above. */
typedef struct { sp_zlib_out *o; uint32_t buf; int cnt; } sp_zlib_bw;

static void sp_zlib_bw_put(sp_zlib_bw *w, unsigned value, int nbits) {
  w->buf |= (uint32_t)value << w->cnt;
  w->cnt += nbits;
  while (w->cnt >= 8) {
    sp_zlib_out_byte(w->o, (unsigned char)(w->buf & 0xff));
    w->buf >>= 8;
    w->cnt -= 8;
  }
}

/* Huffman codes go out most-significant bit first, which is the one place
   DEFLATE reverses its own bit order. */
static void sp_zlib_bw_code(sp_zlib_bw *w, unsigned code, int nbits) {
  unsigned rev = 0;
  for (int i = 0; i < nbits; i++) { rev = (rev << 1) | ((code >> i) & 1); }
  sp_zlib_bw_put(w, rev, nbits);
}

static void sp_zlib_bw_flush(sp_zlib_bw *w) {
  if (w->cnt > 0) { sp_zlib_out_byte(w->o, (unsigned char)(w->buf & 0xff)); w->buf = 0; w->cnt = 0; }
}

/* The fixed literal/length alphabet of RFC 1951 3.2.6. */
static void sp_zlib_fixed_lit(unsigned sym, unsigned *code, int *nbits) {
  if (sym < 144)      { *code = 0x30 + sym;        *nbits = 8; }
  else if (sym < 256) { *code = 0x190 + sym - 144; *nbits = 9; }
  else if (sym < 280) { *code = sym - 256;         *nbits = 7; }
  else                { *code = 0xC0 + sym - 280;  *nbits = 8; }
}

static void sp_zlib_emit_lit(sp_zlib_bw *w, unsigned sym) {
  unsigned code; int nbits;
  sp_zlib_fixed_lit(sym, &code, &nbits);
  sp_zlib_bw_code(w, code, nbits);
}

static int sp_zlib_len_sym(size_t len) {
  for (int i = 28; i >= 0; i--) if (len >= SP_Z_LEN_BASE[i]) return i;
  return 0;
}

static int sp_zlib_dist_sym(size_t d) {
  for (int i = 29; i >= 0; i--) if (d >= SP_Z_DIST_BASE[i]) return i;
  return 0;
}

#define SP_Z_HASH_BITS 15
#define SP_Z_HASH_SIZE (1 << SP_Z_HASH_BITS)
#define SP_Z_MIN_MATCH 3
#define SP_Z_MAX_MATCH 258
#define SP_Z_WINDOW    32768

static unsigned sp_zlib_hash3(const unsigned char *p) {
  return (unsigned)(((uint32_t)p[0] << 10) ^ ((uint32_t)p[1] << 5) ^ (uint32_t)p[2])
         & (SP_Z_HASH_SIZE - 1);
}

/* Greedy LZ77 over a hash chain, emitted as one fixed-Huffman block. The
   chain depth is what `level` buys: more candidates examined per position,
   the same output format either way. */
static void sp_zlib_deflate_body(sp_zlib_bw *w, const unsigned char *p, size_t n, int level) {
  /* Z_DEFAULT_COMPRESSION is -1 and means level 6, which is the value nearly
     every caller passes without knowing it: `Zlib.deflate(s)` takes the
     default, and reading -1 as "below 0, so no matching" made the default the
     one level that does not compress. */
  if (level < 0) level = 6;
  int depth = level == 0 ? 0 : (level <= 3 ? 16 : (level <= 6 ? 64 : 256));
  int32_t *head = NULL, *prev = NULL;
  if (depth > 0 && n >= SP_Z_MIN_MATCH) {
    head = (int32_t *)malloc(sizeof(int32_t) * SP_Z_HASH_SIZE);
    prev = (int32_t *)malloc(sizeof(int32_t) * n);
    if (!head || !prev) { free(head); free(prev); head = NULL; prev = NULL; depth = 0; }
  }
  if (head) for (size_t i = 0; i < SP_Z_HASH_SIZE; i++) head[i] = -1;

  size_t i = 0;
  while (i < n) {
    size_t best_len = 0, best_dist = 0;
    if (head && i + SP_Z_MIN_MATCH <= n) {
      unsigned h = sp_zlib_hash3(p + i);
      int32_t cand = head[h];
      int tries = depth;
      size_t limit = n - i;
      if (limit > SP_Z_MAX_MATCH) limit = SP_Z_MAX_MATCH;
      while (cand >= 0 && tries-- > 0) {
        size_t d = i - (size_t)cand;
        if (d > SP_Z_WINDOW) break;              /* chains are newest first */
        const unsigned char *a = p + (size_t)cand, *b = p + i;
        /* A candidate replaces the best match only by being longer, so it
           has to agree with the input one byte past the best match: at the
           very first byte when there is none yet. That byte is inside the
           input, since a match of `limit` bytes ends the search. */
        if (a[best_len] != b[best_len]) { cand = prev[cand]; continue; }
        size_t l = 0;
        while (l + 8 <= limit && memcmp(a + l, b + l, 8) == 0) l += 8;
        while (l < limit && a[l] == b[l]) l++;
        if (l > best_len) { best_len = l; best_dist = d; if (l == limit) break; }
        cand = prev[cand];
      }
      if (best_len < SP_Z_MIN_MATCH) { best_len = 0; best_dist = 0; }
    }

    size_t advance = best_len ? best_len : 1;
    if (best_len) {
      int ls = sp_zlib_len_sym(best_len);
      sp_zlib_emit_lit(w, (unsigned)(257 + ls));
      if (SP_Z_LEN_EXTRA[ls])
        sp_zlib_bw_put(w, (unsigned)(best_len - SP_Z_LEN_BASE[ls]), SP_Z_LEN_EXTRA[ls]);
      int ds = sp_zlib_dist_sym(best_dist);
      sp_zlib_bw_code(w, (unsigned)ds, 5);
      if (SP_Z_DIST_EXTRA[ds])
        sp_zlib_bw_put(w, (unsigned)(best_dist - SP_Z_DIST_BASE[ds]), SP_Z_DIST_EXTRA[ds]);
    }
    else {
      sp_zlib_emit_lit(w, p[i]);
    }
    /* Every position the match covered still enters the chain: skipping them
       is what makes a later match miss the only copy it had. */
    if (head)
      for (size_t k = i; k < i + advance && k + SP_Z_MIN_MATCH <= n; k++) {
        unsigned h = sp_zlib_hash3(p + k);
        prev[k] = head[h];
        head[h] = (int32_t)k;
      }
    i += advance;
  }
  sp_zlib_emit_lit(w, 256);   /* end of block */
  free(head);
  free(prev);
}

const char *sp_zlib_deflate(const char *src, sp_int level, sp_int window_bits) {SP_GC_ROOT_STR(src);
  sp_zlib_err = NULL;
  size_t n = src ? sp_str_byte_len(src) : 0;
  const unsigned char *p = (const unsigned char *)src;
  int kind = sp_zlib_wrap_kind((int)window_bits);
  if (kind == SP_Z_AUTO) kind = SP_Z_ZLIB;   /* nothing to detect when writing */

  sp_zlib_out o;
  o.p = NULL; o.len = 0; o.cap = 0; o.err = 0;

  if (kind == SP_Z_ZLIB) {
    /* CMF 0x78: deflate, 32K window. FLG chosen so the pair divides by 31. */
    sp_zlib_out_byte(&o, 0x78);
    sp_zlib_out_byte(&o, 0x9c);
  }
  else if (kind == SP_Z_GZIP) {
    static const unsigned char hdr[10] = { 0x1f, 0x8b, 8, 0, 0, 0, 0, 0, 0, 0xff };
    sp_zlib_out_write(&o, hdr, 10);
  }

  sp_zlib_bw w;
  w.o = &o; w.buf = 0; w.cnt = 0;
  sp_zlib_bw_put(&w, 1, 1);   /* BFINAL: one block for the whole input */
  sp_zlib_bw_put(&w, 1, 2);   /* BTYPE 01: fixed Huffman */
  sp_zlib_deflate_body(&w, p, n, (int)level);
  sp_zlib_bw_flush(&w);

  if (kind == SP_Z_ZLIB) {
    uint32_t a = sp_zlib_adler32(1, p, n);
    sp_zlib_out_byte(&o, (unsigned char)(a >> 24));
    sp_zlib_out_byte(&o, (unsigned char)(a >> 16));
    sp_zlib_out_byte(&o, (unsigned char)(a >> 8));
    sp_zlib_out_byte(&o, (unsigned char)a);
  }
  else if (kind == SP_Z_GZIP) {
    uint32_t c = sp_zlib_crc32(0, p, n);
    sp_zlib_out_byte(&o, (unsigned char)c);
    sp_zlib_out_byte(&o, (unsigned char)(c >> 8));
    sp_zlib_out_byte(&o, (unsigned char)(c >> 16));
    sp_zlib_out_byte(&o, (unsigned char)(c >> 24));
    uint32_t sz = (uint32_t)n;
    sp_zlib_out_byte(&o, (unsigned char)sz);
    sp_zlib_out_byte(&o, (unsigned char)(sz >> 8));
    sp_zlib_out_byte(&o, (unsigned char)(sz >> 16));
    sp_zlib_out_byte(&o, (unsigned char)(sz >> 24));
  }

  if (o.err) { free(o.p); sp_zlib_err = "out of memory"; return NULL; }

  char *r = sp_str_alloc_raw(o.len + 1);
  if (o.len) memcpy(r, o.p, o.len);
  r[o.len] = 0;
  sp_str_set_len(r, o.len);
  sp_str_mark_binary(r);
  free(o.p);
  return r;
}

/* ------------------------------------------------------------- checksum API */

/* the checksums are unsigned 32-bit values, past a 32-bit sp_int's range:
   answered as a boxed Integer (a Bignum there, the plain value on 64-bit) */
sp_RbVal sp_zlib_crc32_of(const char *src, sp_RbVal init) {SP_GC_ROOT_STR(src);
  size_t n = src ? sp_str_byte_len(src) : 0;
  return sp_box_i64((int64_t)sp_zlib_crc32((uint32_t)sp_unbox_i64(init), (const unsigned char *)src, n));
}

sp_RbVal sp_zlib_adler32_of(const char *src, sp_RbVal init) {SP_GC_ROOT_STR(src);
  size_t n = src ? sp_str_byte_len(src) : 0;
  return sp_box_i64((int64_t)sp_zlib_adler32((uint32_t)sp_unbox_i64(init), (const unsigned char *)src, n));
}
