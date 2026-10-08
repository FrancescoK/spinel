/* Windows: the UCRT's <fcntl.h> plus fcntl(2) for what the runtime asks of
   it: F_GETFD/F_SETFD (close-on-exec is "not inherited" on Windows),
   F_GETFL/F_SETFL (O_NONBLOCK on a pipe or a socket), F_DUPFD. Every open
   is binary: a Ruby program's bytes are its bytes, as on POSIX. */
#ifndef SP_WIN32_FCNTL_H
#define SP_WIN32_FCNTL_H
#include_next <fcntl.h>
#include <io.h>
#include "sp_win32.h"

#define F_DUPFD   0
#define F_GETFD   1
#define F_SETFD   2
#define F_GETFL   3
#define F_SETFL   4
#define F_GETLK   5
#define F_SETLK   6
#define F_SETLKW  7
#define F_DUPFD_CLOEXEC 1030
#define FD_CLOEXEC 1

#ifndef O_NONBLOCK
#define O_NONBLOCK 0x00800000
#endif
#define O_NDELAY   O_NONBLOCK
#ifndef O_CLOEXEC
#define O_CLOEXEC  _O_NOINHERIT
#endif
#define O_NOCTTY   0
#define O_SYNC     0
#define O_DSYNC    0
#define O_NOFOLLOW 0
#define O_DIRECTORY 0x01000000
#define O_ASYNC    0

#define AT_FDCWD            (-100)
#define AT_SYMLINK_NOFOLLOW 0x100
#define AT_EACCESS          0x200
#define AT_REMOVEDIR        0x200
#define AT_SYMLINK_FOLLOW   0x400

#ifdef __cplusplus
extern "C" {
#endif
int sp_w32_faccessat(int dirfd, const char *path, int mode, int flags);
#define faccessat(d, p, m, f) sp_w32_faccessat((d), (p), (m), (f))
int fcntl(int fd, int cmd, ...);
int sp_w32_open(const char *path, int flags, ...);
#define open(...) sp_w32_open(__VA_ARGS__)
#ifdef __cplusplus
}
#endif
#endif
