/* Windows: the UCRT's <stdio.h> plus getline/getdelim and dprintf; popen/pclose speak POSIX (a wait status from
   pclose, /dev/null in the command, binary streams); fopen and freopen
   take /dev/null and UTF-8 paths. */
#ifndef SP_WIN32_STDIO_H
#define SP_WIN32_STDIO_H
#include_next <stdio.h>
#include <sys/types.h>
#include <stdarg.h>
#ifdef __cplusplus
extern "C" {
#endif
long long getdelim(char **line, size_t *cap, int delim, FILE *f);
long long getline(char **line, size_t *cap, FILE *f);
int dprintf(int fd, const char *fmt, ...);
int vdprintf(int fd, const char *fmt, va_list ap);
FILE *sp_w32_popen(const char *cmd, const char *mode);
int sp_w32_pclose(FILE *f);
FILE *sp_w32_fopen(const char *path, const char *mode);
FILE *sp_w32_freopen(const char *path, const char *mode, FILE *f);
FILE *sp_w32_fdopen(int fd, const char *mode);
int sp_w32_fclose(FILE *f);
/* setvbuf on a stream already read from: glibc keeps the bytes it has
   buffered, the UCRT drops them; the shim puts the descriptor back at the
   stream's position first, so nothing is lost */
int sp_w32_setvbuf(FILE *f, char *buf, int mode, size_t size);
/* fflush on a read stream: POSIX puts the descriptor at the stream's
   position and drops the buffer; the UCRT drops it and leaves the
   descriptor past it, losing what was read ahead */
int sp_w32_fflush(FILE *f);
#define fflush(f) sp_w32_fflush(f)
#define setvbuf(f, b, m, s) sp_w32_setvbuf((f), (b), (m), (s))
int sp_w32_remove(const char *path);
int sp_w32_rename(const char *from, const char *to);
/* POSIX's stream locks are the UCRT's under other names */
#define flockfile(f)        _lock_file(f)
#define funlockfile(f)      _unlock_file(f)
#define ftrylockfile(f)     (_lock_file(f), 0)
#define putc_unlocked(c, f) _putc_nolock((c), (f))
#define getc_unlocked(f)    _getc_nolock(f)
#define putchar_unlocked(c) _putc_nolock((c), stdout)
#define getchar_unlocked()  _getc_nolock(stdin)
#define fwrite_unlocked(b, s, n, f) _fwrite_nolock((b), (s), (n), (f))
#define fread_unlocked(b, s, n, f)  _fread_nolock((b), (s), (n), (f))
#undef popen
#undef pclose
#define popen(c, m)     sp_w32_popen((c), (m))
#define pclose(f)       sp_w32_pclose(f)
#define fopen(p, m)     sp_w32_fopen((p), (m))
#define freopen(p, m, f) sp_w32_freopen((p), (m), (f))
#define fdopen(fd, m)   sp_w32_fdopen((fd), (m))
/* a socket's stream: the SOCKET goes when the stream does (see sp_win32_net.c) */
#define fclose(f)       sp_w32_fclose(f)
#define remove(p)       sp_w32_remove(p)
#define rename(a, b)    sp_w32_rename((a), (b))
#ifdef __cplusplus
}
#endif
#endif
