#define main sp_cext_unused_main
#include "../../build/cext/host.c"
#undef main
#include <ruby.h>
#include <assert.h>
#include "exception-api.c"

static int cleanup_calls;
static sp_RbVal allocate_custom(const char *name, const char *message) {
    assert(!strcmp(name, "CextTestError"));
    sp_CextTestError *e = sp_exc_new_sub_sized(sizeof(*e), name, message);
    ((sp_gc_hdr *)e - 1)->scan = sp_CextTestError__gc_scan;
    return sp_box_obj(e, 0);
}
static VALUE custom_new(VALUE klass) { return rb_exc_new_cstr(klass, "custom"); }
static VALUE custom_raise(VALUE klass) { rb_raise(klass, "custom %d", 42); }
static VALUE success(VALUE argument) { return argument; }
static VALUE c_raise(VALUE argument) {
    (void)argument;
    (void)sp_cext_arena_enter();
    (void)sp_cext_arena_enter();
    sp_RbVal number = {SP_TAG_FLT, 0, {.f = 3.25}};
    (void)sp_cext_value(number);
    rb_raise(rb_eRuntimeError, "bad %d", 42);
}
static VALUE ruby_raise(VALUE argument) {
    (void)argument; sp_raise_cls("ArgumentError", "Ruby side");
}
static VALUE cleanup(VALUE argument) {
    ++cleanup_calls; sp_gc_collect(); return argument;
}
static VALUE cleanup_raise(VALUE argument) {
    (void)argument; ++cleanup_calls; rb_raise(rb_eTypeError, "cleanup failed");
}
static VALUE ensure_raise(VALUE argument) {
    return rb_ensure(c_raise, argument, cleanup, Qnil);
}
static VALUE ensure_replace(VALUE argument) {
    return rb_ensure(c_raise, argument, cleanup_raise, Qnil);
}
static VALUE handler(VALUE argument, VALUE error) {
    assert(sp_exc_is_a(sp_cext_rbval(error).v.p, "StandardError"));
    return argument;
}
static VALUE unmatched(VALUE argument) {
    return rb_rescue2(c_raise, Qnil, handler, argument, rb_eArgError, (VALUE)0);
}
static VALUE jump(VALUE argument) {
    int state; rb_protect(ruby_raise, argument, &state); rb_jump_tag(state); return Qnil;
}
static VALUE fatal(VALUE argument) { (void)argument; rb_fatal("fatal test"); }
static VALUE fatal_cleanup(VALUE argument) { (void)argument; puts("fatal ensured"); return Qnil; }
static VALUE fatal_ensure(VALUE argument) { return rb_ensure(fatal, argument, fatal_cleanup, Qnil); }
static VALUE fatal_rescue(VALUE argument) {
    return rb_rescue2(fatal, Qnil, handler, argument, rb_eException, (VALUE)0);
}
int main(int argc, char **argv) {
    sp_tu_init();
    sp_cext_arena_mark arena = sp_cext_arena_enter();
    sp_cext_exceptions_init();
    if (argc > 1 && !strcmp(argv[1], "fatal")) { fatal_ensure(Qnil); assert(0); }
    sp_cext_exception_api_check();
    int roots = sp_gc_nroots, state = -1;
    sp_RbVal custom_class = {SP_TAG_CLASS, SP_CLASS_BY_NAME, {.s = &("\xff" "CextTestError")[1]}};
    VALUE klass = sp_cext_value(custom_class);
    rb_protect(custom_new, klass, &state);
    assert(state && !strcmp(((sp_Exception *)sp_cext_rbval(rb_errinfo()).v.p)->cls_name, "NotImplementedError"));
    sp_cext_exception_new_fn = allocate_custom;
    VALUE custom = rb_exc_new_cstr(klass, "custom");
    sp_RbVal cv = sp_cext_rbval(custom);
    assert(cv.cls_id == 0 && ((sp_gc_hdr *)cv.v.p - 1)->size >= sizeof(sp_CextTestError));
    ((sp_CextTestError *)cv.v.p)->iv_detail = 41;
    rb_protect(api_raise_object, custom, &state);
    assert(state && rb_errinfo() == custom);
    sp_gc_collect();
    assert(((sp_CextTestError *)sp_cext_rbval(rb_errinfo()).v.p)->iv_detail == 41);
    rb_protect(custom_raise, klass, &state);
    assert(state && sp_cext_rbval(rb_errinfo()).cls_id == 0);
    assert(rb_protect(success, INT2FIX(7), &state) == INT2FIX(7) && state == 0);
    assert(rb_protect(c_raise, Qnil, &state) == Qnil && state != 0);
    assert(sp_cext_arena_snapshot().depth == 1 && sp_gc_nroots == roots);
    sp_Exception *e = sp_cext_rbval(rb_errinfo()).v.p;
    assert(!strcmp(e->cls_name, "RuntimeError") && !strcmp(sp_exc_message(e), "bad 42"));
    rb_protect(ruby_raise, Qnil, &state);
    assert(state && !strcmp(((sp_Exception *)sp_cext_rbval(rb_errinfo()).v.p)->cls_name, "ArgumentError"));
    rb_protect(ensure_raise, Qnil, &state);
    e = sp_cext_rbval(rb_errinfo()).v.p;
    assert(state && cleanup_calls == 1 && !strcmp(e->cls_name, "RuntimeError"));
    rb_protect(ensure_replace, Qnil, &state);
    e = sp_cext_rbval(rb_errinfo()).v.p;
    assert(state && cleanup_calls == 2 && !strcmp(e->cls_name, "TypeError"));
    assert(e->cause && !strcmp(e->cause->cls_name, "RuntimeError"));
    rb_set_errinfo(Qnil);
    assert(rb_rescue(c_raise, Qnil, handler, INT2FIX(9)) == INT2FIX(9));
    assert(NIL_P(rb_errinfo()));
    assert(rb_rescue2(ruby_raise, Qnil, handler, INT2FIX(10), rb_eTypeError, rb_eArgError, (VALUE)0) == INT2FIX(10));
    rb_protect(unmatched, Qnil, &state);
    assert(state && !strcmp(((sp_Exception *)sp_cext_rbval(rb_errinfo()).v.p)->cls_name, "RuntimeError"));
    rb_protect(jump, Qnil, &state);
    assert(state && !strcmp(((sp_Exception *)sp_cext_rbval(rb_errinfo()).v.p)->cls_name, "ArgumentError"));
    rb_protect(fatal_rescue, Qnil, &state);
    assert(state == 8);
    assert(!sp_exc_cls_matches("fatal", "Exception"));
    /* An ordinary generated-runtime handler catches a C raise, including
       the arena cleanup that rb_protect is not involved in. */
    jmp_buf frame;
    if (setjmp(frame) == 0) {
        sp_exc_arm(frame); c_raise(Qnil); assert(0);
    }
    assert(!strcmp(sp_exc_cur_cls(), "RuntimeError"));
    sp_exc_disarm(); sp_gc_nroots = roots;
    assert(sp_cext_arena_snapshot().depth == 1);
    /* Two saved fiber contexts have separate error state and arena backing
       stores; collection must retain pins belonging to the suspended one. */
    rb_set_errinfo(rb_exc_new_cstr(rb_eRuntimeError, "context A"));
    VALUE error_a = rb_errinfo();
    void *context_a = sp_exc_ctx_new(), *context_b = sp_exc_ctx_new();
    sp_exc_ctx_save(context_a);
    sp_exc_ctx_load(context_b);
    assert(NIL_P(rb_errinfo()) && sp_cext_arena_snapshot().depth == 0);
    sp_cext_arena_mark arena_b = sp_cext_arena_enter();
    sp_RbVal f = {SP_TAG_FLT, 0, {.f = 9.5}};
    VALUE held_b = sp_cext_value(f);
    rb_set_errinfo(rb_exc_new_cstr(rb_eArgError, "context B"));
    VALUE error_b = rb_errinfo();
    sp_exc_ctx_save(context_b);
    sp_exc_ctx_load(context_a);
    assert(rb_errinfo() == error_a && sp_cext_arena_snapshot().depth == 1);
    sp_gc_collect();
    assert(sp_cext_rbval(held_b).v.f == 9.5);
    sp_exc_ctx_save(context_a);
    sp_exc_ctx_load(context_b);
    assert(rb_errinfo() == error_b && sp_cext_arena_snapshot().depth == 1);
    rb_protect(c_raise, Qnil, &state);
    assert(state && sp_cext_arena_snapshot().depth == 1);
    rb_set_errinfo(Qnil);
    sp_cext_arena_restore(arena_b);
    sp_exc_ctx_save(context_b);
    sp_exc_ctx_load(context_a);
    sp_exc_ctx_free(context_b);
    rb_set_errinfo(Qnil);
    sp_cext_arena_restore(arena);
    sp_exc_ctx_save(context_a);
    sp_cext_arena_context empty = {0}; sp_cext_arena_context_load(&empty);
    sp_exc_ctx_free(context_a);
    for (int i = 0; i < 256; ++i) sp_gc_collect();
    assert(sp_cext_arena_snapshot().depth == 0);
    puts("cext-exceptions-test: pass");
}
