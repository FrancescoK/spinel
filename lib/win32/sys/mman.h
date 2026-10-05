/* Windows: no <sys/mman.h>; mmap over VirtualAlloc and file mappings.
   An anonymous MAP_NORESERVE mapping is reserved address space whose pages
   are committed on first touch (a vectored exception handler in sp_win32.c
   commits the page and resumes), which is Linux's overcommit as the runtime
   relies on it: the 16 GB slab arena is never committed whole. */
#ifndef SP_WIN32_SYS_MMAN_H
#define SP_WIN32_SYS_MMAN_H
#include <sys/types.h>
#include <stddef.h>

#define PROT_NONE  0x0
#define PROT_READ  0x1
#define PROT_WRITE 0x2
#define PROT_EXEC  0x4

#define MAP_SHARED    0x01
#define MAP_PRIVATE   0x02
#define MAP_FIXED     0x10
#define MAP_ANONYMOUS 0x20
#define MAP_ANON      MAP_ANONYMOUS
#define MAP_NORESERVE 0x4000
#define MAP_STACK     0x20000
#define MAP_POPULATE  0x8000
#define MAP_FAILED    ((void *)-1)

#define MADV_NORMAL     0
#define MADV_RANDOM     1
#define MADV_SEQUENTIAL 2
#define MADV_WILLNEED   3
#define MADV_DONTNEED   4
#define MADV_FREE       8
#define MADV_HUGEPAGE   14
#define MADV_NOHUGEPAGE 15

#define MS_ASYNC      1
#define MS_INVALIDATE 2
#define MS_SYNC       4

#ifdef __cplusplus
extern "C" {
#endif
void *mmap(void *addr, size_t len, int prot, int flags, int fd, long long off);
int munmap(void *addr, size_t len);
int mprotect(void *addr, size_t len, int prot);
int madvise(void *addr, size_t len, int advice);
int msync(void *addr, size_t len, int flags);
int mlock(const void *addr, size_t len);
int munlock(const void *addr, size_t len);
#ifdef __cplusplus
}
#endif
#endif
