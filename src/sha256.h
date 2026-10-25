#ifndef SPINEL_SHA256_H
#define SPINEL_SHA256_H
#include <stddef.h>
#include <stdint.h>

/* SHA-256 (FIPS 180-4) for the compiler's own use: --incremental names a
   unit by the hash of its text and keys a cached object by the hash of
   everything that compiled it. The runtime's lib/sp_crypto.c serves Ruby's
   Digest and needs the runtime headers; this one needs nothing. */
typedef struct {
  uint32_t h[8];
  uint64_t len;           /* bytes hashed so far */
  unsigned char buf[64];
  size_t nbuf;            /* bytes waiting in buf */
} Sha256;

void sha256_init(Sha256 *s);
void sha256_update(Sha256 *s, const void *p, size_t n);
void sha256_final(Sha256 *s, unsigned char out[32]);
/* The digest of p[0..n) as 64 lowercase hex digits and a NUL. */
void sha256_hex(const void *p, size_t n, char out[65]);

#endif
