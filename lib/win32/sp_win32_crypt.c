/* sp_win32_crypt.c -- crypt(3) for Windows, which has none: the traditional
   DES scheme every libc answers a two-character salt with (glibc's, which
   String#crypt reads on Linux). The key's first eight characters, seven bits
   each, are the DES key; the salt's twelve bits swap bit pairs of the E
   expansion; a zero block is encrypted 25 times; and the 64 bits are written
   as eleven characters of "./0-9A-Za-z" after the salt. Plain C, no Windows
   header: it builds and can be checked against glibc on any host. */
#if defined(_WIN32) || defined(SP_W32_CRYPT_TEST)
#include <errno.h>
#include <stdint.h>
#include <string.h>

static const unsigned char IP[64] = {
  58,50,42,34,26,18,10,2, 60,52,44,36,28,20,12,4, 62,54,46,38,30,22,14,6, 64,56,48,40,32,24,16,8,
  57,49,41,33,25,17, 9,1, 59,51,43,35,27,19,11,3, 61,53,45,37,29,21,13,5, 63,55,47,39,31,23,15,7 };
static const unsigned char FP[64] = {
  40,8,48,16,56,24,64,32, 39,7,47,15,55,23,63,31, 38,6,46,14,54,22,62,30, 37,5,45,13,53,21,61,29,
  36,4,44,12,52,20,60,28, 35,3,43,11,51,19,59,27, 34,2,42,10,50,18,58,26, 33,1,41, 9,49,17,57,25 };
static const unsigned char E0[48] = {
  32, 1, 2, 3, 4, 5,  4, 5, 6, 7, 8, 9,  8, 9,10,11,12,13, 12,13,14,15,16,17,
  16,17,18,19,20,21, 20,21,22,23,24,25, 24,25,26,27,28,29, 28,29,30,31,32, 1 };
static const unsigned char P[32] = {
  16, 7,20,21,29,12,28,17,  1,15,23,26, 5,18,31,10,  2, 8,24,14,32,27, 3, 9, 19,13,30, 6,22,11, 4,25 };
static const unsigned char PC1[56] = {
  57,49,41,33,25,17, 9, 1,58,50,42,34,26,18, 10, 2,59,51,43,35,27,19,11, 3,60,52,44,36,
  63,55,47,39,31,23,15, 7,62,54,46,38,30,22, 14, 6,61,53,45,37,29,21,13, 5,28,20,12, 4 };
static const unsigned char PC2[48] = {
  14,17,11,24, 1, 5, 3,28,15, 6,21,10, 23,19,12, 4,26, 8,16, 7,27,20,13, 2,
  41,52,31,37,47,55,30,40,51,45,33,48, 44,49,39,56,34,53,46,42,50,36,29,32 };
static const unsigned char SHIFTS[16] = { 1,1,2,2,2,2,2,2,1,2,2,2,2,2,2,1 };
static const unsigned char S[8][64] = {
  {14,4,13,1,2,15,11,8,3,10,6,12,5,9,0,7, 0,15,7,4,14,2,13,1,10,6,12,11,9,5,3,8,
   4,1,14,8,13,6,2,11,15,12,9,7,3,10,5,0, 15,12,8,2,4,9,1,7,5,11,3,14,10,0,6,13},
  {15,1,8,14,6,11,3,4,9,7,2,13,12,0,5,10, 3,13,4,7,15,2,8,14,12,0,1,10,6,9,11,5,
   0,14,7,11,10,4,13,1,5,8,12,6,9,3,2,15, 13,8,10,1,3,15,4,2,11,6,7,12,0,5,14,9},
  {10,0,9,14,6,3,15,5,1,13,12,7,11,4,2,8, 13,7,0,9,3,4,6,10,2,8,5,14,12,11,15,1,
   13,6,4,9,8,15,3,0,11,1,2,12,5,10,14,7, 1,10,13,0,6,9,8,7,4,15,14,3,11,5,2,12},
  {7,13,14,3,0,6,9,10,1,2,8,5,11,12,4,15, 13,8,11,5,6,15,0,3,4,7,2,12,1,10,14,9,
   10,6,9,0,12,11,7,13,15,1,3,14,5,2,8,4, 3,15,0,6,10,1,13,8,9,4,5,11,12,7,2,14},
  {2,12,4,1,7,10,11,6,8,5,3,15,13,0,14,9, 14,11,2,12,4,7,13,1,5,0,15,10,3,9,8,6,
   4,2,1,11,10,13,7,8,15,9,12,5,6,3,0,14, 11,8,12,7,1,14,2,13,6,15,0,9,10,4,5,3},
  {12,1,10,15,9,2,6,8,0,13,3,4,14,7,5,11, 10,15,4,2,7,12,9,5,6,1,13,14,0,11,3,8,
   9,14,15,5,2,8,12,3,7,0,4,10,1,13,11,6, 4,3,2,12,9,5,15,10,11,14,1,7,6,0,8,13},
  {4,11,2,14,15,0,8,13,3,12,9,7,5,10,6,1, 13,0,11,7,4,9,1,10,14,3,5,12,2,15,8,6,
   1,4,11,13,12,3,7,14,10,15,6,8,0,5,9,2, 6,11,13,8,1,4,10,7,9,5,0,15,14,2,3,12},
  {13,2,8,4,6,15,11,1,10,9,3,14,5,0,12,7, 1,15,13,8,10,3,7,4,12,5,6,11,0,14,9,2,
   7,11,4,1,9,12,14,2,0,6,10,13,15,3,5,8, 2,1,14,7,4,10,8,13,15,12,9,0,3,5,6,11} };

static const char sp_crypt_alpha[] = "./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

static int sp_crypt_ascii64(int c) {
  if (c >= '.' && c <= '9') return c - '.';
  if (c >= 'A' && c <= 'Z') return c - 'A' + 12;
  if (c >= 'a' && c <= 'z') return c - 'a' + 38;
  return -1;
}

/* bits as arrays of 0/1, index 0 the most significant: plain and slow,
   and String#crypt is called a handful of times */
char *crypt(const char *key, const char *salt) {
  static __thread char out[14];
  if (!key || !salt) { errno = EINVAL; return NULL; }
  int s0 = sp_crypt_ascii64((unsigned char)salt[0]);
  int s1 = salt[0] ? sp_crypt_ascii64((unsigned char)salt[1]) : -1;
  if (s0 < 0 || s1 < 0) { errno = EINVAL; return NULL; }
  unsigned saltbits = (unsigned)s0 | ((unsigned)s1 << 6);

  unsigned char E[48];
  memcpy(E, E0, sizeof E);
  for (int i = 0; i < 12; i++)
    if ((saltbits >> i) & 1) { unsigned char t = E[i]; E[i] = E[i + 24]; E[i + 24] = t; }

  unsigned char kb[64];
  memset(kb, 0, sizeof kb);
  for (int i = 0; i < 8 && key[i]; i++) {
    unsigned c = (unsigned char)key[i];
    for (int j = 0; j < 7; j++) kb[i * 8 + j] = (unsigned char)((c >> (6 - j)) & 1);
  }
  unsigned char cd[56];
  for (int i = 0; i < 56; i++) cd[i] = kb[PC1[i] - 1];
  unsigned char ks[16][48];
  for (int r = 0; r < 16; r++) {
    for (int s = 0; s < SHIFTS[r]; s++) {
      unsigned char c0 = cd[0], d0 = cd[28];
      memmove(cd, cd + 1, 27); cd[27] = c0;
      memmove(cd + 28, cd + 29, 27); cd[55] = d0;
    }
    for (int i = 0; i < 48; i++) ks[r][i] = cd[PC2[i] - 1];
  }

  unsigned char blk[64];
  memset(blk, 0, sizeof blk);
  for (int it = 0; it < 25; it++) {
    unsigned char lr[64];
    for (int i = 0; i < 64; i++) lr[i] = blk[IP[i] - 1];
    unsigned char *L = lr, *R = lr + 32;
    for (int r = 0; r < 16; r++) {
      unsigned char er[48], f[32], pf[32];
      for (int i = 0; i < 48; i++) er[i] = (unsigned char)(R[E[i] - 1] ^ ks[r][i]);
      for (int b = 0; b < 8; b++) {
        const unsigned char *x = er + b * 6;
        int row = (x[0] << 1) | x[5];
        int col = (x[1] << 3) | (x[2] << 2) | (x[3] << 1) | x[4];
        int v = S[b][row * 16 + col];
        for (int j = 0; j < 4; j++) f[b * 4 + j] = (unsigned char)((v >> (3 - j)) & 1);
      }
      for (int i = 0; i < 32; i++) pf[i] = f[P[i] - 1];
      unsigned char nr[32];
      for (int i = 0; i < 32; i++) nr[i] = (unsigned char)(L[i] ^ pf[i]);
      memcpy(L, R, 32);
      memcpy(R, nr, 32);
    }
    /* the halves swap once more before the final permutation */
    unsigned char rl[64];
    memcpy(rl, R, 32); memcpy(rl + 32, L, 32);
    for (int i = 0; i < 64; i++) blk[i] = rl[FP[i] - 1];
  }

  out[0] = salt[0]; out[1] = salt[1];
  for (int i = 0; i < 11; i++) {
    int v = 0;
    for (int j = 0; j < 6; j++) {
      int bit = i * 6 + j;
      v = (v << 1) | (bit < 64 ? blk[bit] : 0);
    }
    out[2 + i] = sp_crypt_alpha[v];
  }
  out[13] = 0;
  return out;
}
#endif
