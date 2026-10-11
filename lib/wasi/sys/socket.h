/* wasm32-wasi (preview 1): the socket options wasi-libc's header leaves out
   and the UNIX-domain family it has no address for. The calls that need
   them fail in the host with ENOTSUP (see ../signal.h here). */
#ifndef SP_WASI_SYS_SOCKET_H
#define SP_WASI_SYS_SOCKET_H
#include_next <sys/socket.h>
#ifndef SO_REUSEADDR
#define SO_REUSEADDR 2
#endif
#ifndef SO_ERROR
#define SO_ERROR 4
#endif
#ifndef SO_BROADCAST
#define SO_BROADCAST 6
#endif
#ifndef SO_SNDBUF
#define SO_SNDBUF 7
#endif
#ifndef SO_RCVBUF
#define SO_RCVBUF 8
#endif
#ifndef SO_KEEPALIVE
#define SO_KEEPALIVE 9
#endif
#ifndef SO_LINGER
#define SO_LINGER 13
#endif
#ifndef PF_UNIX
#define PF_UNIX 1
#endif
#ifndef AF_UNIX
#define AF_UNIX PF_UNIX
#endif
int socket(int, int, int);
int bind(int, const struct sockaddr *, socklen_t);
int listen(int, int);
int connect(int, const struct sockaddr *, socklen_t);
int setsockopt(int, int, int, const void *, socklen_t);
int socketpair(int, int, int, int [2]);
/* listen(2)'s backlog hint, which wasi-libc leaves out (sp_net.c's
   Socket.tcp_server_sockets, #8541); the call fails there as the others do */
#ifndef SOMAXCONN
#define SOMAXCONN 128
#endif
#endif
