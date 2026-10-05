/* Windows: the UCRT's <sys/time.h> plus utimes. */
#ifndef SP_WIN32_SYS_TIME_H
#define SP_WIN32_SYS_TIME_H
#include_next <sys/time.h>
#ifdef __cplusplus
extern "C" {
#endif
int sp_w32_utimes(const char *path, const struct timeval tv[2]);
#define utimes(p, tv) sp_w32_utimes((p), (tv))
#ifdef __cplusplus
}
#endif
#endif
