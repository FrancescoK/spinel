/* Windows: the UCRT's <stdlib.h> plus realpath, setenv/unsetenv,
   mkdtemp/mkstemp and getentropy; system runs its command line the POSIX
   way (see sp_w32_system). */
#ifndef SP_WIN32_STDLIB_H
#define SP_WIN32_STDLIB_H
#include_next <stdlib.h>
#include "sp_win32.h"
#ifdef __cplusplus
extern "C" {
#endif
#define realpath(p, r) sp_w32_realpath((p), (r))
int setenv(const char *name, const char *value, int overwrite);
int unsetenv(const char *name);
char *mkdtemp(char *tmpl);
int sp_w32_mkstemp(char *tmpl);
#define mkstemp(t) sp_w32_mkstemp(t)
int getentropy(void *buf, size_t n);
/* `environ` over a function of the shim's, so POSIX code's own
   `extern char **environ;` declares something compatible (the UCRT's is a
   macro over a dllimport'd function, which that declaration contradicts) */
char ***sp_w32_environ(void);
#undef environ
#define environ (*sp_w32_environ())
#define system(c) sp_w32_system(c)
#ifdef __cplusplus
}
#endif
#endif
