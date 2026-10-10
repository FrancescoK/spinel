/* spinel-timeout: a minimal timeout wrapper.
 *
 * GNU coreutils' `timeout` returns 124 when the command runs past the
 * duration. Busybox's applet and other implementations return different
 * values (143 = 128+SIGTERM, or 399 on some BSDs). The Makefile's bench
 * target keys on 124 to mark a benchmark as SKIP, so it needs a uniform
 * exit code regardless of which `timeout` is on PATH.
 *
 * Usage: spinel-timeout SECONDS COMMAND [ARG...]
 *
 * SECONDS limits the command's CPU time, not the time that passes on the
 * clock. A limit on the clock fails a correct program on a loaded machine:
 * a test that needs 8 s of CPU took 63 s on the clock beside a dozen
 * compiles and was killed at 60 s with its output right so far. A program
 * waiting for the machine is not a runaway; one that burns SECONDS of CPU is.
 * The child sets RLIMIT_CPU on itself before it execs, so the kernel ends a
 * spinner with SIGXCPU. The limit counts the command's own process with all
 * its threads together (N threads running flat out use N CPU seconds per
 * second), and not the processes it starts: each of those inherits the same
 * limit for itself, and the backstop below covers the sum.
 *
 * A command that does not use the CPU (blocked, sleeping, or waiting for a
 * child that hangs) is ended by a backstop on the clock, WALL_FACTOR times
 * SECONDS. Past it the wrapper sends SIGTERM and then, after a grace period,
 * SIGKILL. Either limit makes the wrapper return 124 and name the limit on
 * stderr; otherwise it returns the child's exit status.
 *
 * No dependencies beyond POSIX.1-2001 (fork, exec, kill, sigaction, alarm,
 * waitpid, setrlimit, getrusage). */

#include <signal.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <errno.h>
#include <string.h>
#include <stdio.h>
#include <time.h>

/* How many times SECONDS the clock backstop allows. The CPU limit is what
   ends a real runaway; this one only has to end a program that is stuck, and
   must be far enough out that a slow machine never reaches it first. */
#define WALL_FACTOR 6

static volatile sig_atomic_t timed_out;

static void on_alarm(int sig) {
  (void)sig;
  timed_out = 1;
}

/* Limit this process's CPU time to `secs`. The soft limit raises SIGXCPU,
   which ends the process; the hard limit, a little later, is SIGKILL for a
   program that ignores the signal. An existing limit that is already lower
   stays, since an unprivileged process cannot raise its hard limit. A failure
   leaves the child without a CPU limit, and the backstop still applies. */
static void limit_cpu(long secs) {
  struct rlimit rl;
  if (getrlimit(RLIMIT_CPU, &rl) != 0) return;
  rlim_t soft = (rlim_t)secs, hard = (rlim_t)secs + 2;
  if (rl.rlim_cur != RLIM_INFINITY && rl.rlim_cur < soft) soft = rl.rlim_cur;
  if (rl.rlim_max != RLIM_INFINITY && rl.rlim_max < hard) hard = rl.rlim_max;
  if (soft > hard) soft = hard;
  rl.rlim_cur = soft;
  rl.rlim_max = hard;
  setrlimit(RLIMIT_CPU, &rl);
}

/* CPU seconds the reaped child (and the children it waited for) used. */
static double child_cpu_seconds(void) {
  struct rusage ru;
  if (getrusage(RUSAGE_CHILDREN, &ru) != 0) return 0;
  return (double)ru.ru_utime.tv_sec + ru.ru_utime.tv_usec / 1e6 +
         (double)ru.ru_stime.tv_sec + ru.ru_stime.tv_usec / 1e6;
}

int main(int argc, char **argv) {
  if (argc < 3) {
    fputs("usage: spinel-timeout SECONDS COMMAND [ARG...]\n", stderr);
    return 2;
  }
  long secs = atol(argv[1]);
  if (secs <= 0) secs = 1;
  if (secs > 100000) secs = 100000;   /* keeps SECONDS * WALL_FACTOR in an unsigned */

  pid_t pid = fork();
  if (pid < 0) { perror("fork"); return 1; }
  if (pid == 0) {
    /* child: the alarm is armed in the PARENT after this fork, so there is
       nothing pending here; put SIGALRM back to its default in case the
       command inherits an expectation about it. */
    struct sigaction dfl = {0};
    dfl.sa_handler = SIG_DFL;
    sigaction(SIGALRM, &dfl, NULL);
    limit_cpu(secs);
    execvp(argv[2], argv + 2);
    perror("execvp");
    _exit(127);
  }

  /* Arm AFTER the fork: armed before it, an alarm that fired in the window
     between alarm() and fork() would set timed_out with no child to blame. */
  struct sigaction sa = {0};
  sa.sa_handler = on_alarm;   /* no SA_RESTART: the wait below must be cut short */
  sigaction(SIGALRM, &sa, NULL);
  alarm((unsigned)(secs * WALL_FACTOR));

  /* The alarm has to END the wait, not just interrupt it. Retrying waitpid on
     every EINTR -- which is what a plain `while (waitpid(...) < 0 && errno ==
     EINTR)` does -- goes straight back to waiting, so the child runs to
     completion and the wrapper reports 124 having enforced nothing: a 15s
     sleep under a 2s limit took 15s and then said it had timed out. `reaped`
     is what tells the two apart, rather than timed_out, so a child that exits
     in the same instant the alarm fires still reports its own status. */
  int status = 0, reaped = 0;
  for (;;) {
    pid_t r = waitpid(pid, &status, 0);
    if (r == pid) { reaped = 1; break; }
    if (r < 0 && errno == EINTR) { if (timed_out) break; continue; }
    break;   /* ECHILD or another error: nothing left to wait for */
  }
  alarm(0);

  if (!reaped) {
    /* give the child a moment to exit on SIGTERM, then force it */
    kill(pid, SIGTERM);
    struct timespec grace = {0, 100 * 1000 * 1000};  /* 100ms */
    nanosleep(&grace, NULL);
    kill(pid, SIGKILL);
    while (waitpid(pid, &status, 0) < 0 && errno == EINTR) {}
    fprintf(stderr, "spinel-timeout: the clock limit of %ld s (%d x the %ld s CPU limit) passed after %.1f s of CPU: killed\n",
            secs * WALL_FACTOR, WALL_FACTOR, secs, child_cpu_seconds());
    return 124;
  }

  if (WIFEXITED(status)) return WEXITSTATUS(status);
  if (WIFSIGNALED(status)) {
    /* SIGXCPU is the soft limit; SIGKILL is the hard one for a program that
       ignored it, which the CPU the child used tells from any other kill. */
    int sig = WTERMSIG(status);
    double cpu = child_cpu_seconds();
    if (sig == SIGXCPU || (sig == SIGKILL && cpu >= (double)secs)) {
      fprintf(stderr, "spinel-timeout: the CPU limit of %ld s passed (%.1f s of CPU used): killed\n", secs, cpu);
      return 124;
    }
    return 128 + sig;
  }
  return 1;
}
