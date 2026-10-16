#ifndef SPINEL_RUBY_THREAD_H
#define SPINEL_RUBY_THREAD_H
#include <ruby.h>
#include <sys/time.h>
typedef struct { unsigned char *bits; size_t capacity; } rb_fdset_t;
void rb_fd_init(rb_fdset_t *);
void rb_fd_term(rb_fdset_t *);
void rb_fd_set(int, rb_fdset_t *);
int rb_fd_isset(int, const rb_fdset_t *);
int rb_thread_fd_select(int, rb_fdset_t *, rb_fdset_t *, rb_fdset_t *, struct timeval *);
typedef void rb_unblock_function_t(void *);
#define RUBY_UBF_IO ((rb_unblock_function_t *)(intptr_t)-1)
void *rb_thread_call_without_gvl(void *(*)(void *), void *, rb_unblock_function_t *, void *);
#endif
