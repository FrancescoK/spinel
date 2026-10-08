/* Windows: <ucontext.h> over the shim's own context switch
   (sp_win32_ctx.c), which the runtime's coroutines take there (see
   lib/sp_fiber_ctx.h). makecontext lays out a fresh stack for its entry
   function and swapcontext moves between contexts, saving what the
   Windows x64 ABI preserves across a call and the stack bounds the
   thread's TEB holds. getcontext prepares a context for makecontext; it
   does not capture the caller's state for a later setcontext, which
   nothing here asks of it. */
#ifndef SP_WIN32_UCONTEXT_H
#define SP_WIN32_UCONTEXT_H
#include <signal.h>
typedef struct sp_w32_ucontext {
  void *sp;                          /* the saved stack pointer: first, the switch's own frame */
  struct sp_w32_ucontext *uc_link;   /* not followed: an entry function here never returns */
  stack_t uc_stack;
} ucontext_t;
#ifdef __cplusplus
extern "C" {
#endif
int sp_w32_getcontext(ucontext_t *uc);
void sp_w32_makecontext(ucontext_t *uc, void (*fn)(void), int argc, ...);
int sp_w32_swapcontext(ucontext_t *from, const ucontext_t *to);
#define getcontext(u)        sp_w32_getcontext(u)
#define makecontext(u, f, ...) sp_w32_makecontext((u), (f), __VA_ARGS__)
#define swapcontext(f, t)    sp_w32_swapcontext((f), (t))
#ifdef __cplusplus
}
#endif
#endif
