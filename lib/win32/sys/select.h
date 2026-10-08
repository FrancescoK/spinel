/* Windows: no <sys/select.h>. fd_set here is a POSIX bitmap over CRT fds
   (winsock's is an array of SOCKETs), and select runs on the poll shim. */
#ifndef SP_WIN32_SYS_SELECT_H
#define SP_WIN32_SYS_SELECT_H
#include <sys/time.h>
#include <string.h>

#ifndef FD_SETSIZE
#define FD_SETSIZE 1024
#endif
typedef struct { unsigned long fds_bits[FD_SETSIZE / (8 * sizeof(unsigned long))]; } sp_w32_fd_set;
#define fd_set sp_w32_fd_set
#define SP_W32_NFDBITS (8 * sizeof(unsigned long))
#undef FD_ZERO
#undef FD_SET
#undef FD_CLR
#undef FD_ISSET
#define FD_ZERO(s)     memset((s), 0, sizeof(*(s)))
#define FD_SET(fd, s)  ((s)->fds_bits[(fd) / SP_W32_NFDBITS] |= (1UL << ((fd) % SP_W32_NFDBITS)))
#define FD_CLR(fd, s)  ((s)->fds_bits[(fd) / SP_W32_NFDBITS] &= ~(1UL << ((fd) % SP_W32_NFDBITS)))
#define FD_ISSET(fd, s) (((s)->fds_bits[(fd) / SP_W32_NFDBITS] & (1UL << ((fd) % SP_W32_NFDBITS))) != 0)

#ifdef __cplusplus
extern "C" {
#endif
int sp_w32_select(int n, fd_set *r, fd_set *w, fd_set *e, struct timeval *tv);
#define select(n, r, w, e, tv) sp_w32_select((n), (r), (w), (e), (tv))
#ifdef __cplusplus
}
#endif
#endif
