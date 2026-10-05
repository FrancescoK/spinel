/* Windows x64: MinGW's setjmp passes the frame address, so its longjmp
   unwinds through RtlUnwindEx -- every raise a full SEH unwind, and one
   that fails outright on a fiber stack (the unwinder checks the target
   against the thread's own stack bounds). The runtime longjmps the way
   glibc's does, restoring registers and nothing more, so take MinGW's
   non-SEH setjmp: _setjmp(buf, NULL), which longjmp honours without
   unwinding. */
#ifndef SP_WIN32_SETJMP_H
#define SP_WIN32_SETJMP_H
#ifndef __USE_MINGW_SETJMP_NON_SEH
#define __USE_MINGW_SETJMP_NON_SEH 1
#endif
#include_next <setjmp.h>
#endif
