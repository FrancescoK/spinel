/* sp_win32_net.c -- sockets, poll/select, and the fd calls that have to
   tell a socket from a file (read, write, close, dup, fcntl, ioctl).

   A socket fd is a CRT descriptor whose handle is a duplicate of the
   SOCKET's (the SOCKET is created non-overlapped, so the CRT's ReadFile and
   WriteFile work on it, and fdopen streams read it). The table below maps
   the fd to the SOCKET itself, which every winsock call takes; close calls
   closesocket on it and lets the CRT close its own duplicate, so winsock's
   bookkeeping is released properly and no handle is ever closed twice. An
   entry counts only while the fd still holds the handle it was made with:
   an fd closed behind the shim's back (fclose) and reused for a file is a
   file again.

   This file includes <winsock2.h> and so must not see the shim's own
   socket headers (their structs are winsock's under POSIX names); it
   declares the sp_w32_ entry points it defines itself. */
#ifdef _WIN32
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#define NOMINMAX
#include <winsock2.h>
#include <ws2tcpip.h>
#include <windows.h>
#include <io.h>
#include <fcntl.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#undef read
#undef write
#undef close
#undef dup
#undef dup2
#undef pipe
#undef isatty
#undef fcntl
#undef open
#undef fclose
#undef fflush

/* the shim's numbers, as its headers spell them (sys/socket.h, poll.h,
   fcntl.h, sys/ioctl.h) */
#define SP_SOCK_NONBLOCK  0x00000800
#define SP_SOCK_CLOEXEC   0x00080000
#define SP_MSG_DONTWAIT   0x40000000
#define SP_O_NONBLOCK     0x00800000
#define SP_F_DUPFD   0
#define SP_F_GETFD   1
#define SP_F_SETFD   2
#define SP_F_GETFL   3
#define SP_F_SETFL   4
#define SP_F_DUPFD_CLOEXEC 1030
#define SP_FD_CLOEXEC 1
#define SP_TIOCGWINSZ 0x5413
#define SP_FIONREAD   0x4004667f
#define SP_FIONBIO    0x8004667e
#define SP_POLLIN   (POLLRDNORM | POLLRDBAND)
#define SP_POLLOUT  POLLWRNORM

struct sp_pollfd { int fd; short events; short revents; };
struct sp_winsize { unsigned short ws_row, ws_col, ws_xpixel, ws_ypixel; };
struct sp_linger { int l_onoff; int l_linger; };
struct sp_iovec { void *iov_base; size_t iov_len; };
struct sp_msghdr {
  void *msg_name; int msg_namelen;
  struct sp_iovec *msg_iov; int msg_iovlen;
  void *msg_control; int msg_controllen;
  int msg_flags;
};

int sp_w32_errno_of(DWORD e);
int sp_w32_close(int fd);

/* ===================================================================== */
/* the fd table                                                          */
/* ===================================================================== */

typedef struct {
  SOCKET s;        /* INVALID_SOCKET: not a socket */
  HANDLE h;        /* the handle the fd was made with */
  int nonblock;    /* O_NONBLOCK as fcntl last set it */
  int cloexec;     /* FD_CLOEXEC as fcntl last set it */
  int reuseaddr;   /* SO_REUSEADDR as setsockopt last set it */
} sp_w32_fdent;

static sp_w32_fdent *sp_w32_fds;
static int sp_w32_nfds;
static SRWLOCK sp_w32_fds_lock = SRWLOCK_INIT;

static sp_w32_fdent *sp_w32_ent(int fd, int create) {
  if (fd < 0) return NULL;
  if (fd >= sp_w32_nfds) {
    if (!create) return NULL;
    int n = sp_w32_nfds ? sp_w32_nfds : 64;
    while (n <= fd) n *= 2;
    sp_w32_fdent *nx = (sp_w32_fdent *)realloc(sp_w32_fds, sizeof *nx * (size_t)n);
    if (!nx) return NULL;
    for (int i = sp_w32_nfds; i < n; i++) { memset(&nx[i], 0, sizeof nx[i]); nx[i].s = INVALID_SOCKET; nx[i].h = INVALID_HANDLE_VALUE; }
    sp_w32_fds = nx; sp_w32_nfds = n;
  }
  sp_w32_fdent *e = &sp_w32_fds[fd];
  /* a stale entry (the fd was closed and reused without the shim seeing it) */
  HANDLE cur = (HANDLE)_get_osfhandle(fd);
  if (e->h != cur) {
    if (!create && e->h == INVALID_HANDLE_VALUE) return e->nonblock || e->cloexec ? e : NULL;
    e->s = INVALID_SOCKET; e->h = cur; e->nonblock = 0; e->cloexec = 0; e->reuseaddr = 0;
  }
  return e;
}

static SOCKET sp_w32_sock(int fd) {
  AcquireSRWLockExclusive(&sp_w32_fds_lock);
  sp_w32_fdent *e = sp_w32_ent(fd, 0);
  SOCKET s = e ? e->s : INVALID_SOCKET;
  ReleaseSRWLockExclusive(&sp_w32_fds_lock);
  return s;
}

int sp_w32_is_socket(int fd) { return sp_w32_sock(fd) != INVALID_SOCKET; }

int sp_w32_is_socket_handle(HANDLE h) {
  int r = 0;
  AcquireSRWLockShared(&sp_w32_fds_lock);
  for (int i = 0; i < sp_w32_nfds; i++)
    if (sp_w32_fds[i].s != INVALID_SOCKET && sp_w32_fds[i].h == h) { r = 1; break; }
  ReleaseSRWLockShared(&sp_w32_fds_lock);
  return r;
}

static int sp_w32_nonblocking(int fd) {
  AcquireSRWLockExclusive(&sp_w32_fds_lock);
  sp_w32_fdent *e = sp_w32_ent(fd, 0);
  int nb = e ? e->nonblock : 0;
  ReleaseSRWLockExclusive(&sp_w32_fds_lock);
  return nb;
}

/* ===================================================================== */
/* winsock                                                               */
/* ===================================================================== */

static INIT_ONCE sp_w32_wsa_once = INIT_ONCE_STATIC_INIT;
static BOOL CALLBACK sp_w32_wsa_init(PINIT_ONCE o, PVOID p, PVOID *c) {
  (void)o; (void)p; (void)c;
  WSADATA wd;
  WSAStartup(MAKEWORD(2, 2), &wd);
  return TRUE;
}
static void sp_w32_wsa(void) { InitOnceExecuteOnce(&sp_w32_wsa_once, sp_w32_wsa_init, NULL, NULL); }

static int sp_w32_errno_wsa(int e) {
  switch (e) {
    case WSAEINTR: return EINTR;
    case WSAEBADF: return EBADF;
    case WSAEACCES: return EACCES;
    case WSAEFAULT: return EFAULT;
    case WSAEINVAL: return EINVAL;
    case WSAEMFILE: return EMFILE;
    case WSAEWOULDBLOCK: return EAGAIN;
    case WSAEINPROGRESS: return EINPROGRESS;
    case WSAEALREADY: return EALREADY;
    case WSAENOTSOCK: return ENOTSOCK;
    case WSAEDESTADDRREQ: return EDESTADDRREQ;
    case WSAEMSGSIZE: return EMSGSIZE;
    case WSAEPROTOTYPE: return EPROTOTYPE;
    case WSAENOPROTOOPT: return ENOPROTOOPT;
    case WSAEPROTONOSUPPORT: return EPROTONOSUPPORT;
    case WSAESOCKTNOSUPPORT: return 159;   /* ESOCKTNOSUPPORT (errno.h here) */
    case WSAEOPNOTSUPP: return EOPNOTSUPP;
    case WSAEPFNOSUPPORT: return 158;      /* EPFNOSUPPORT */
    case WSAEAFNOSUPPORT: return EAFNOSUPPORT;
    case WSAEADDRINUSE: return EADDRINUSE;
    case WSAEADDRNOTAVAIL: return EADDRNOTAVAIL;
    case WSAENETDOWN: return ENETDOWN;
    case WSAENETUNREACH: return ENETUNREACH;
    case WSAENETRESET: return ENETRESET;
    case WSAECONNABORTED: return ECONNABORTED;
    case WSAECONNRESET: return ECONNRESET;
    case WSAENOBUFS: return ENOBUFS;
    case WSAEISCONN: return EISCONN;
    case WSAENOTCONN: return ENOTCONN;
    case WSAESHUTDOWN: return EPIPE;
    case WSAETIMEDOUT: return ETIMEDOUT;
    case WSAECONNREFUSED: return ECONNREFUSED;
    case WSAELOOP: return ELOOP;
    case WSAENAMETOOLONG: return ENAMETOOLONG;
    case WSAEHOSTDOWN: return 157;        /* EHOSTDOWN */
    case WSAEHOSTUNREACH: return EHOSTUNREACH;
    case WSAENOTEMPTY: return ENOTEMPTY;
    case WSAEDISCON: return EPIPE;
    case WSA_NOT_ENOUGH_MEMORY: return ENOMEM;
    default: return EINVAL;
  }
}
static int sp_w32_sockfail(void) { errno = sp_w32_errno_wsa(WSAGetLastError()); return -1; }

/* a SOCKET as a CRT fd: the fd holds a duplicate of its handle */
static int sp_w32_wrap(SOCKET s, int nonblock, int cloexec) {
  HANDLE dh;
  if (!DuplicateHandle(GetCurrentProcess(), (HANDLE)s, GetCurrentProcess(), &dh, 0, FALSE, DUPLICATE_SAME_ACCESS)) {
    closesocket(s); errno = sp_w32_errno_of(GetLastError()); return -1;
  }
  int fd = _open_osfhandle((intptr_t)dh, _O_BINARY);
  if (fd < 0) { CloseHandle(dh); closesocket(s); errno = EMFILE; return -1; }
  if (nonblock) { u_long one = 1; ioctlsocket(s, FIONBIO, &one); }
  AcquireSRWLockExclusive(&sp_w32_fds_lock);
  sp_w32_fdent *e = sp_w32_ent(fd, 1);
  if (e) { e->s = s; e->h = dh; e->nonblock = nonblock; e->cloexec = cloexec; e->reuseaddr = 0; }
  ReleaseSRWLockExclusive(&sp_w32_fds_lock);
  return fd;
}

static SOCKET sp_w32_need(int fd) {
  SOCKET s = sp_w32_sock(fd);
  if (s == INVALID_SOCKET) errno = (HANDLE)_get_osfhandle(fd) == INVALID_HANDLE_VALUE ? EBADF : ENOTSOCK;
  return s;
}

int sp_w32_socket(int domain, int type, int protocol) {
  sp_w32_wsa();
  int nb = (type & SP_SOCK_NONBLOCK) != 0, ce = (type & SP_SOCK_CLOEXEC) != 0;
  type &= ~(SP_SOCK_NONBLOCK | SP_SOCK_CLOEXEC);
  SOCKET s = WSASocketW(domain, type, protocol, NULL, 0, WSA_FLAG_NO_HANDLE_INHERIT);
  if (s == INVALID_SOCKET) return sp_w32_sockfail();
  return sp_w32_wrap(s, nb, ce);
}

const char *sp_w32_path(const char *path, char *buf, size_t n);

/* an AF_UNIX address names a file: /tmp and the rest mapped as for open */
#define SP_UNIX_PATH_MAX 108
typedef struct { unsigned short family; char path[SP_UNIX_PATH_MAX]; } sp_sockaddr_un;
static const struct sockaddr *sp_w32_unix_addr(const struct sockaddr *a, int *len, sp_sockaddr_un *out) {
  if (!a || a->sa_family != AF_UNIX || *len <= (int)sizeof(unsigned short)) return a;
  const sp_sockaddr_un *u = (const sp_sockaddr_un *)a;
  char in[SP_UNIX_PATH_MAX + 1];
  size_t n = (size_t)*len - sizeof(unsigned short);
  if (n > SP_UNIX_PATH_MAX) n = SP_UNIX_PATH_MAX;
  memcpy(in, u->path, n); in[n] = 0;
  if (!in[0]) return a;   /* an abstract address: as it is */
  char mapped[SP_UNIX_PATH_MAX * 3];
  sp_w32_path(in, mapped, sizeof mapped);
  if (strlen(mapped) >= SP_UNIX_PATH_MAX) return a;
  memset(out, 0, sizeof *out);
  out->family = AF_UNIX;
  strcpy(out->path, mapped);
  *len = (int)(sizeof(unsigned short) + strlen(mapped) + 1);
  return (const struct sockaddr *)out;
}

int sp_w32_bind(int fd, const struct sockaddr *a, int len) {
  SOCKET s = sp_w32_need(fd);
  if (s == INVALID_SOCKET) return -1;
  sp_sockaddr_un ua;
  a = sp_w32_unix_addr(a, &len, &ua);
  return bind(s, a, len) == 0 ? 0 : sp_w32_sockfail();
}

int sp_w32_listen(int fd, int backlog) {
  SOCKET s = sp_w32_need(fd);
  if (s == INVALID_SOCKET) return -1;
  return listen(s, backlog) == 0 ? 0 : sp_w32_sockfail();
}

/* An address buffer too small for the address: POSIX truncates it and
   says how long it was; winsock fails the call (WSAEFAULT) -- an accept
   into a sockaddr_in drops an IPv6 connection. The calls below take a full
   sockaddr_storage and hand back the POSIX answer. */
static void sp_w32_addr_out(const struct sockaddr_storage *ss, int got, struct sockaddr *a, int *len) {
  if (!a || !len) return;
  int n = *len < got ? *len : got;
  if (n > 0) memcpy(a, ss, (size_t)n);
  *len = got;
}

int sp_w32_accept4(int fd, struct sockaddr *a, int *len, int flags) {
  SOCKET s = sp_w32_need(fd);
  if (s == INVALID_SOCKET) return -1;
  struct sockaddr_storage ss; int sl = sizeof ss;
  SOCKET c = accept(s, (struct sockaddr *)&ss, &sl);
  if (c == INVALID_SOCKET) return sp_w32_sockfail();
  sp_w32_addr_out(&ss, sl, a, len);
  /* winsock hands the listener's non-blocking mode to the new socket; POSIX
     starts it blocking */
  int nb = (flags & SP_SOCK_NONBLOCK) != 0;
  u_long v = (u_long)nb;
  ioctlsocket(c, FIONBIO, &v);
  return sp_w32_wrap(c, nb, (flags & SP_SOCK_CLOEXEC) != 0);
}
int sp_w32_accept(int fd, struct sockaddr *a, int *len) { return sp_w32_accept4(fd, a, len, 0); }

int sp_w32_connect(int fd, const struct sockaddr *a, int len) {
  SOCKET s = sp_w32_need(fd);
  if (s == INVALID_SOCKET) return -1;
  sp_sockaddr_un ua;
  a = sp_w32_unix_addr(a, &len, &ua);
  if (connect(s, a, len) == 0) return 0;
  int e = WSAGetLastError();
  /* a non-blocking connect is under way: POSIX says EINPROGRESS */
  if (e == WSAEWOULDBLOCK) { errno = EINPROGRESS; return -1; }
  if (e == WSAEINVAL) { errno = EALREADY; return -1; }
  errno = sp_w32_errno_wsa(e);
  return -1;
}

int sp_w32_shutdown(int fd, int how) {
  SOCKET s = sp_w32_need(fd);
  if (s == INVALID_SOCKET) return -1;
  return shutdown(s, how) == 0 ? 0 : sp_w32_sockfail();
}

/* MSG_DONTWAIT on a blocking socket: non-blocking for this one call */
static int sp_w32_dontwait_begin(int fd, SOCKET s, int *flags) {
  if (!(*flags & SP_MSG_DONTWAIT)) return 0;
  *flags &= ~SP_MSG_DONTWAIT;
  if (sp_w32_nonblocking(fd)) return 0;
  u_long one = 1;
  ioctlsocket(s, FIONBIO, &one);
  return 1;
}
static void sp_w32_dontwait_end(SOCKET s, int on) { if (on) { u_long zero = 0; ioctlsocket(s, FIONBIO, &zero); } }

long long sp_w32_send(int fd, const void *buf, size_t n, int flags) {
  SOCKET s = sp_w32_need(fd);
  if (s == INVALID_SOCKET) return -1;
  int dw = sp_w32_dontwait_begin(fd, s, &flags);
  int r = send(s, (const char *)buf, n > 0x7fffffff ? 0x7fffffff : (int)n, flags);
  int e = WSAGetLastError();
  sp_w32_dontwait_end(s, dw);
  if (r == SOCKET_ERROR) { errno = sp_w32_errno_wsa(e); return -1; }
  return r;
}

long long sp_w32_recv(int fd, void *buf, size_t n, int flags) {
  SOCKET s = sp_w32_need(fd);
  if (s == INVALID_SOCKET) return -1;
  int dw = sp_w32_dontwait_begin(fd, s, &flags);
  int r = recv(s, (char *)buf, n > 0x7fffffff ? 0x7fffffff : (int)n, flags);
  int e = WSAGetLastError();
  sp_w32_dontwait_end(s, dw);
  if (r == SOCKET_ERROR) {
    if (e == WSAESHUTDOWN || e == WSAEDISCON) return 0;
    errno = sp_w32_errno_wsa(e); return -1;
  }
  return r;
}

long long sp_w32_sendto(int fd, const void *buf, size_t n, int flags, const struct sockaddr *to, int tolen) {
  SOCKET s = sp_w32_need(fd);
  if (s == INVALID_SOCKET) return -1;
  int dw = sp_w32_dontwait_begin(fd, s, &flags);
  int r = sendto(s, (const char *)buf, n > 0x7fffffff ? 0x7fffffff : (int)n, flags, to, tolen);
  int e = WSAGetLastError();
  sp_w32_dontwait_end(s, dw);
  if (r == SOCKET_ERROR) { errno = sp_w32_errno_wsa(e); return -1; }
  return r;
}

long long sp_w32_recvfrom(int fd, void *buf, size_t n, int flags, struct sockaddr *from, int *fromlen) {
  SOCKET s = sp_w32_need(fd);
  if (s == INVALID_SOCKET) return -1;
  int dw = sp_w32_dontwait_begin(fd, s, &flags);
  struct sockaddr_storage ss; int sl = sizeof ss;
  int r = recvfrom(s, (char *)buf, n > 0x7fffffff ? 0x7fffffff : (int)n, flags,
                   from ? (struct sockaddr *)&ss : NULL, from ? &sl : NULL);
  int e = WSAGetLastError();
  sp_w32_dontwait_end(s, dw);
  if (r != SOCKET_ERROR || e == WSAEMSGSIZE) sp_w32_addr_out(&ss, sl, from, fromlen);
  if (r == SOCKET_ERROR) {
    /* a datagram longer than the buffer: POSIX truncates it quietly */
    if (e == WSAEMSGSIZE) return (long long)n;
    /* an ICMP port-unreachable from an earlier send: not this receive's */
    if (e == WSAECONNRESET && !from) { errno = ECONNREFUSED; return -1; }
    errno = sp_w32_errno_wsa(e); return -1;
  }
  return r;
}

long long sp_w32_sendmsg(int fd, const struct sp_msghdr *m, int flags) {
  size_t tot = 0;
  for (int i = 0; i < m->msg_iovlen; i++) tot += m->msg_iov[i].iov_len;
  char *b = (char *)malloc(tot ? tot : 1);
  if (!b) { errno = ENOMEM; return -1; }
  size_t k = 0;
  for (int i = 0; i < m->msg_iovlen; i++) { memcpy(b + k, m->msg_iov[i].iov_base, m->msg_iov[i].iov_len); k += m->msg_iov[i].iov_len; }
  long long r = m->msg_name ? sp_w32_sendto(fd, b, tot, flags, (const struct sockaddr *)m->msg_name, m->msg_namelen)
                            : sp_w32_send(fd, b, tot, flags);
  free(b);
  return r;
}

long long sp_w32_recvmsg(int fd, struct sp_msghdr *m, int flags) {
  size_t tot = 0;
  for (int i = 0; i < m->msg_iovlen; i++) tot += m->msg_iov[i].iov_len;
  char *b = (char *)malloc(tot ? tot : 1);
  if (!b) { errno = ENOMEM; return -1; }
  long long r = m->msg_name ? sp_w32_recvfrom(fd, b, tot, flags, (struct sockaddr *)m->msg_name, &m->msg_namelen)
                            : sp_w32_recv(fd, b, tot, flags);
  if (r > 0) {
    size_t k = 0;
    for (int i = 0; i < m->msg_iovlen && k < (size_t)r; i++) {
      size_t c = m->msg_iov[i].iov_len;
      if (c > (size_t)r - k) c = (size_t)r - k;
      memcpy(m->msg_iov[i].iov_base, b + k, c);
      k += c;
    }
  }
  m->msg_controllen = 0;
  m->msg_flags = 0;
  free(b);
  return r;
}

int sp_w32_getsockopt(int fd, int level, int name, void *val, int *len) {
  SOCKET s = sp_w32_need(fd);
  if (s == INVALID_SOCKET) return -1;
  if (level == SOL_SOCKET && (name == SO_RCVTIMEO || name == SO_SNDTIMEO) && len && *len >= (int)sizeof(struct timeval)) {
    DWORD ms = 0; int l = sizeof ms;
    if (getsockopt(s, level, name, (char *)&ms, &l) != 0) return sp_w32_sockfail();
    struct timeval *tv = (struct timeval *)val;
    tv->tv_sec = (long)(ms / 1000); tv->tv_usec = (long)((ms % 1000) * 1000);
    *len = sizeof *tv;
    return 0;
  }
  if (level == SOL_SOCKET && name == SO_LINGER && len && *len >= (int)sizeof(struct sp_linger)) {
    struct linger wl; int l = sizeof wl;
    if (getsockopt(s, level, name, (char *)&wl, &l) != 0) return sp_w32_sockfail();
    struct sp_linger *pl = (struct sp_linger *)val;
    pl->l_onoff = wl.l_onoff; pl->l_linger = wl.l_linger;
    *len = sizeof *pl;
    return 0;
  }
  if (level == SOL_SOCKET && name == SO_REUSEADDR && len && *len >= (int)sizeof(int)) {
    AcquireSRWLockExclusive(&sp_w32_fds_lock);
    sp_w32_fdent *e = sp_w32_ent(fd, 0);
    *(int *)val = e ? e->reuseaddr : 0;
    ReleaseSRWLockExclusive(&sp_w32_fds_lock);
    *len = sizeof(int);
    return 0;
  }
  int r = getsockopt(s, level, name, (char *)val, len);
  if (r != 0) return sp_w32_sockfail();
  /* winsock answers a BOOL option in one byte on some providers */
  if (len && *len == 1 && level != SOL_SOCKET) { int v = *(unsigned char *)val; *(int *)val = v; *len = sizeof(int); }
  return 0;
}

int sp_w32_setsockopt(int fd, int level, int name, const void *val, int len) {
  SOCKET s = sp_w32_need(fd);
  if (s == INVALID_SOCKET) return -1;
  if (level == SOL_SOCKET && (name == SO_RCVTIMEO || name == SO_SNDTIMEO) && len >= (int)sizeof(struct timeval)) {
    const struct timeval *tv = (const struct timeval *)val;
    DWORD ms = (DWORD)(tv->tv_sec * 1000 + tv->tv_usec / 1000);
    if (ms == 0 && tv->tv_usec > 0) ms = 1;
    return setsockopt(s, level, name, (const char *)&ms, sizeof ms) == 0 ? 0 : sp_w32_sockfail();
  }
  if (level == SOL_SOCKET && name == SO_LINGER && len >= (int)sizeof(struct sp_linger)) {
    const struct sp_linger *pl = (const struct sp_linger *)val;
    struct linger wl; wl.l_onoff = (u_short)(pl->l_onoff != 0); wl.l_linger = (u_short)pl->l_linger;
    return setsockopt(s, level, name, (const char *)&wl, sizeof wl) == 0 ? 0 : sp_w32_sockfail();
  }
  /* POSIX SO_REUSEADDR lets a server rebind a port in TIME_WAIT, which
     Windows allows anyway; winsock's SO_REUSEADDR lets a second server take
     a port that is in use, which POSIX's never does. Recorded, not passed. */
  if (level == SOL_SOCKET && name == SO_REUSEADDR) {
    AcquireSRWLockExclusive(&sp_w32_fds_lock);
    sp_w32_fdent *e = sp_w32_ent(fd, 0);
    if (e) e->reuseaddr = len >= (int)sizeof(int) ? *(const int *)val != 0 : 0;
    ReleaseSRWLockExclusive(&sp_w32_fds_lock);
    return 0;
  }
  return setsockopt(s, level, name, (const char *)val, len) == 0 ? 0 : sp_w32_sockfail();
}

int sp_w32_getsockname(int fd, struct sockaddr *a, int *len) {
  SOCKET s = sp_w32_need(fd);
  if (s == INVALID_SOCKET) return -1;
  struct sockaddr_storage ss; int sl = sizeof ss;
  if (getsockname(s, (struct sockaddr *)&ss, &sl) != 0) {
    /* an unbound socket: POSIX answers its family and a zero address,
       winsock refuses (WSAEINVAL); the family is the socket's own */
    WSAPROTOCOL_INFOW pi; int pl = sizeof pi;
    if (WSAGetLastError() != WSAEINVAL ||
        getsockopt(s, SOL_SOCKET, SO_PROTOCOL_INFOW, (char *)&pi, &pl) != 0) return sp_w32_sockfail();
    memset(&ss, 0, sizeof ss);
    ss.ss_family = (ADDRESS_FAMILY)pi.iAddressFamily;
    sl = pi.iAddressFamily == AF_INET6 ? (int)sizeof(struct sockaddr_in6) :
         pi.iAddressFamily == AF_INET ? (int)sizeof(struct sockaddr_in) : (int)sizeof(ADDRESS_FAMILY);
  }
  sp_w32_addr_out(&ss, sl, a, len);
  return 0;
}

int sp_w32_getpeername(int fd, struct sockaddr *a, int *len) {
  SOCKET s = sp_w32_need(fd);
  if (s == INVALID_SOCKET) return -1;
  struct sockaddr_storage ss; int sl = sizeof ss;
  if (getpeername(s, (struct sockaddr *)&ss, &sl) != 0) return sp_w32_sockfail();
  sp_w32_addr_out(&ss, sl, a, len);
  return 0;
}

/* socketpair: two connected TCP sockets on the loopback (AF_UNIX pairs need
   a path on Windows; a stream is a stream), or a pair of UDP sockets
   connected to each other */
int sp_w32_socketpair(int domain, int type, int protocol, int sv[2]) {
  (void)domain; (void)protocol;
  sp_w32_wsa();
  int nb = (type & SP_SOCK_NONBLOCK) != 0, ce = (type & SP_SOCK_CLOEXEC) != 0;
  type &= ~(SP_SOCK_NONBLOCK | SP_SOCK_CLOEXEC);
  struct sockaddr_in a; int al = sizeof a;
  memset(&a, 0, sizeof a);
  a.sin_family = AF_INET; a.sin_addr.s_addr = htonl(INADDR_LOOPBACK); a.sin_port = 0;
  SOCKET x = INVALID_SOCKET, y = INVALID_SOCKET, l = INVALID_SOCKET;
  if (type == SOCK_DGRAM) {
    x = WSASocketW(AF_INET, SOCK_DGRAM, 0, NULL, 0, WSA_FLAG_NO_HANDLE_INHERIT);
    y = WSASocketW(AF_INET, SOCK_DGRAM, 0, NULL, 0, WSA_FLAG_NO_HANDLE_INHERIT);
    struct sockaddr_in ax = a, ay = a; int lx = sizeof ax, ly = sizeof ay;
    if (x == INVALID_SOCKET || y == INVALID_SOCKET ||
        bind(x, (struct sockaddr *)&ax, sizeof ax) || bind(y, (struct sockaddr *)&ay, sizeof ay) ||
        getsockname(x, (struct sockaddr *)&ax, &lx) || getsockname(y, (struct sockaddr *)&ay, &ly) ||
        connect(x, (struct sockaddr *)&ay, ly) || connect(y, (struct sockaddr *)&ax, lx)) goto fail;
  } else {
    l = WSASocketW(AF_INET, SOCK_STREAM, 0, NULL, 0, WSA_FLAG_NO_HANDLE_INHERIT);
    if (l == INVALID_SOCKET || bind(l, (struct sockaddr *)&a, sizeof a) ||
        getsockname(l, (struct sockaddr *)&a, &al) || listen(l, 1)) goto fail;
    x = WSASocketW(AF_INET, SOCK_STREAM, 0, NULL, 0, WSA_FLAG_NO_HANDLE_INHERIT);
    if (x == INVALID_SOCKET || connect(x, (struct sockaddr *)&a, al)) goto fail;
    y = accept(l, NULL, NULL);
    if (y == INVALID_SOCKET) goto fail;
    closesocket(l);
    BOOL one = TRUE;
    setsockopt(x, IPPROTO_TCP, TCP_NODELAY, (const char *)&one, sizeof one);
    setsockopt(y, IPPROTO_TCP, TCP_NODELAY, (const char *)&one, sizeof one);
  }
  sv[0] = sp_w32_wrap(x, nb, ce);
  if (sv[0] < 0) { closesocket(y); return -1; }
  sv[1] = sp_w32_wrap(y, nb, ce);
  if (sv[1] < 0) { sp_w32_close(sv[0]); return -1; }
  return 0;
fail:
  {
    int e = WSAGetLastError();
    if (l != INVALID_SOCKET) closesocket(l);
    if (x != INVALID_SOCKET) closesocket(x);
    if (y != INVALID_SOCKET) closesocket(y);
    errno = sp_w32_errno_wsa(e);
    return -1;
  }
}

/* ===================================================================== */
/* fd I/O                                                                */
/* ===================================================================== */

/* The room in a pipe's buffer, from its write end: a write end cannot be
   peeked, and POLLOUT has to mean a write will not block -- a writer that
   blocks in WriteFile holds its OS worker, and the reader that would drain
   the pipe may be a green thread on that worker. -1 when the pipe says
   nothing (an older Windows, a handle without the right). */
typedef struct {
  ULONG NamedPipeType, NamedPipeConfiguration, MaximumInstances, CurrentInstances,
        InboundQuota, ReadDataAvailable, OutboundQuota, WriteQuotaAvailable,
        NamedPipeState, NamedPipeEnd;
} sp_w32_pipe_info;
typedef struct { union { LONG Status; PVOID Pointer; } u; ULONG_PTR Information; } sp_w32_iosb;
typedef LONG (NTAPI *sp_w32_nqif_fn)(HANDLE, sp_w32_iosb *, PVOID, ULONG, int);
static long sp_w32_pipe_room(HANDLE h, int *closing) {
  static sp_w32_nqif_fn nqif;
  static int looked;
  if (!looked) { nqif = (sp_w32_nqif_fn)(void *)GetProcAddress(GetModuleHandleW(L"ntdll.dll"), "NtQueryInformationFile"); looked = 1; }
  if (!nqif) return -1;
  sp_w32_iosb io; sp_w32_pipe_info pi;
  memset(&pi, 0, sizeof pi);
  if (nqif(h, &io, &pi, sizeof pi, 24 /* FilePipeLocalInformation */) < 0) return -1;
  *closing = pi.NamedPipeState == 4;   /* FILE_PIPE_CLOSING_STATE: the other end is gone */
  return (long)pi.WriteQuotaAvailable;
}

long long sp_w32_read(int fd, void *buf, size_t n) {
  SOCKET s = sp_w32_sock(fd);
  if (s != INVALID_SOCKET) return sp_w32_recv(fd, buf, n, 0);
  unsigned int k = n > 0x7fffffff ? 0x7fffffff : (unsigned int)n;
  /* O_NONBLOCK on a pipe: what is waiting, EAGAIN when nothing is, 0 at
     the end -- from PeekNamedPipe, so the read never waits (a pipe's
     PIPE_NOWAIT mode cannot be set from its read end) */
  if (sp_w32_nonblocking(fd)) {
    HANDLE h = (HANDLE)_get_osfhandle(fd);
    if (GetFileType(h) == FILE_TYPE_PIPE) {
      DWORD avail = 0;
      if (!PeekNamedPipe(h, NULL, 0, NULL, &avail, NULL)) {
        DWORD e = GetLastError();
        if (e == ERROR_BROKEN_PIPE || e == ERROR_PIPE_NOT_CONNECTED) return 0;
        errno = sp_w32_errno_of(e);
        return -1;
      }
      if (avail == 0) { errno = EAGAIN; return -1; }
      if (k > avail) k = avail;
      DWORD got = 0;
      if (ReadFile(h, buf, k, &got, NULL)) return got;
      DWORD e = GetLastError();
      if (e == ERROR_BROKEN_PIPE || e == ERROR_HANDLE_EOF) return 0;
      errno = sp_w32_errno_of(e);
      return -1;
    }
  }
  return _read(fd, buf, k);
}

long long sp_w32_write(int fd, const void *buf, size_t n) {
  SOCKET s = sp_w32_sock(fd);
  if (s != INVALID_SOCKET) return sp_w32_send(fd, buf, n, 0);
  unsigned int k = n > 0x7fffffff ? 0x7fffffff : (unsigned int)n;
  /* O_NONBLOCK on a pipe: as much as the buffer has room for, EAGAIN when
     it has none -- the room read from the pipe, so the write never waits */
  if (sp_w32_nonblocking(fd)) {
    HANDLE h = (HANDLE)_get_osfhandle(fd);
    if (GetFileType(h) == FILE_TYPE_PIPE) {
      int closing = 0;
      long room = sp_w32_pipe_room(h, &closing);
      if (closing) { errno = EPIPE; return -1; }
      if (room == 0) { errno = EAGAIN; return -1; }
      if (room > 0 && (long)k > room) k = (unsigned int)room;
      DWORD put = 0;
      if (!WriteFile(h, buf, k, &put, NULL)) {
        DWORD e = GetLastError();
        errno = e == ERROR_NO_DATA ? EPIPE : sp_w32_errno_of(e);
        return -1;
      }
      return put;
    }
  }
  if (k == 0) return 0;
  return _write(fd, buf, k);
}

long long sp_w32_readv(int fd, const struct sp_iovec *iov, int n) {
  long long tot = 0;
  for (int i = 0; i < n; i++) {
    long long r = sp_w32_read(fd, iov[i].iov_base, iov[i].iov_len);
    if (r < 0) return tot ? tot : -1;
    tot += r;
    if ((size_t)r < iov[i].iov_len) break;
  }
  return tot;
}
long long sp_w32_writev(int fd, const struct sp_iovec *iov, int n) {
  long long tot = 0;
  for (int i = 0; i < n; i++) {
    long long r = sp_w32_write(fd, iov[i].iov_base, iov[i].iov_len);
    if (r < 0) return tot ? tot : -1;
    tot += r;
    if ((size_t)r < iov[i].iov_len) break;
  }
  return tot;
}

/* fclose on a socket's stream: the CRT closes the fd's duplicate handle,
   which leaves the SOCKET itself open -- no FIN reaches the peer, and a read
   there waits forever. The stream is closed first (it flushes what it
   holds), then the SOCKET. */
int sp_w32_fclose(FILE *f) {
  if (!f) { errno = EINVAL; return EOF; }
  int fd = _fileno(f);
  SOCKET s = INVALID_SOCKET;
  if (fd >= 0) {
    AcquireSRWLockExclusive(&sp_w32_fds_lock);
    sp_w32_fdent *e = sp_w32_ent(fd, 0);
    if (e && e->s != INVALID_SOCKET) { s = e->s; e->s = INVALID_SOCKET; e->h = INVALID_HANDLE_VALUE; e->nonblock = 0; e->cloexec = 0; }
    ReleaseSRWLockExclusive(&sp_w32_fds_lock);
  }
  int r = fclose(f);
  if (s != INVALID_SOCKET) closesocket(s);
  return r;
}

int sp_w32_close(int fd) {
  AcquireSRWLockExclusive(&sp_w32_fds_lock);
  sp_w32_fdent *e = sp_w32_ent(fd, 0);
  SOCKET s = INVALID_SOCKET;
  if (e) { s = e->s; e->s = INVALID_SOCKET; e->h = INVALID_HANDLE_VALUE; e->nonblock = 0; e->cloexec = 0; }
  ReleaseSRWLockExclusive(&sp_w32_fds_lock);
  if (s != INVALID_SOCKET) closesocket(s);
  return _close(fd);
}

/* a socket's own copy for a second fd, so closing one leaves the other */
static SOCKET sp_w32_sock_dup(SOCKET s) {
  WSAPROTOCOL_INFOW pi;
  if (WSADuplicateSocketW(s, GetCurrentProcessId(), &pi) != 0) return INVALID_SOCKET;
  return WSASocketW(FROM_PROTOCOL_INFO, FROM_PROTOCOL_INFO, FROM_PROTOCOL_INFO, &pi, 0, WSA_FLAG_NO_HANDLE_INHERIT);
}

int sp_w32_dup(int fd) {
  SOCKET s = sp_w32_sock(fd);
  if (s == INVALID_SOCKET) return _dup(fd);
  SOCKET c = sp_w32_sock_dup(s);
  if (c == INVALID_SOCKET) return sp_w32_sockfail();
  return sp_w32_wrap(c, sp_w32_nonblocking(fd), 0);
}

int sp_w32_dup2(int fd, int fd2) {
  if (fd == fd2) return (HANDLE)_get_osfhandle(fd) == INVALID_HANDLE_VALUE ? (errno = EBADF, -1) : fd2;
  SOCKET s = sp_w32_sock(fd);
  /* fd2 stops being whatever it was */
  SOCKET old = sp_w32_sock(fd2);
  if (s == INVALID_SOCKET) {
    if (_dup2(fd, fd2) != 0) return -1;
    if (old != INVALID_SOCKET) closesocket(old);
    AcquireSRWLockExclusive(&sp_w32_fds_lock);
    sp_w32_fdent *e = sp_w32_ent(fd2, 1);
    if (e) { e->s = INVALID_SOCKET; e->h = (HANDLE)_get_osfhandle(fd2); e->nonblock = 0; e->cloexec = 0; }
    ReleaseSRWLockExclusive(&sp_w32_fds_lock);
    return fd2;
  }
  SOCKET c = sp_w32_sock_dup(s);
  if (c == INVALID_SOCKET) return sp_w32_sockfail();
  int tmp = sp_w32_wrap(c, sp_w32_nonblocking(fd), 0);
  if (tmp < 0) return -1;
  int r = _dup2(tmp, fd2);
  /* fd2 holds its own duplicate of the handle now; the tmp fd goes, the
     SOCKET stays with fd2 */
  AcquireSRWLockExclusive(&sp_w32_fds_lock);
  sp_w32_fdent *te = sp_w32_ent(tmp, 0);
  if (te) { te->s = INVALID_SOCKET; te->h = INVALID_HANDLE_VALUE; }
  sp_w32_fdent *e = r == 0 ? sp_w32_ent(fd2, 1) : NULL;
  if (e) { e->s = c; e->h = (HANDLE)_get_osfhandle(fd2); e->nonblock = sp_w32_nonblocking(fd); e->cloexec = 0; }
  ReleaseSRWLockExclusive(&sp_w32_fds_lock);
  _close(tmp);
  if (r != 0) { closesocket(c); return -1; }
  if (old != INVALID_SOCKET) closesocket(old);
  return fd2;
}

int sp_w32_pipe(int fds[2]) {
  return _pipe(fds, 65536, _O_BINARY | _O_NOINHERIT);
}

int sp_w32_isatty(int fd) {
  HANDLE h = (HANDLE)_get_osfhandle(fd);
  if (h == INVALID_HANDLE_VALUE) { errno = EBADF; return 0; }
  DWORD m;
  /* the CRT's _isatty says yes to NUL, a character device that is no terminal */
  if (GetFileType(h) == FILE_TYPE_CHAR && GetConsoleMode(h, &m)) return 1;
  errno = ENOTTY;
  return 0;
}

int fcntl(int fd, int cmd, ...) {
  va_list ap; va_start(ap, cmd);
  long arg = va_arg(ap, long);
  va_end(ap);
  HANDLE h = (HANDLE)_get_osfhandle(fd);
  if (h == INVALID_HANDLE_VALUE) { errno = EBADF; return -1; }
  switch (cmd) {
    /* close-on-exec is a handle a child does not inherit, which is how the
       shim opens files and sockets (as CRuby opens them close-on-exec) */
    case SP_F_GETFD: {
      DWORD hf = 0;
      if (!GetHandleInformation(h, &hf)) return 0;
      return (hf & HANDLE_FLAG_INHERIT) ? 0 : SP_FD_CLOEXEC;
    }
    case SP_F_SETFD: {
      SetHandleInformation(h, HANDLE_FLAG_INHERIT, (arg & SP_FD_CLOEXEC) ? 0 : HANDLE_FLAG_INHERIT);
      AcquireSRWLockExclusive(&sp_w32_fds_lock);
      sp_w32_fdent *e = sp_w32_ent(fd, 1);
      if (e) e->cloexec = (arg & SP_FD_CLOEXEC) != 0;
      ReleaseSRWLockExclusive(&sp_w32_fds_lock);
      return 0;
    }
    case SP_F_GETFL: {
      int r = _O_RDWR;
      if (sp_w32_nonblocking(fd)) r |= SP_O_NONBLOCK;
      return r;
    }
    case SP_F_SETFL: {
      int nb = (arg & SP_O_NONBLOCK) != 0;
      SOCKET s = sp_w32_sock(fd);
      if (s != INVALID_SOCKET) {
        u_long v = (u_long)nb;
        if (ioctlsocket(s, FIONBIO, &v) != 0) return sp_w32_sockfail();
      }   /* a pipe's is the shim's own (sp_w32_read, sp_w32_write) */
      AcquireSRWLockExclusive(&sp_w32_fds_lock);
      sp_w32_fdent *e = sp_w32_ent(fd, 1);
      if (e) e->nonblock = nb;
      ReleaseSRWLockExclusive(&sp_w32_fds_lock);
      return 0;
    }
    case SP_F_DUPFD:
    case SP_F_DUPFD_CLOEXEC: {
      int got[64], ng = 0, r = -1;
      for (;;) {
        int d = sp_w32_dup(fd);
        if (d < 0) break;
        if (d >= arg) { r = d; break; }
        if (ng == 64) { sp_w32_close(d); errno = EMFILE; break; }
        got[ng++] = d;
      }
      for (int i = 0; i < ng; i++) sp_w32_close(got[i]);
      if (r >= 0 && cmd == SP_F_DUPFD_CLOEXEC) fcntl(r, SP_F_SETFD, (long)SP_FD_CLOEXEC);
      return r;
    }
    default:
      errno = EINVAL;
      return -1;
  }
}

int ioctl(int fd, unsigned long req, ...) {
  va_list ap; va_start(ap, req);
  void *arg = va_arg(ap, void *);
  va_end(ap);
  HANDLE h = (HANDLE)_get_osfhandle(fd);
  if (h == INVALID_HANDLE_VALUE) { errno = EBADF; return -1; }
  SOCKET s = sp_w32_sock(fd);
  switch (req) {
    case SP_TIOCGWINSZ: {
      CONSOLE_SCREEN_BUFFER_INFO ci;
      if (!GetConsoleScreenBufferInfo(h, &ci)) { errno = ENOTTY; return -1; }
      struct sp_winsize *ws = (struct sp_winsize *)arg;
      ws->ws_col = (unsigned short)(ci.srWindow.Right - ci.srWindow.Left + 1);
      ws->ws_row = (unsigned short)(ci.srWindow.Bottom - ci.srWindow.Top + 1);
      ws->ws_xpixel = ws->ws_ypixel = 0;
      return 0;
    }
    case SP_FIONREAD: {
      int *out = (int *)arg;
      if (s != INVALID_SOCKET) {
        u_long n = 0;
        if (ioctlsocket(s, FIONREAD, &n) != 0) return sp_w32_sockfail();
        *out = (int)n; return 0;
      }
      DWORD t = GetFileType(h);
      if (t == FILE_TYPE_PIPE) {
        DWORD avail = 0;
        if (!PeekNamedPipe(h, NULL, 0, NULL, &avail, NULL)) {
          if (GetLastError() == ERROR_BROKEN_PIPE) { *out = 0; return 0; }
          errno = sp_w32_errno_of(GetLastError()); return -1;
        }
        *out = (int)avail; return 0;
      }
      if (t == FILE_TYPE_DISK) {
        LARGE_INTEGER sz, pos, zero = {0};
        if (!GetFileSizeEx(h, &sz) || !SetFilePointerEx(h, zero, &pos, FILE_CURRENT)) { errno = EINVAL; return -1; }
        *out = sz.QuadPart > pos.QuadPart ? (int)(sz.QuadPart - pos.QuadPart) : 0;
        return 0;
      }
      *out = 0;
      return 0;
    }
    case SP_FIONBIO: {
      int nb = arg && *(int *)arg;
      return fcntl(fd, SP_F_SETFL, nb ? (long)SP_O_NONBLOCK : 0L);
    }
    default:
      errno = ENOTTY;
      return -1;
  }
}

/* ===================================================================== */
/* poll and select                                                       */
/* ===================================================================== */

/* whether a console has a keystroke to read: a console signals for focus
   and mouse events too, which a read would block past */
static int sp_w32_console_readable(HANDLE h) {
  DWORD n = 0;
  if (!GetNumberOfConsoleInputEvents(h, &n) || n == 0) return 0;
  INPUT_RECORD rec[64];
  DWORD got = 0;
  if (!PeekConsoleInputW(h, rec, n > 64 ? 64 : n, &got)) return 1;
  for (DWORD i = 0; i < got; i++)
    if (rec[i].EventType == KEY_EVENT && rec[i].Event.KeyEvent.bKeyDown && rec[i].Event.KeyEvent.uChar.UnicodeChar) return 1;
  /* nothing a read would return: drop the rest so the next poll is cheap */
  if (got == n) { INPUT_RECORD sink[64]; DWORD k; ReadConsoleInputW(h, sink, got, &k); }
  return 0;
}

static short sp_w32_poll_one(int fd, short ev) {
  HANDLE h = (HANDLE)_get_osfhandle(fd);
  if (h == INVALID_HANDLE_VALUE) return POLLNVAL;
  short re = 0;
  switch (GetFileType(h)) {
    case FILE_TYPE_DISK:
      re = ev & (SP_POLLIN | SP_POLLOUT);
      break;
    case FILE_TYPE_CHAR: {
      DWORD m;
      if (GetConsoleMode(h, &m)) {
        if ((ev & SP_POLLIN) && sp_w32_console_readable(h)) re |= ev & SP_POLLIN;
        if (ev & SP_POLLOUT) re |= SP_POLLOUT;
      } else re = ev & (SP_POLLIN | SP_POLLOUT);   /* NUL and other devices never wait */
      break;
    }
    case FILE_TYPE_PIPE: {
      DWORD avail = 0;
      if (ev & SP_POLLOUT) {
        /* writable: PIPE_BUF bytes of room, as POSIX has it */
        int closing = 0;
        long room = sp_w32_pipe_room(h, &closing);
        if (closing) re |= POLLERR;
        else if (room < 0 || room >= 4096) re |= SP_POLLOUT;
      }
      if (PeekNamedPipe(h, NULL, 0, NULL, &avail, NULL)) {
        if ((ev & SP_POLLIN) && avail > 0) re |= ev & SP_POLLIN;
      } else {
        DWORD e = GetLastError();
        if (e == ERROR_BROKEN_PIPE || e == ERROR_PIPE_NOT_CONNECTED) re |= (ev & SP_POLLOUT) ? POLLERR | POLLHUP : POLLHUP;
      }
      break;
    }
    default:
      re = ev & (SP_POLLIN | SP_POLLOUT);
  }
  return re;
}

int poll(struct sp_pollfd *fds, unsigned long n, int timeout) {
  sp_w32_wsa();
  ULONGLONG start = GetTickCount64();
  WSAPOLLFD sb[64], *ws = n <= 64 ? sb : (WSAPOLLFD *)malloc(sizeof *ws * n);
  int *wi = (int *)malloc(sizeof(int) * (n ? n : 1));
  if (!ws || !wi) { if (ws != sb) free(ws); free(wi); errno = ENOMEM; return -1; }
  int spins = 0, rc = 0;
  for (;;) {
    int ready = 0, nsock = 0, nother = 0;
    for (unsigned long i = 0; i < n; i++) {
      fds[i].revents = 0;
      if (fds[i].fd < 0) continue;
      SOCKET s = sp_w32_sock(fds[i].fd);
      if (s != INVALID_SOCKET) {
        ws[nsock].fd = s;
        ws[nsock].events = (short)(((fds[i].events & SP_POLLIN) ? POLLRDNORM : 0) | ((fds[i].events & SP_POLLOUT) ? POLLWRNORM : 0));
        ws[nsock].revents = 0;
        wi[nsock++] = (int)i;
        continue;
      }
      nother++;
      fds[i].revents = sp_w32_poll_one(fds[i].fd, fds[i].events);
      if (fds[i].revents) ready++;
    }
    int remain = -1;
    if (timeout >= 0) {
      ULONGLONG el = GetTickCount64() - start;
      remain = el >= (ULONGLONG)timeout ? 0 : (int)((ULONGLONG)timeout - el);
    }
    if (nsock) {
      /* only sockets: winsock does the waiting */
      int wait = (ready || nother) ? 0 : remain;
      int r = WSAPoll(ws, (ULONG)nsock, wait);
      if (r == SOCKET_ERROR) { rc = sp_w32_sockfail(); break; }
      for (int k = 0; k < nsock; k++) {
        short re = ws[k].revents, ev = fds[wi[k]].events, out = 0;
        if (re & (POLLRDNORM | POLLRDBAND)) out |= ev & SP_POLLIN;
        if (re & POLLWRNORM) out |= ev & SP_POLLOUT;
        out |= re & (POLLERR | POLLHUP | POLLNVAL);
        /* a peer's close reads as readable (the read answers 0), as on POSIX */
        if ((re & POLLHUP) && (ev & SP_POLLIN)) out |= ev & SP_POLLIN;
        fds[wi[k]].revents = out;
        if (out) ready++;
      }
      if (!nother && (ready || remain == 0 || wait != 0)) { rc = ready; if (ready || remain == 0) break; continue; }
    }
    if (ready || remain == 0) { rc = ready; break; }
    /* pipes and consoles have no readiness to wait on: look again shortly */
    if (spins < 50) { spins++; SwitchToThread(); }
    else {
      DWORD ms = spins < 200 ? 1 : 5;
      spins++;
      if (remain >= 0 && (DWORD)remain < ms) ms = (DWORD)remain;
      if (nsock) {
        int r = WSAPoll(ws, (ULONG)nsock, (int)ms);
        (void)r;
      } else Sleep(ms);
    }
  }
  if (ws != sb) free(ws);
  free(wi);
  return rc;
}

typedef struct { unsigned long fds_bits[1024 / (8 * sizeof(unsigned long))]; } sp_w32_fdset;
#define SP_BITS (8 * sizeof(unsigned long))
#define SP_ISSET(fd, s) (((s)->fds_bits[(fd) / SP_BITS] >> ((fd) % SP_BITS)) & 1UL)
#define SP_SET(fd, s)   ((s)->fds_bits[(fd) / SP_BITS] |= 1UL << ((fd) % SP_BITS))

int sp_w32_select(int nfds, sp_w32_fdset *r, sp_w32_fdset *w, sp_w32_fdset *e, struct timeval *tv) {
  if (nfds < 0 || nfds > 1024) { errno = EINVAL; return -1; }
  struct sp_pollfd *pf = (struct sp_pollfd *)malloc(sizeof *pf * (size_t)(nfds ? nfds : 1));
  if (!pf) { errno = ENOMEM; return -1; }
  int np = 0;
  for (int fd = 0; fd < nfds; fd++) {
    short ev = 0;
    if (r && SP_ISSET(fd, r)) ev |= SP_POLLIN;
    if (w && SP_ISSET(fd, w)) ev |= SP_POLLOUT;
    if (e && SP_ISSET(fd, e)) ev |= 0;
    if (ev || (e && SP_ISSET(fd, e))) { pf[np].fd = fd; pf[np].events = ev; pf[np].revents = 0; np++; }
  }
  int ms = tv ? (int)(tv->tv_sec * 1000 + (tv->tv_usec + 999) / 1000) : -1;
  int got = poll(pf, (unsigned long)np, ms);
  if (got < 0) { free(pf); return -1; }
  if (r) memset(r, 0, sizeof *r);
  if (w) memset(w, 0, sizeof *w);
  if (e) memset(e, 0, sizeof *e);
  int cnt = 0;
  for (int i = 0; i < np; i++) {
    short re = pf[i].revents;
    if (re & POLLNVAL) { free(pf); errno = EBADF; return -1; }
    if (r && (re & (SP_POLLIN | POLLHUP | POLLERR)) && (pf[i].events & SP_POLLIN)) { SP_SET(pf[i].fd, r); cnt++; }
    if (w && (re & (SP_POLLOUT | POLLERR)) && (pf[i].events & SP_POLLOUT)) { SP_SET(pf[i].fd, w); cnt++; }
  }
  free(pf);
  return cnt;
}

/* ===================================================================== */
/* names and addresses                                                   */
/* ===================================================================== */

const struct in6_addr sp_w32_in6addr_any = {{{0}}};
const struct in6_addr sp_w32_in6addr_loopback = {{{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1}}};

int sp_w32_gethostname(char *name, size_t len) {
  DWORD n = (DWORD)len;
  if (GetComputerNameExA(ComputerNameDnsHostname, name, &n)) return 0;
  if (GetLastError() == ERROR_MORE_DATA) { errno = ENAMETOOLONG; return -1; }
  errno = EFAULT;
  return -1;
}

int sp_w32_inet_pton(int af, const char *src, void *dst) {
  sp_w32_wsa();
  int r = inet_pton(af, src, dst);
  if (r < 0) { errno = EAFNOSUPPORT; return -1; }
  return r;
}
const char *sp_w32_inet_ntop(int af, const void *src, char *dst, int size) {
  sp_w32_wsa();
  const char *r = inet_ntop(af, (void *)src, dst, (size_t)size);
  if (!r) errno = af == AF_INET || af == AF_INET6 ? ENOSPC : EAFNOSUPPORT;
  return r;
}
unsigned long sp_w32_inet_addr(const char *cp) { sp_w32_wsa(); return inet_addr(cp); }
char *sp_w32_inet_ntoa(struct in_addr in) { sp_w32_wsa(); return inet_ntoa(in); }
int sp_w32_inet_aton(const char *cp, struct in_addr *in) {
  sp_w32_wsa();
  unsigned long a = inet_addr(cp);
  if (a == INADDR_NONE && strcmp(cp, "255.255.255.255") != 0) return 0;
  if (in) in->s_addr = a;
  return 1;
}

int sp_w32_getaddrinfo(const char *node, const char *service, const struct addrinfo *hints, struct addrinfo **res) {
  sp_w32_wsa();
  return getaddrinfo(node, service, hints, res);
}
void sp_w32_freeaddrinfo(struct addrinfo *ai) { freeaddrinfo(ai); }
int sp_w32_getnameinfo(const struct sockaddr *sa, int salen, char *host, int hostlen, char *serv, int servlen, int flags) {
  sp_w32_wsa();
  return getnameinfo(sa, salen, host, (DWORD)hostlen, serv, (DWORD)servlen, flags);
}
struct hostent *sp_w32_gethostbyname(const char *name) { sp_w32_wsa(); return gethostbyname(name); }

const char *sp_w32_gai_strerror(int code) {
  switch (code) {
    case 0: return "Success";
    case EAI_AGAIN: return "Temporary failure in name resolution";
    case EAI_BADFLAGS: return "Bad value for ai_flags";
    case EAI_FAIL: return "Non-recoverable failure in name resolution";
    case EAI_FAMILY: return "ai_family not supported";
    case EAI_MEMORY: return "Memory allocation failure";
    case EAI_NONAME: return "Name or service not known";
    case EAI_SERVICE: return "Servname not supported for ai_socktype";
    case EAI_SOCKTYPE: return "ai_socktype not supported";
    case -11: return "System error";
    case -12: return "Argument buffer overflow";
    default: return "Unknown error";
  }
}

#endif /* _WIN32 */
