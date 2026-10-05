/* Windows: no <poll.h>. poll answers for every kind of fd the runtime
   parks on -- sockets (WSAPoll), pipes (PeekNamedPipe), the console and
   regular files (always ready, as on POSIX) -- in one call. The struct and
   the event bits are winsock's (WSAPOLLFD), so a set of sockets goes to
   WSAPoll as it is. */
#ifndef SP_WIN32_POLL_H
#define SP_WIN32_POLL_H

struct pollfd { int fd; short events; short revents; };
typedef unsigned long nfds_t;

#define POLLRDNORM 0x0100
#define POLLRDBAND 0x0200
#define POLLIN     (POLLRDNORM | POLLRDBAND)
#define POLLPRI    0x0400
#define POLLWRNORM 0x0010
#define POLLOUT    POLLWRNORM
#define POLLWRBAND 0x0020
#define POLLERR    0x0001
#define POLLHUP    0x0002
#define POLLNVAL   0x0004

#ifdef __cplusplus
extern "C" {
#endif
int poll(struct pollfd *fds, nfds_t n, int timeout_ms);
#ifdef __cplusplus
}
#endif
#endif
