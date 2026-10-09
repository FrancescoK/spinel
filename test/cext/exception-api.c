/* The same API checks run against Spinel and a host CRuby extension. */
#include <ruby.h>
#include <assert.h>
#include <errno.h>
static int api_cleanups, api_rescues;
static int api_evaluations;
static VALUE api_once(void) { ++api_evaluations; return Qnil; }
static VALUE api_return(VALUE v) { return v; }
static VALUE api_raise(VALUE v) { (void)v; rb_raise(rb_eArgError, "argument %d", 17); }
static VALUE api_raise_object(VALUE v) { rb_exc_raise(v); }
static VALUE api_cleanup(VALUE v) { ++api_cleanups; return v; }
static VALUE api_handler(VALUE v, VALUE e) { assert(!NIL_P(e)); ++api_rescues; return v; }
static VALUE api_ensure_raise(VALUE v) { return rb_ensure(api_raise, v, api_cleanup, Qnil); }
static VALUE api_no_memory(VALUE v) { (void)v; rb_raise(rb_eNoMemError, "test"); }
static VALUE api_standard_only(VALUE v) { return rb_rescue(api_no_memory, v, api_handler, Qnil); }
static VALUE api_system_error(VALUE v) { (void)v; errno = ENOENT; rb_sys_fail("missing"); }
static VALUE api_continue(VALUE v) {
    int state; rb_protect(api_raise, v, &state); rb_jump_tag(state); return Qnil;
}
static void sp_cext_exception_api_check(void) {
    assert(SPECIAL_CONST_P(api_once()) && api_evaluations == 1);
    api_evaluations = 0;
    assert(!FLONUM_P(api_once()) && api_evaluations == 1);
    int state = -1;
    rb_set_errinfo(Qnil);
    assert(rb_protect(api_return, INT2FIX(17), &state) == INT2FIX(17) && state == 0);
    assert(rb_protect(api_raise, Qnil, &state) == Qnil && state != 0);
    assert(!NIL_P(rb_errinfo()));
    assert(rb_protect(api_raise, Qnil, NULL) == Qnil);
    VALUE error = rb_exc_new_cstr(rb_eRuntimeError, "same object");
    rb_protect(api_raise_object, error, &state);
    assert(state && rb_errinfo() == error);
    assert(rb_ensure(api_return, INT2FIX(3), api_cleanup, Qnil) == INT2FIX(3));
    rb_protect(api_ensure_raise, Qnil, &state);
    assert(state && api_cleanups == 2);
    rb_set_errinfo(Qnil);
    assert(rb_rescue(api_raise, Qnil, api_handler, INT2FIX(9)) == INT2FIX(9));
    assert(NIL_P(rb_errinfo()) && api_rescues == 1);
    assert(rb_rescue2(api_raise, Qnil, api_handler, INT2FIX(10), rb_eRuntimeError, rb_eArgError, (VALUE)0) == INT2FIX(10));
    assert(api_rescues == 2);
    assert(rb_rescue2(api_system_error, Qnil, api_handler, INT2FIX(11), rb_eSystemCallError, (VALUE)0) == INT2FIX(11));
    assert(api_rescues == 3);
    rb_protect(api_standard_only, Qnil, &state);
    assert(state && api_rescues == 3);
    rb_protect(api_continue, Qnil, &state);
    assert(state && !NIL_P(rb_errinfo()));
    rb_set_errinfo(Qnil);
    (void)RB_GC_GUARD(error);
}
#ifdef SP_CEXT_ORACLE
void Init_cext_exception_oracle(void) { sp_cext_exception_api_check(); }
#endif
