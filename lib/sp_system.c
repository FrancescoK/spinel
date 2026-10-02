/* sp_system.c -- system()/backtick support in libspinel_rt.a.
 * See sp_system.h.
 *
 * Self-contained (libc + OS process API only); does not include
 * spinel_rt.h, so it carries its own sp_bool/TRUE/FALSE locally. */
#include "sp_system.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include <errno.h>
#include <unistd.h>
#include <sys/wait.h>
#if defined(_WIN32)
#include <spawn.h>
#endif

typedef int sp_bool;
#ifndef TRUE
#define TRUE 1
#endif
#ifndef FALSE
#define FALSE 0
#endif

int sp_last_status = 0;
int sp_last_pid = 0;


int sp_system_args(int argc, const char *const *argv) {
  if (argc <= 0 || argv == NULL || argv[0] == NULL) {
    sp_last_status = -1;
    return FALSE;
  }
  fflush(NULL);
#if defined(_WIN32)
  /* posix_spawn where there is no fork (see sp_process.c): a program that
     cannot be started leaves $? at the 127 its failed exec exits with */
  pid_t pid = 0;
  {
    int rc;
    if (argc == 1) {
      char *av[] = { (char *)"sh", (char *)"-c", (char *)argv[0], NULL };
      rc = posix_spawn(&pid, "/bin/sh", NULL, NULL, av, environ);
    }
    else rc = posix_spawnp(&pid, argv[0], NULL, NULL, (char *const *)argv, environ);
    if (rc != 0) { sp_last_status = 127 << 8; return FALSE; }
  }
#else
  pid_t pid = fork();
  if (pid < 0) {
    sp_last_status = -1;
    return FALSE;
  }
  if (pid == 0) {
    if (argc == 1) {
      execl("/bin/sh", "sh", "-c", argv[0], (char *)NULL);
    }
    else {
      execvp(argv[0], (char * const *)argv);
    }
    _exit(127);
  }
#endif
  /* Same rule as Process.waitpid2 (#4381): a blocking wait answers for the OS
     worker, and a started green thread is pinned to its worker, so it would
     stall the very thread that may have to drain this child's output before it
     can exit. sp_sched_wait_child polls and hands the scheduler back while any
     other thread is alive, and keeps the blocking wait when none is. */
  int status = 0;
  {
    extern int sp_sched_wait_child(int pid, int *status);
    if (sp_sched_wait_child((int)pid, &status) < 0) { sp_last_status = -1; return FALSE; }
  }
  sp_last_status = status;
  sp_last_pid = (int)pid;
  return (WIFEXITED(status) && WEXITSTATUS(status) == 0) ? TRUE : FALSE;
}
