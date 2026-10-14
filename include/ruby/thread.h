#ifndef SPINEL_RUBY_THREAD_H
#define SPINEL_RUBY_THREAD_H
#include <ruby.h>
typedef void rb_unblock_function_t(void *);
void *rb_thread_call_without_gvl(void *(*)(void *), void *, rb_unblock_function_t *, void *);
#endif
