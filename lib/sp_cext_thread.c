/* C extension serialization. Waiting for the lock is a blocking native
 * operation: a collector must not wait for a worker sleeping on this mutex. */
#ifdef SP_CEXT
#include "sp_cext.h"
#include "sp_sched.h"
#include <ruby/thread.h>
#include <stdlib.h>
#ifdef SP_THREADS
#include <pthread.h>
static pthread_once_t cxl_once = PTHREAD_ONCE_INIT;
static pthread_mutex_t cxl;
static SP_TLS unsigned cxl_depth;
static void cxl_init(void) {
    pthread_mutexattr_t attr;
    if (pthread_mutexattr_init(&attr) ||
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE) ||
        pthread_mutex_init(&cxl, &attr)) abort();
    pthread_mutexattr_destroy(&attr);
}
void sp_cext_lock(void) {
    pthread_once(&cxl_once, cxl_init);
    if (!cxl_depth) {
        sp_native_enter();
        int error = pthread_mutex_lock(&cxl);
        sp_native_leave();
        if (error) abort();
    }
    cxl_depth++;
}
void sp_cext_unlock(void) {
    if (!cxl_depth) abort();
    if (!--cxl_depth && pthread_mutex_unlock(&cxl)) abort();
}
unsigned sp_cext_lock_depth(void) { return cxl_depth; }
unsigned sp_cext_lock_suspend(void) {
    unsigned depth = cxl_depth;
    if (depth) {
        cxl_depth = 0;
        if (pthread_mutex_unlock(&cxl)) abort();
    }
    return depth;
}
void sp_cext_lock_resume(unsigned depth) {
    if (!depth) return;
    if (cxl_depth) abort();
    sp_cext_lock(); cxl_depth = depth;
}
#else
void sp_cext_lock(void) {}
void sp_cext_unlock(void) {}
unsigned sp_cext_lock_depth(void) { return 0; }
unsigned sp_cext_lock_suspend(void) { return 0; }
void sp_cext_lock_resume(unsigned depth) { (void)depth; }
#endif

void *rb_thread_call_without_gvl(void *(*function)(void *), void *data,
                                  rb_unblock_function_t *unblock, void *unblock_data) {
    void *result = NULL;
    unsigned depth = sp_cext_lock_suspend();
#ifdef SP_THREADS
    int run = sp_cext_native_register(unblock, unblock_data);
#else
    int run = 1;
    (void)unblock; (void)unblock_data;
#endif
    if (run) {
        sp_native_enter();
        result = function(data);
        sp_native_leave();
#ifdef SP_THREADS
        sp_cext_native_unregister();
#endif
    }
    sp_cext_lock_resume(depth);
    sp_fiber_fire_inject_if_pending();
    return result;
}
#endif
