/* Windows: no <sys/wait.h>. A child is a process handle the shim keeps by
   pid (see spawn.h); waitpid waits on it, and the status it answers is laid
   out as a POSIX wait status -- the exit code in the second byte, or the
   signal kill(2) sent in the low bits -- so WIFEXITED and the rest read it
   as they do everywhere. */
#ifndef SP_WIN32_SYS_WAIT_H
#define SP_WIN32_SYS_WAIT_H
#include <sys/types.h>
#include "../sp_win32.h"

#define WNOHANG    1
#define WUNTRACED  2
#define WCONTINUED 8

#define WEXITSTATUS(s) (((s) & 0xff00) >> 8)
#define WTERMSIG(s)    ((s) & 0x7f)
#define WSTOPSIG(s)    WEXITSTATUS(s)
#define WIFEXITED(s)   (WTERMSIG(s) == 0)
#define WIFSIGNALED(s) (((signed char)(((s) & 0x7f) + 1) >> 1) > 0)
#define WIFSTOPPED(s)  (((s) & 0xff) == 0x7f)
#define WIFCONTINUED(s) ((s) == 0xffff)
#define WCOREDUMP(s)   ((s) & 0x80)

#ifdef __cplusplus
extern "C" {
#endif
pid_t waitpid(pid_t pid, int *status, int options);
pid_t wait(int *status);
#ifdef __cplusplus
}
#endif
#endif
