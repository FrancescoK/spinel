/* Windows (MinGW-w64, UCRT): the POSIX surface the runtime is written
   against, for the native Windows build. Like lib/wasi beside it, this
   directory is on the include path only for that build (-Ilib/win32, from
   common.mk and from the driver when it was itself built for Windows), so a
   POSIX build never sees it, and lib/*.c compiles unchanged.

   Each header here is named after the POSIX one it stands in for. Where
   MinGW ships the header, the shim #include_next's it and adds what it
   leaves out; where MinGW has no such header, the shim is the whole of it.
   The definitions live in sp_win32.c, the one file here that includes
   <windows.h> -- the shims do not, so neither the runtime nor a generated
   program sees its macros (min, max, small, ERROR, ...).

   What Windows has no answer for fails the way an unsupported call fails on
   a POSIX system: -1 with errno set (ENOSYS), so the Errno the runtime
   already raises reaches the program instead of a link error.

   This header is the shims' shared part: the sp_w32_* names the macros in
   the others redirect to. */
#ifndef SP_WIN32_H
#define SP_WIN32_H
#ifdef _WIN32

#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>

#ifdef __cplusplus
extern "C" {
#endif

/* POSIX ids: Windows has none; uid/gid answer 0 */
#ifndef _SP_W32_ID_T
#define _SP_W32_ID_T
typedef unsigned int uid_t;
typedef unsigned int gid_t;
typedef unsigned int id_t;
#endif
/* MinGW defines sigset_t only under _POSIX; suseconds_t not at all */
#ifndef _SP_W32_SIGSET_T
#define _SP_W32_SIGSET_T
#ifndef _POSIX
typedef _sigset_t sigset_t;
#endif
typedef long suseconds_t;
#endif

/* An fd that is a socket (sockets are not CRT descriptors on Windows; the
   shim pairs each with one, see sys/socket.h) */
int sp_w32_is_socket(int fd);

/* I/O that must see sockets, pipes and the console */
long long sp_w32_read(int fd, void *buf, size_t n);
long long sp_w32_write(int fd, const void *buf, size_t n);
int sp_w32_close(int fd);
int sp_w32_dup(int fd);
int sp_w32_dup2(int fd, int fd2);
int sp_w32_pipe(int fds[2]);
int sp_w32_isatty(int fd);

/* files and paths */
int sp_w32_mkdir(const char *path, int mode);
char *sp_w32_realpath(const char *path, char *resolved);
long long sp_w32_readlink(const char *path, char *buf, size_t n);
int sp_w32_symlink(const char *target, const char *path);
int sp_w32_link(const char *target, const char *path);
int sp_w32_unlink(const char *path);
int sp_w32_rename(const char *from, const char *to);
int sp_w32_access(const char *path, int mode);
int sp_w32_chdir(const char *path);
const char *sp_w32_path(const char *path, char *buf, size_t n);

/* processes */
int sp_w32_system(const char *cmd);

#ifdef __cplusplus
}
#endif

#endif /* _WIN32 */
#endif /* SP_WIN32_H */
