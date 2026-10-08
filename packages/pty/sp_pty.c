/* sp_pty.c -- PTY.spawn for the `pty` spin package (Path B carried C),
   linked on demand when `require "pty"` appears.

   A child on a pseudo-terminal: the master is opened here
   (posix_openpt/grantpt/unlockpt, the portable calls rather than glibc's
   openpty), and the child is made a session leader with the slave as its
   controlling terminal and as stdin, stdout and stderr, then exec'd. This
   is what CRuby's ext/pty does; the Ruby side (pty.rb) wraps the
   descriptors as IOs.

   THE CHILD DOES NOTHING THAT ALLOCATES. The parent may be a threaded
   program, and after fork only async-signal-safe calls are sound in the
   child: the argument vector and the environment are built here, in the
   parent, before the fork, and the child only assigns `environ`, moves
   descriptors and execs. Spinel's own Process.spawn (lib/sp_process.c)
   follows the same rule.

   THE CHILD STARTS WITH NO BLOCKED SIGNALS AND SIGPIPE AT ITS DEFAULT,
   whatever the forking thread had: a mask survives exec, and a shell on the
   terminal that inherited a blocked SIGINT would never see the ^C its line
   discipline sends. CRuby's children start this way too.

   Exec failure is reported through a close-on-exec pipe, as lib/sp_process.c
   does, so PTY.spawn raises Errno::ENOENT for a program that does not exist
   at the call, instead of returning the pid of a child that exits 127.

   Every symbol carries the full package prefix (see packages/zlib/sp_zlib.c
   for why the reserved-identifier list makes that matter). */
#ifndef _GNU_SOURCE
#define _GNU_SOURCE   /* posix_openpt, ptsname_r on glibc */
#endif
#include "spinel/runtime.h"
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

extern char **environ;

/* "Errno::ENOENT" and friends for the errnos a spawn meets; the parent
   otherwise, as lib/sp_process.c raises them. */
static const char *sp_pty_errno_class(int e) {
  switch (e) {
    case ENOENT: return "Errno::ENOENT";
    case EACCES: return "Errno::EACCES";
    case ENOEXEC: return "Errno::ENOEXEC";
    case EMFILE: return "Errno::EMFILE";
    case ENFILE: return "Errno::ENFILE";
    case EAGAIN: return "Errno::EAGAIN";
    case ENOMEM: return "Errno::ENOMEM";
    default: return "SystemCallError";
  }
}

/* CRuby's message: the strerror text, then " - " and what it was about. */
static SP_NORETURN void sp_pty_raise_errno(int e, const char *what) {
  char msg[512];
  if (what) snprintf(msg, sizeof msg, "%s - %s", strerror(e), what);
  else snprintf(msg, sizeof msg, "%s", strerror(e));
  sp_raise_cls(sp_pty_errno_class(e), msg);
}

static void sp_pty_cloexec(int fd) {
  int fl = fcntl(fd, F_GETFD);
  if (fl >= 0) fcntl(fd, F_SETFD, fl | FD_CLOEXEC);
}

/* A new master, close-on-exec, its slave unlocked. */
sp_int sp_pty_open_master(void) {
  int m = posix_openpt(O_RDWR | O_NOCTTY);
  if (m < 0) sp_pty_raise_errno(errno, "/dev/ptmx");
  if (grantpt(m) < 0 || unlockpt(m) < 0) {
    int e = errno;
    close(m);
    sp_pty_raise_errno(e, "/dev/ptmx");
  }
  sp_pty_cloexec(m);
  return (sp_int)m;
}

/* A second descriptor on the master for the writer CRuby hands back beside
   the reader, close-on-exec like the first. */
sp_int sp_pty_dup(sp_int fd) {
  int d = dup((int)fd);
  if (d < 0) sp_pty_raise_errno(errno, NULL);
  sp_pty_cloexec(d);
  return (sp_int)d;
}

/* The String a boxed value holds, or a TypeError naming what it was. */
static const char *sp_pty_str(sp_RbVal v, const char *what) {
  if (v.tag != SP_TAG_STR) {
    char msg[128];
    snprintf(msg, sizeof msg, "no implicit conversion into String (%s)", what);
    sp_raise_cls("TypeError", msg);
  }
  return v.v.s;
}

/* Does an `env` key name this `NAME=value` entry of environ? */
static int sp_pty_env_names(const char *entry, const char *name) {
  size_t n = strlen(name);
  return strncmp(entry, name, n) == 0 && entry[n] == '=';
}

/* Run `args` (an Array of Strings; one String with a shell character runs
   through /bin/sh -c, as Process.spawn reads it) on the slave of `master`,
   with `env` (a Hash of String => String or nil, or nil) laid over the
   current environment. Answers the child's pid. */
sp_int sp_pty_spawn_child(sp_int master, sp_RbVal env, sp_RbVal args) {
  if (args.tag != SP_TAG_OBJ || sp_json_kind_fn(args) != 1)
    sp_raise_cls("TypeError", "PTY.spawn takes the command as Strings");
  sp_int na = sp_json_len_fn(args);
  if (na < 1) sp_raise_cls("ArgumentError", "wrong number of arguments (given 0, expected 1+)");

  sp_int ne = 0;
  if (env.tag != SP_TAG_NIL) {
    if (env.tag != SP_TAG_OBJ || sp_json_kind_fn(env) != 2)
      sp_raise_cls("TypeError", "PTY.spawn takes the environment as a Hash");
    ne = sp_json_len_fn(env);
  }

  /* argv, in the parent */
  const char *first = sp_pty_str(sp_json_aref_fn(args, 0), "command");
  int via_shell = na == 1 && strpbrk(first, " \t\n*?{}[]<>()~&|\\$;'`\"#=%") != NULL;
  char **argv = malloc(sizeof(char *) * (size_t)(na + 3));
  if (!argv) sp_oom_die();
  int ai = 0;
  if (via_shell) { argv[ai++] = (char *)"/bin/sh"; argv[ai++] = (char *)"-c"; }
  for (sp_int i = 0; i < na; i++)
    argv[ai++] = (char *)sp_pty_str(sp_json_aref_fn(args, i), "command argument");
  argv[ai] = NULL;
  const char *prog = via_shell ? "/bin/sh" : first;

  /* envp: environ less every name `env` mentions, then the ones it sets */
  char **envp = NULL;
  char **owned = NULL;
  int nowned = 0;
  if (ne > 0) {
    sp_int nenv = 0;
    while (environ && environ[nenv]) nenv++;
    envp = malloc(sizeof(char *) * (size_t)(nenv + ne + 1));
    owned = malloc(sizeof(char *) * (size_t)(ne + 1));
    if (!envp || !owned) sp_oom_die();
    int ei = 0;
    for (sp_int i = 0; i < nenv; i++) {
      int shadowed = 0;
      for (sp_int k = 0; k < ne && !shadowed; k++) {
        sp_RbVal key, val;
        sp_json_hpair_fn(env, k, &key, &val);
        shadowed = sp_pty_env_names(environ[i], sp_pty_str(key, "environment name"));
      }
      if (!shadowed) envp[ei++] = environ[i];
    }
    for (sp_int k = 0; k < ne; k++) {
      sp_RbVal key, val;
      sp_json_hpair_fn(env, k, &key, &val);
      if (val.tag == SP_TAG_NIL) continue;
      const char *name = sp_pty_str(key, "environment name");
      const char *value = sp_pty_str(val, "environment value");
      size_t len = strlen(name) + strlen(value) + 2;
      char *entry = malloc(len);
      if (!entry) sp_oom_die();
      snprintf(entry, len, "%s=%s", name, value);
      owned[nowned++] = entry;
      envp[ei++] = entry;
    }
    envp[ei] = NULL;
  }

  char slave[256];
#ifdef __linux__
  if (ptsname_r((int)master, slave, sizeof slave) != 0) {
#else
  const char *pn = ptsname((int)master);
  if (pn) { strncpy(slave, pn, sizeof slave - 1); slave[sizeof slave - 1] = 0; }
  if (!pn) {
#endif
    int e = errno;
    free(argv); free(envp);
    for (int i = 0; i < nowned; i++) free(owned[i]);
    free(owned);
    sp_pty_raise_errno(e, "ptsname");
  }

  int err_pipe[2];
  if (pipe(err_pipe) < 0) {
    int e = errno;
    free(argv); free(envp);
    for (int i = 0; i < nowned; i++) free(owned[i]);
    free(owned);
    sp_pty_raise_errno(e, "pipe");
  }
  sp_pty_cloexec(err_pipe[1]);

  /* what the parent has buffered is written before the child can write to
     the same descriptors, as lib/sp_process.c and CRuby flush */
  fflush(NULL);
  pid_t pid = fork();
  if (pid == 0) {
    /* CHILD: async-signal-safe calls only, until exec */
    sigset_t none;
    sigemptyset(&none);
    sigprocmask(SIG_SETMASK, &none, NULL);
    signal(SIGPIPE, SIG_DFL);
    close(err_pipe[0]);
    setsid();
    int s = open(slave, O_RDWR);
    if (s < 0) {
      int fail = errno;
      (void)!write(err_pipe[1], &fail, sizeof fail);
      _exit(127);
    }
#ifdef TIOCSCTTY
    ioctl(s, TIOCSCTTY, 0);
#endif
    dup2(s, 0);
    dup2(s, 1);
    dup2(s, 2);
    if (s > 2) close(s);
    close((int)master);
    if (envp) environ = envp;
    execvp(prog, argv);
    int fail = errno;
    (void)!write(err_pipe[1], &fail, sizeof fail);
    _exit(127);
  }
  int fork_errno = errno;
  close(err_pipe[1]);
  free(argv);
  free(envp);
  for (int i = 0; i < nowned; i++) free(owned[i]);
  free(owned);
  if (pid < 0) {
    close(err_pipe[0]);
    sp_pty_raise_errno(fork_errno, "fork");
  }

  int fail = 0;
  ssize_t got;
  do { got = read(err_pipe[0], &fail, sizeof fail); } while (got < 0 && errno == EINTR);
  close(err_pipe[0]);
  if (got > 0) {
    /* the child could not exec: reap it before the raise, as CRuby does,
       and give the master back, since no IO was made for it */
    int st = 0;
    pid_t r;
    do { r = waitpid(pid, &st, 0); } while (r < 0 && errno == EINTR);
    close((int)master);
    sp_pty_raise_errno(fail, first);
  }
  return (sp_int)pid;
}
