/* Windows: posix_spawn over CreateProcess. The file actions the runtime
   uses -- dup2, close, open, and chdir (the _np one glibc and macOS spell
   the same) -- are carried out on the child's three standard handles and
   its working directory; POSIX_SPAWN_SETPGROUP starts it in a process group
   of its own (CREATE_NEW_PROCESS_GROUP). argv is quoted for the child's
   command line the way the MSVC runtime splits it, and a program spelled
   /bin/sh -c CMD runs CMD under %ComSpec%, the system's shell. The pid is
   the child's process id; waitpid and kill find its handle by it. An envp
   that is `environ` (or NULL) gives the child this process's environment. */
#ifndef SP_WIN32_SPAWN_H
#define SP_WIN32_SPAWN_H
#include <sys/types.h>
#include <signal.h>

typedef struct sp_w32_spawn_action sp_w32_spawn_action;
typedef struct {
  int n, cap;
  sp_w32_spawn_action *acts;
} posix_spawn_file_actions_t;
typedef struct {
  short flags;
  pid_t pgroup;
} posix_spawnattr_t;

#define POSIX_SPAWN_RESETIDS      0x01
#define POSIX_SPAWN_SETPGROUP     0x02
#define POSIX_SPAWN_SETSIGDEF     0x04
#define POSIX_SPAWN_SETSIGMASK    0x08
#define POSIX_SPAWN_SETSCHEDPARAM 0x10
#define POSIX_SPAWN_SETSCHEDULER  0x20
#define POSIX_SPAWN_SETSID        0x80

#ifdef __cplusplus
extern "C" {
#endif
int posix_spawn(pid_t *pid, const char *path, const posix_spawn_file_actions_t *fa,
                const posix_spawnattr_t *attr, char *const argv[], char *const envp[]);
int posix_spawnp(pid_t *pid, const char *file, const posix_spawn_file_actions_t *fa,
                 const posix_spawnattr_t *attr, char *const argv[], char *const envp[]);
int posix_spawn_file_actions_init(posix_spawn_file_actions_t *fa);
int posix_spawn_file_actions_destroy(posix_spawn_file_actions_t *fa);
int posix_spawn_file_actions_adddup2(posix_spawn_file_actions_t *fa, int fd, int newfd);
int posix_spawn_file_actions_addclose(posix_spawn_file_actions_t *fa, int fd);
int posix_spawn_file_actions_addopen(posix_spawn_file_actions_t *fa, int fd, const char *path, int oflag, mode_t mode);
int posix_spawn_file_actions_addchdir_np(posix_spawn_file_actions_t *fa, const char *path);
int posix_spawnattr_init(posix_spawnattr_t *a);
int posix_spawnattr_destroy(posix_spawnattr_t *a);
int posix_spawnattr_setflags(posix_spawnattr_t *a, short flags);
int posix_spawnattr_getflags(const posix_spawnattr_t *a, short *flags);
int posix_spawnattr_setpgroup(posix_spawnattr_t *a, pid_t pgroup);
int posix_spawnattr_setsigmask(posix_spawnattr_t *a, const sigset_t *m);
int posix_spawnattr_setsigdefault(posix_spawnattr_t *a, const sigset_t *m);
#ifdef __cplusplus
}
#endif
#endif
