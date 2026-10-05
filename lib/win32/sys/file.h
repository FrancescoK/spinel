/* Windows: flock(2) over LockFileEx on the fd's handle. */
#ifndef SP_WIN32_SYS_FILE_H
#define SP_WIN32_SYS_FILE_H
#include_next <sys/file.h>
#define LOCK_SH 1
#define LOCK_EX 2
#define LOCK_NB 4
#define LOCK_UN 8
#ifdef __cplusplus
extern "C" {
#endif
int flock(int fd, int op);
#ifdef __cplusplus
}
#endif
#endif
