/* Windows: BSD sockets as POSIX has them, over winsock. A socket is a CRT
   file descriptor here too -- the SOCKET is created non-overlapped and
   wrapped with _open_osfhandle, so fdopen, the CRT's read and write, and
   fileno all work on it -- and the shim keeps which fds are sockets (see
   sp_win32.h), so read, write, poll, fcntl and close reach winsock for
   them. The structs are winsock's own layouts and the constants its values,
   declared here so neither the runtime nor a generated program includes
   <winsock2.h> (and with it <windows.h>). */
#ifndef SP_WIN32_SYS_SOCKET_H
#define SP_WIN32_SYS_SOCKET_H
#include <sys/types.h>
#include <stdint.h>
#include <stddef.h>
#include "../sp_win32.h"

typedef int socklen_t;
typedef unsigned short sa_family_t;

struct sockaddr { sa_family_t sa_family; char sa_data[14]; };
struct sockaddr_storage {
  sa_family_t ss_family;
  char __ss_pad1[6];
  long long __ss_align;
  char __ss_pad2[112];
};
struct linger { int l_onoff; int l_linger; };   /* POSIX ints; winsock's are u_short, the shim converts */
struct iovec { void *iov_base; size_t iov_len; };
struct msghdr {
  void *msg_name; socklen_t msg_namelen;
  struct iovec *msg_iov; int msg_iovlen;
  void *msg_control; socklen_t msg_controllen;
  int msg_flags;
};

#define AF_UNSPEC 0
#define AF_UNIX   1
#define AF_LOCAL  AF_UNIX
#define AF_INET   2
#define AF_INET6  23
#define PF_UNSPEC AF_UNSPEC
#define PF_UNIX   AF_UNIX
#define PF_LOCAL  AF_UNIX
#define PF_INET   AF_INET
#define PF_INET6  AF_INET6

#define SOCK_STREAM    1
#define SOCK_DGRAM     2
#define SOCK_RAW       3
#define SOCK_RDM       4
#define SOCK_SEQPACKET 5
/* Linux's type flags: winsock has none, socket() applies them itself */
#define SOCK_NONBLOCK  0x00000800
#define SOCK_CLOEXEC   0x00080000

#define SOL_SOCKET    0xffff
#define SO_DEBUG      0x0001
#define SO_ACCEPTCONN 0x0002
#define SO_REUSEADDR  0x0004
#define SO_KEEPALIVE  0x0008
#define SO_DONTROUTE  0x0010
#define SO_BROADCAST  0x0020
#define SO_LINGER     0x0080
#define SO_OOBINLINE  0x0100
#define SO_SNDBUF     0x1001
#define SO_RCVBUF     0x1002
#define SO_SNDLOWAT   0x1003
#define SO_RCVLOWAT   0x1004
#define SO_SNDTIMEO   0x1005
#define SO_RCVTIMEO   0x1006
#define SO_ERROR      0x1007
#define SO_TYPE       0x1008

#define MSG_OOB       0x1
#define MSG_PEEK      0x2
#define MSG_DONTROUTE 0x4
#define MSG_WAITALL   0x8
#define MSG_TRUNC     0x0100
#define MSG_CTRUNC    0x0200
#define MSG_DONTWAIT  0x40000000   /* not winsock's: the shim makes the one call non-blocking */
#define MSG_NOSIGNAL  0            /* no SIGPIPE on Windows: a closed peer is EPIPE already */
#define MSG_EOR       0

#define SHUT_RD   0
#define SHUT_WR   1
#define SHUT_RDWR 2

#define SOMAXCONN 0x7fffffff

#ifdef __cplusplus
extern "C" {
#endif
int sp_w32_socket(int domain, int type, int protocol);
int sp_w32_socketpair(int domain, int type, int protocol, int sv[2]);
int sp_w32_bind(int fd, const struct sockaddr *addr, socklen_t len);
int sp_w32_listen(int fd, int backlog);
int sp_w32_accept(int fd, struct sockaddr *addr, socklen_t *len);
int sp_w32_accept4(int fd, struct sockaddr *addr, socklen_t *len, int flags);
int sp_w32_connect(int fd, const struct sockaddr *addr, socklen_t len);
int sp_w32_shutdown(int fd, int how);
long long sp_w32_send(int fd, const void *buf, size_t n, int flags);
long long sp_w32_recv(int fd, void *buf, size_t n, int flags);
long long sp_w32_sendto(int fd, const void *buf, size_t n, int flags, const struct sockaddr *to, socklen_t tolen);
long long sp_w32_recvfrom(int fd, void *buf, size_t n, int flags, struct sockaddr *from, socklen_t *fromlen);
long long sp_w32_sendmsg(int fd, const struct msghdr *msg, int flags);
long long sp_w32_recvmsg(int fd, struct msghdr *msg, int flags);
int sp_w32_getsockopt(int fd, int level, int name, void *val, socklen_t *len);
int sp_w32_setsockopt(int fd, int level, int name, const void *val, socklen_t len);
int sp_w32_getsockname(int fd, struct sockaddr *addr, socklen_t *len);
int sp_w32_getpeername(int fd, struct sockaddr *addr, socklen_t *len);
#define socket(domain, type, protocol) sp_w32_socket((domain), (type), (protocol))
#define socketpair(domain, type, protocol, sv) sp_w32_socketpair((domain), (type), (protocol), (sv))
#define bind(fd, addr, len) sp_w32_bind((fd), (addr), (len))
#define listen(fd, backlog) sp_w32_listen((fd), (backlog))
#define accept(fd, addr, len) sp_w32_accept((fd), (addr), (len))
#define accept4(fd, addr, len, flags) sp_w32_accept4((fd), (addr), (len), (flags))
#define connect(fd, addr, len) sp_w32_connect((fd), (addr), (len))
#define shutdown(fd, how) sp_w32_shutdown((fd), (how))
#define send(fd, buf, n, flags) sp_w32_send((fd), (buf), (n), (flags))
#define recv(fd, buf, n, flags) sp_w32_recv((fd), (buf), (n), (flags))
#define sendto(fd, buf, n, flags, to, tolen) sp_w32_sendto((fd), (buf), (n), (flags), (to), (tolen))
#define recvfrom(fd, buf, n, flags, from, fromlen) sp_w32_recvfrom((fd), (buf), (n), (flags), (from), (fromlen))
#define sendmsg(fd, msg, flags) sp_w32_sendmsg((fd), (msg), (flags))
#define recvmsg(fd, msg, flags) sp_w32_recvmsg((fd), (msg), (flags))
#define getsockopt(fd, level, name, val, len) sp_w32_getsockopt((fd), (level), (name), (val), (len))
#define setsockopt(fd, level, name, val, len) sp_w32_setsockopt((fd), (level), (name), (val), (len))
#define getsockname(fd, addr, len) sp_w32_getsockname((fd), (addr), (len))
#define getpeername(fd, addr, len) sp_w32_getpeername((fd), (addr), (len))
#ifdef __cplusplus
}
#endif
#endif
