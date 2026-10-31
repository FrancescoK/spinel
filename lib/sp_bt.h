#ifndef SP_BT_H
#define SP_BT_H
/* sp_bt.h -- the native backtrace a raise snapshots under spinel --debug,
 * shared by the generated TU (Kernel#caller, Exception#backtrace) and
 * lib/sp_exc.c (sp_raise_cls). The buffer and the switches are in
 * lib/sp_cold.c. */
#include <stdint.h>
#include <stdlib.h>
#include "sp_gc.h"
#include "sp_fiber.h"
#include "sp_sched.h"
#include "sp_array.h"   /* sp_StrArray */

/* Opt-in native backtrace (spinel --debug). In a -g, non-inlined build the
   sp_<method> symbols are present, so sp_raise_cls can snapshot the live C
   stack at raise time and Exception#backtrace / caller format it into a
   Ruby-style backtrace -- no per-method shadow frames needed. Off unless the
   generated main() sets sp_bt_enabled (debug builds), so non-debug behaviour
   and cost are unchanged. execinfo is not quite POSIX-ish; it's absent on
   Windows and other platforms. */
#if defined(__has_include)
#  if __has_include(<execinfo.h>)
#    define HAVE_EXECINFO_H 1
#  endif
#elif defined(__GLIBC__) || defined(__APPLE__) || defined(__FreeBSD__)
#  define HAVE_EXECINFO_H 1
#endif

#ifdef HAVE_EXECINFO_H
#include <execinfo.h>
#else
/* No execinfo.h: provide no-op shims so the formatting code below compiles
   and links unchanged. backtrace_symbols returns NULL, which the formatter
   treats as "nothing to format" -- the backtrace is simply empty. */
#define backtrace_symbols(buf, n) ((char **)0)
#define backtrace(buf, sz) 0
#endif
#define SP_BT_AVAILABLE 1
extern int sp_bt_enabled;          /* set to 1 by debug-build main(); defined in lib/sp_cold.c */
extern const char *sp_bt_srcfile;  /* toplevel .rb path, set by debug main() */
extern const char *const *sp_bt_files;  /* debug main(): C symbol, .rb file pairs of the methods of a required file, 0 ends */
#if SP_BT_AVAILABLE
extern void *sp_bt_buf[256];       /* frames captured at the last raise; lib/sp_cold.c */
extern int sp_bt_n;
#endif

/* The capture of a backtrace (at a raise, and for Kernel#caller). macOS 14's
   backtrace() on x86_64 answers no frame on a stack other than the
   pthread's own: the one the top level runs on (sp_main_stack_run), a
   fiber's, a green thread's (#9930). Where it answers almost none, the
   frame-pointer chain, which the Darwin ABI keeps on both architectures, is
   walked by hand, only within the stack the walk starts on, where every
   frame record is mapped (the unwinder, tried first, walked past the
   switched stack's first frame on arm64 and faulted). SPINEL_BT_WALK=1
   takes that walk wherever backtrace() works, so it can be checked there. */
#if defined(__APPLE__) && defined(HAVE_EXECINFO_H)
static SP_NOINLINE SP_UNUSED int sp_bt_capture(void **buf, int max) {
  static int forced = -1;
  if (forced < 0) { const char *e = getenv("SPINEL_BT_WALK"); forced = e && e[0] == '1'; }
  int n = forced ? 0 : backtrace(buf, max);
  if (n > 2) return n;
  char *fp = (char *)__builtin_frame_address(0), *lo = NULL, *hi = NULL;
  sp_Fiber *f = sp_fiber_current;
  if (f && f->stack && fp >= f->stack && fp < f->stack + sp_fiber_guard() + f->stack_size) {
    lo = f->stack + sp_fiber_guard(); hi = lo + f->stack_size;
  }
  else if (sp_thread_stack_lo && fp >= sp_thread_stack_lo && fp < sp_thread_stack_hi) {
    lo = sp_thread_stack_lo; hi = sp_thread_stack_hi;
  }
  if (!lo) return n;
  n = 0;
  while (n < max && fp >= lo && fp + 2 * sizeof(void *) <= hi && ((uintptr_t)fp & (sizeof(void *) - 1)) == 0) {
    void **rec = (void **)fp;
    if (!rec[1]) break;
    buf[n++] = rec[1];
    if ((char *)rec[0] <= fp) break;
    fp = (char *)rec[0];
  }
  return n;
}
#else
#define sp_bt_capture(buf, max) backtrace(buf, max)
#endif
sp_StrArray *sp_bt_format(void **buf, int n);
#endif
