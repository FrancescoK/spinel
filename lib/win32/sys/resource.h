/* Windows: no <sys/resource.h>. getrusage and the priorities read the
   process (GetProcessTimes, GetPriorityClass); the limits answer what
   Windows has -- the stack is the main thread's reserve, the rest
   RLIM_INFINITY -- and setting one is accepted and has no effect. */
#ifndef SP_WIN32_SYS_RESOURCE_H
#define SP_WIN32_SYS_RESOURCE_H
#include <sys/time.h>
#include "../sp_win32.h"

typedef unsigned long long rlim_t;
#define RLIM_INFINITY  (~(rlim_t)0)
#define RLIM_SAVED_MAX RLIM_INFINITY
#define RLIM_SAVED_CUR RLIM_INFINITY
struct rlimit { rlim_t rlim_cur; rlim_t rlim_max; };

#define RLIMIT_CPU     0
#define RLIMIT_FSIZE   1
#define RLIMIT_DATA    2
#define RLIMIT_STACK   3
#define RLIMIT_CORE    4
#define RLIMIT_RSS     5
#define RLIMIT_NPROC   6
#define RLIMIT_NOFILE  7
#define RLIMIT_MEMLOCK 8
#define RLIMIT_AS      9
#define RLIM_NLIMITS   10

#define RUSAGE_SELF     0
#define RUSAGE_CHILDREN (-1)
#define RUSAGE_THREAD   1
struct rusage {
  struct timeval ru_utime, ru_stime;
  long ru_maxrss, ru_ixrss, ru_idrss, ru_isrss, ru_minflt, ru_majflt, ru_nswap,
       ru_inblock, ru_oublock, ru_msgsnd, ru_msgrcv, ru_nsignals, ru_nvcsw, ru_nivcsw;
};

#define PRIO_PROCESS 0
#define PRIO_PGRP    1
#define PRIO_USER    2

#ifdef __cplusplus
extern "C" {
#endif
int getrlimit(int res, struct rlimit *rl);
int setrlimit(int res, const struct rlimit *rl);
int getrusage(int who, struct rusage *ru);
int getpriority(int which, id_t who);
int setpriority(int which, id_t who, int prio);
#ifdef __cplusplus
}
#endif
#endif
