/* Windows: MinGW's <unistd.h> plus the POSIX calls it leaves out or gets
   wrong for the runtime: fork/exec (answer ENOSYS -- the runtime spawns
   through posix_spawn, see spawn.h), the user and process-group ids, links,
   sysconf, and fd I/O that must also reach sockets (see sp_win32.h). */
#ifndef SP_WIN32_UNISTD_H
#define SP_WIN32_UNISTD_H
#include_next <unistd.h>
#include <io.h>
#include <process.h>
#include <direct.h>
#include "sp_win32.h"

#ifdef __cplusplus
extern "C" {
#endif

/* processes: no fork on Windows */
pid_t sp_w32_fork(void);
#define fork() sp_w32_fork()
/* the CRT has _exec*, which it declares under these names too; the shim's
   wait for the program and exit with its status (sp_win32.c) */
int sp_w32_execvp(const char *file, char *const argv[]);
int sp_w32_execv(const char *path, char *const argv[]);
int sp_w32_execve(const char *path, char *const argv[], char *const envp[]);
int sp_w32_execl(const char *path, const char *arg, ...);
#define execvp(f, a)    sp_w32_execvp((f), (a))
#define execv(p, a)     sp_w32_execv((p), (a))
#define execve(p, a, e) sp_w32_execve((p), (a), (e))
#define execl(...)      sp_w32_execl(__VA_ARGS__)
pid_t getppid(void);
pid_t getpgrp(void);
pid_t getpgid(pid_t pid);
int setpgid(pid_t pid, pid_t pgid);
pid_t setsid(void);
pid_t getsid(pid_t pid);
uid_t getuid(void);
uid_t geteuid(void);
gid_t getgid(void);
gid_t getegid(void);
int getgroups(int n, gid_t *list);
int fchdir(int fd);
int chown(const char *path, uid_t uid, gid_t gid);
int lchown(const char *path, uid_t uid, gid_t gid);
int fchown(int fd, uid_t uid, gid_t gid);
unsigned int alarm(unsigned int seconds);
int pause(void);
int fsync(int fd);
int fdatasync(int fd);
long long pread(int fd, void *buf, size_t n, long long off);
long long pwrite(int fd, const void *buf, size_t n, long long off);
char *getlogin(void);
char *ttyname(int fd);
int sp_w32_gethostname(char *name, size_t len);
#define gethostname(n, l) sp_w32_gethostname((n), (l))
char *sp_w32_getcwd(char *buf, size_t n);
#define getcwd(b, n) sp_w32_getcwd((b), (n))

/* sysconf names: the ones the runtime asks */
#define _SC_PAGESIZE          30
#define _SC_PAGE_SIZE         _SC_PAGESIZE
#define _SC_NPROCESSORS_CONF  83
#define _SC_NPROCESSORS_ONLN  84
#define _SC_CLK_TCK           2
#define _SC_OPEN_MAX          4
#define _SC_PHYS_PAGES        85
#define _SC_ARG_MAX           0
long sysconf(int name);
int getpagesize(void);

/* fd I/O: a socket fd goes to winsock, the rest to the CRT */
#define read(fd, buf, n)   sp_w32_read((fd), (buf), (n))
#define write(fd, buf, n)  sp_w32_write((fd), (buf), (n))
#define close(fd)          sp_w32_close(fd)
#define dup(fd)            sp_w32_dup(fd)
#define dup2(fd, fd2)      sp_w32_dup2((fd), (fd2))
#define pipe(fds)          sp_w32_pipe(fds)
#define isatty(fd)         sp_w32_isatty(fd)

/* paths: UTF-8 in, and the POSIX spellings of /dev/null and links */
#define readlink(p, b, n)  sp_w32_readlink((p), (b), (n))
#define symlink(t, p)      sp_w32_symlink((t), (p))
#define link(t, p)         sp_w32_link((t), (p))
#define unlink(p)          sp_w32_unlink(p)
#define access(p, m)       sp_w32_access((p), (m))
#define chdir(p)           sp_w32_chdir(p)
int sp_w32_rmdir(const char *path);
int sp_w32_truncate(const char *path, long long len);
#define rmdir(p)           sp_w32_rmdir(p)
#undef truncate
#define truncate(p, n)     sp_w32_truncate((p), (n))

#ifndef F_OK
#define F_OK 0
#endif
#ifndef X_OK
#define X_OK 1
#endif
#ifndef W_OK
#define W_OK 2
#endif
#ifndef R_OK
#define R_OK 4
#endif

#ifdef __cplusplus
}
#endif
#endif
