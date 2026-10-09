#include <ruby.h>
#include <ruby/encoding.h>
#include <ruby/thread.h>
#include <ruby/io.h>
#include <assert.h>

static VALUE once(int *calls) { ++*calls; return Qnil; }
int main(void) {
    SIGNED_VALUE numbers[] = {RUBY_FIXNUM_MIN, -100, -1, 0, 1, 100, RUBY_FIXNUM_MAX};
    assert(sizeof(VALUE) == sizeof(void *));
    for (size_t i = 0; i < sizeof(numbers) / sizeof(*numbers); ++i) {
        VALUE v = LONG2FIX(numbers[i]);
        assert(FIXNUM_P(v));
        assert(FIX2LONG(v) == numbers[i]);
        assert(RTEST(v));
        assert(!NIL_P(v));
        assert(!SYMBOL_P(v));
    }
    assert(!RTEST(Qfalse) && !RTEST(Qnil));
    assert(RTEST(Qtrue) && RTEST(Qundef));
    assert(NIL_P(Qnil) && !NIL_P(Qfalse));
    for (ID id = 0; id < 10000; ++id) {
        VALUE v = ID2SYM(id);
        assert(SYMBOL_P(v) && !FIXNUM_P(v) && RTEST(v));
        assert(SYM2ID(v) == id);
    }
    VALUE aligned_handle = (VALUE)0x1000;
    assert(!SPECIAL_CONST_P(aligned_handle) && RTEST(aligned_handle));
    assert(!FLONUM_P(aligned_handle));
    int calls = 0;
    assert(!RTEST(once(&calls)) && calls == 1);
    calls = 0;
    assert(SPECIAL_CONST_P(once(&calls)) && calls == 1);
    calls = 0;
    assert(!FLONUM_P(once(&calls)) && calls == 1);
    rb_io_t io = {42, 0};
    assert(FPTR_TO_FD(&io) == 42);
    return 0;
}
