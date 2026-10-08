/* Windows: no <sys/times.h>; times() reads GetProcessTimes, in clock ticks
   of sysconf(_SC_CLK_TCK) (100 a second, as on Linux). */
#ifndef SP_WIN32_SYS_TIMES_H
#define SP_WIN32_SYS_TIMES_H
#include <time.h>
struct tms { clock_t tms_utime, tms_stime, tms_cutime, tms_cstime; };
#ifdef __cplusplus
extern "C" {
#endif
clock_t times(struct tms *t);
#ifdef __cplusplus
}
#endif
#endif
