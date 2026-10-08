/* Windows: a POSIX struct stat. The UCRT's has no st_mtim / st_atim /
   st_ctim (nanoseconds), st_blksize, st_blocks, or a file identity in
   st_dev / st_ino, all of which the runtime reads, so this header defines
   its own and renames the tag and the calls onto it: `stat` is a struct tag
   and a function, two namespaces, and one object-like macro moves both.
   sp_win32.c fills it from the file's handle (GetFileInformationByHandle),
   with st_dev the volume serial and st_ino the file index.

   Also: mkdir's mode argument, lstat that sees a symlink as one, the link
   and socket file types, fchmod and mkfifo. Paths are UTF-8 and /dev/null
   means NUL, as everywhere in the shim. */
#ifndef SP_WIN32_SYS_STAT_H
#define SP_WIN32_SYS_STAT_H
/* everything that declares the UCRT's stat structs, before the renames */
#include <wchar.h>
#include_next <sys/stat.h>
#include <io.h>
#include <direct.h>
#include <time.h>
#include "../sp_win32.h"

#ifndef S_IFLNK
#define S_IFLNK  0xA000
#endif
#ifndef S_IFSOCK
#define S_IFSOCK 0xC000
#endif
#ifndef S_ISLNK
#define S_ISLNK(m)  (((m) & S_IFMT) == S_IFLNK)
#endif
#ifndef S_ISSOCK
#define S_ISSOCK(m) (((m) & S_IFMT) == S_IFSOCK)
#endif
#ifndef S_ISFIFO
#define S_ISFIFO(m) (((m) & S_IFMT) == _S_IFIFO)
#endif
#ifndef S_ISCHR
#define S_ISCHR(m)  (((m) & S_IFMT) == S_IFCHR)
#endif
#ifndef S_ISBLK
#define S_ISBLK(m)  0
#endif
#ifndef S_IRWXU
#define S_IRWXU 0700
#define S_IRUSR 0400
#define S_IWUSR 0200
#define S_IXUSR 0100
#endif
#ifndef S_IRWXG
#define S_IRWXG 0070
#define S_IRGRP 0040
#define S_IWGRP 0020
#define S_IXGRP 0010
#define S_IRWXO 0007
#define S_IROTH 0004
#define S_IWOTH 0002
#define S_IXOTH 0001
#endif
#ifndef S_ISUID
#define S_ISUID 04000
#define S_ISGID 02000
#define S_ISVTX 01000
#endif

struct sp_w32_stat {
  unsigned long long st_dev;
  unsigned long long st_ino;
  unsigned int st_mode;
  unsigned int st_nlink;
  unsigned int st_uid;
  unsigned int st_gid;
  unsigned long long st_rdev;
  long long st_size;
  long long st_blksize;
  long long st_blocks;
  struct timespec st_atim;
  struct timespec st_mtim;
  struct timespec st_ctim;
  struct timespec st_birthtim;
};

#ifdef __cplusplus
extern "C" {
#endif
int sp_w32_stat(const char *path, struct sp_w32_stat *st);
int sp_w32_lstat(const char *path, struct sp_w32_stat *st);
int sp_w32_fstat(int fd, struct sp_w32_stat *st);
int sp_w32_chmod(const char *path, int mode);
int fchmod(int fd, mode_t mode);
int mkfifo(const char *path, mode_t mode);
#define UTIME_NOW  ((1l << 30) - 1l)
#define UTIME_OMIT ((1l << 30) - 2l)
int sp_w32_utimensat(int dirfd, const char *path, const struct timespec ts[2], int flags);
#define utimensat(d, p, t, f) sp_w32_utimensat((d), (p), (t), (f))
#ifdef __cplusplus
}
#endif

/* an older MinGW-w64 (v11, the cross toolchains Debian and Ubuntu ship)
   spells these as macros of its own under _FILE_OFFSET_BITS=64 */
#undef stat
#undef fstat
#define stat  sp_w32_stat
#define lstat sp_w32_lstat
#define fstat sp_w32_fstat
#undef st_atime
#undef st_mtime
#undef st_ctime
#define st_atime st_atim.tv_sec
#define st_mtime st_mtim.tv_sec
#define st_ctime st_ctim.tv_sec
#define mkdir(p, m)  sp_w32_mkdir((p), (m))
#define chmod(p, m)  sp_w32_chmod((p), (m))
#endif
