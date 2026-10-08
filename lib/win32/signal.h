/* Windows: the UCRT's <signal.h> (SIGINT, SIGILL, SIGFPE, SIGSEGV, SIGTERM,
   SIGBREAK, SIGABRT) plus the POSIX rest. The extra names are numbered as
   on Linux where the number is free, above NSIG otherwise; the CRT never
   raises them, so a handler for one is recorded and never runs, and
   sigaction on it answers 0 the way installing a handler for a signal that
   never comes does. kill(2) on a child terminates it, recording the signal
   for waitpid; kill on this process raises the signal here. */
#ifndef SP_WIN32_SIGNAL_H
#define SP_WIN32_SIGNAL_H
#include_next <signal.h>
#include <sys/types.h>
#include "sp_win32.h"

#define SIGHUP    1
#define SIGQUIT   3
#define SIGTRAP   5
#define SIGBUS    7
#define SIGKILL   9
#define SIGUSR1   10
#define SIGUSR2   12
#define SIGPIPE   13
#define SIGALRM   14
#define SIGSTKFLT 16
#define SIGCHLD   17
#define SIGCLD    SIGCHLD
#define SIGCONT   18
#define SIGSTOP   19
#define SIGTSTP   20
#define SIGTTIN   24
#define SIGTTOU   25
#define SIGURG    26
#define SIGXCPU   27
#define SIGXFSZ   28
#define SIGVTALRM 29
#define SIGPROF   30
#define SIGWINCH  31
#define SIGIO     32
#define SIGPOLL   SIGIO
#define SIGPWR    33
#define SIGSYS    34
#define SP_W32_NSIG 35

#define SA_NOCLDSTOP 0x00000001
#define SA_NOCLDWAIT 0x00000002
#define SA_SIGINFO   0x00000004
#define SA_ONSTACK   0x08000000
#define SA_RESTART   0x10000000
#define SA_NODEFER   0x40000000
#define SA_RESETHAND 0x80000000

#define SIG_BLOCK   0
#define SIG_UNBLOCK 1
#define SIG_SETMASK 2

#define SS_ONSTACK 1
#define SS_DISABLE 2
#define MINSIGSTKSZ 2048
#define SIGSTKSZ    8192

typedef struct {
  int si_signo, si_errno, si_code;
  pid_t si_pid;
  void *si_addr;
  int si_status;
} siginfo_t;

struct sigaction {
  union {
    void (*sa_handler)(int);
    void (*sa_sigaction)(int, siginfo_t *, void *);
  } __sa_handler;
  sigset_t sa_mask;
  int sa_flags;
};
#define sa_handler   __sa_handler.sa_handler
#define sa_sigaction __sa_handler.sa_sigaction

typedef struct sigaltstack { void *ss_sp; int ss_flags; size_t ss_size; } stack_t;

#ifdef __cplusplus
extern "C" {
#endif
int sigaction(int sig, const struct sigaction *act, struct sigaction *old);
int sigaltstack(const stack_t *ss, stack_t *old);
int sigemptyset(sigset_t *s);
int sigfillset(sigset_t *s);
int sigaddset(sigset_t *s, int sig);
int sigdelset(sigset_t *s, int sig);
int sigismember(const sigset_t *s, int sig);
int sigprocmask(int how, const sigset_t *s, sigset_t *old);
int sigpending(sigset_t *s);
int sigsuspend(const sigset_t *s);
int sp_w32_pthread_sigmask(int how, const sigset_t *s, sigset_t *old);
#undef pthread_sigmask
#define pthread_sigmask(h, s, o) sp_w32_pthread_sigmask((h), (s), (o))
int kill(pid_t pid, int sig);
int killpg(pid_t pgrp, int sig);
const char *sp_w32_strsignal(int sig);
#define strsignal(s) sp_w32_strsignal(s)
#ifdef __cplusplus
}
#endif
#endif
