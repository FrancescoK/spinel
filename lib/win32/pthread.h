/* Windows: winpthreads' <pthread.h> plus the glibc call the runtime uses
   to find a thread's stack, pthread_getattr_np (with pthread_attr_getstack
   reading what it found). */
#ifndef SP_WIN32_PTHREAD_H
#define SP_WIN32_PTHREAD_H
#include_next <pthread.h>
#include <signal.h>
/* winpthreads defines pthread_sigmask as a no-op macro; the shim's */
#undef pthread_sigmask
#define pthread_sigmask(h, s, o) sp_w32_pthread_sigmask((h), (s), (o))
#ifdef __cplusplus
extern "C" {
#endif
int pthread_getattr_np(pthread_t t, pthread_attr_t *a);
int sp_w32_pthread_attr_getstack(const pthread_attr_t *a, void **addr, size_t *size);
#define pthread_attr_getstack(a, p, s) sp_w32_pthread_attr_getstack((a), (p), (s))
#ifdef __cplusplus
}
#endif
#endif
