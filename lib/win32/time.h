/* Windows: the UCRT's <time.h> with the POSIX thread-safe calls switched on
   (localtime_r, gmtime_r), timegm, and a strftime with glibc's directives
   in the C locale. The UCRT's own strftime answers the Windows zone name
   for %Z, knows neither %P, %k, %l, %s nor the GNU flags, and treats an
   unknown directive as a fatal invalid-parameter error. */
#ifndef SP_WIN32_TIME_H
#define SP_WIN32_TIME_H
#ifndef _POSIX_THREAD_SAFE_FUNCTIONS
#define _POSIX_THREAD_SAFE_FUNCTIONS 200112L
#endif
#include_next <time.h>
#include <stddef.h>
#ifdef __cplusplus
extern "C" {
#endif
size_t sp_w32_strftime(char *buf, size_t cap, const char *fmt, const struct tm *tm);
#define strftime(b, c, f, t) sp_w32_strftime((b), (c), (f), (t))
/* The UCRT's conversions stop at 1970 and 3000 (and gmtime answers NULL
   for a negative time_t); Ruby's Time has no such edge. These take any
   year, the UCRT's own zone rules inside its range and the zone's standard
   offset outside it. */
struct tm *sp_w32_gmtime_r(const time_t *t, struct tm *out);
struct tm *sp_w32_localtime_r(const time_t *t, struct tm *out);
struct tm *sp_w32_gmtime(const time_t *t);
struct tm *sp_w32_localtime(const time_t *t);
time_t sp_w32_mktime(struct tm *tm);
time_t sp_w32_timegm(struct tm *tm);
#undef gmtime_r
#undef localtime_r
#define gmtime_r(t, o)    sp_w32_gmtime_r((t), (o))
#define localtime_r(t, o) sp_w32_localtime_r((t), (o))
#define gmtime(t)         sp_w32_gmtime(t)
#define localtime(t)      sp_w32_localtime(t)
#define mktime(t)         sp_w32_mktime(t)
#define timegm(t)         sp_w32_timegm(t)
/* tzset as POSIX's: the UCRT's _tzset reads a TZ string's zone and offset
   but keeps the DST bias of the zone it read before -- the system's, 0
   where that has no DST -- so "EST5EDT" ran EDT at EST's hour. */
void sp_w32_tzset(void);
#undef tzset
#define tzset() sp_w32_tzset()
/* nanosleep that a signal cuts short with EINTR, as POSIX's is */
int sp_w32_nanosleep(const struct timespec *req, struct timespec *rem);
#undef nanosleep
#define nanosleep(r, m)   sp_w32_nanosleep((r), (m))
#ifdef __cplusplus
}
#endif
#endif
