/* Windows: readv/writev, one buffer after another (sp_win32.c). */
#ifndef SP_WIN32_SYS_UIO_H
#define SP_WIN32_SYS_UIO_H
#include <sys/socket.h>
#ifdef __cplusplus
extern "C" {
#endif
long long sp_w32_readv(int fd, const struct iovec *iov, int n);
long long sp_w32_writev(int fd, const struct iovec *iov, int n);
#define readv(fd, iov, n) sp_w32_readv((fd), (iov), (n))
#define writev(fd, iov, n) sp_w32_writev((fd), (iov), (n))
#ifdef __cplusplus
}
#endif
#endif
