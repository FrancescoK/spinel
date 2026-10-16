#include "sp_cext.h"
#include <pthread.h>
#include <assert.h>
#include <ruby.h>
#include <stdlib.h>
/* This unit tests CXL without booting the scheduler. Scheduler/GC integration
 * is exercised separately by compiled Ruby extension tests. */
void sp_native_enter(void) {}
void sp_native_leave(void) {}
int sp_cext_native_register(void (*f)(void *), void *p, int repeat) { (void)f; (void)p; (void)repeat; return 1; }
/* I/O and Ruby error paths belong to the integration fixture. */
VALUE rb_eArgError, rb_eNoMemError, rb_eRuntimeError;
void rb_raise(VALUE klass, const char *format, ...) { (void)klass; (void)format; abort(); }
void *sp_cext_allocv(VALUE *handle, size_t size, size_t count) {
    (void)handle; (void)size; (void)count; abort();
}
void sp_cext_native_unregister(void) {}
void sp_fiber_fire_inject_if_pending(void) {}
static int total;
static void *run(void *unused) {
    (void)unused;
    for (int i = 0; i < 10000; i++) {
        sp_cext_lock(); sp_cext_lock();
        assert(sp_cext_lock_depth() == 2);
        total++;
        unsigned depth = sp_cext_lock_suspend();
        assert(depth == 2 && sp_cext_lock_depth() == 0);
        sp_cext_lock_resume(depth);
        assert(sp_cext_lock_depth() == 2);
        sp_cext_unlock(); sp_cext_unlock();
    }
    return NULL;
}
int main(void) {
    pthread_t workers[4];
    for (int i = 0; i < 4; i++) assert(!pthread_create(&workers[i], NULL, run, NULL));
    for (int i = 0; i < 4; i++) assert(!pthread_join(workers[i], NULL));
    assert(total == 40000);
    assert(sp_cext_lock_depth() == 0);
}
