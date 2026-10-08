/* Windows: the UCRT's <string.h>, with strerror answering glibc's texts --
   the ones an Errno's message carries on Linux ("No such file or
   directory", "File name too long"); the UCRT words several differently
   and has none for the numbers lib/win32/errno.h adds. */
#ifndef SP_WIN32_STRING_H
#define SP_WIN32_STRING_H
#include_next <string.h>
#ifdef __cplusplus
extern "C" {
#endif
char *sp_w32_strerror(int e);
#define strerror(e) sp_w32_strerror(e)
/* MinGW-w64 before v14 (RubyInstaller's Devkit among them) has no strndup */
char *sp_w32_strndup(const char *s, size_t n);
#define strndup(s, n) sp_w32_strndup(s, n)
#ifdef __cplusplus
}
#endif
#endif
