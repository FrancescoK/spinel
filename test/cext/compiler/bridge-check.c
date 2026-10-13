/* Included generated program supplies the same class and exception hooks as
 * the Ruby oracle; the bridge object uses counted_calloc for this test. */
#define main sp_cext_unused_main
#include "program.c"
#undef main
#include <assert.h>

static int native_allocations;
void *counted_calloc(size_t count, size_t size) {
    ++native_allocations;
    return calloc(count, size);
}
static const rb_data_type_t check_type = {
    "bridge-check", {NULL, RUBY_TYPED_DEFAULT_FREE, NULL, NULL, {NULL}}, NULL, NULL, 0
};
static VALUE invalid_data_class(VALUE unused) {
    (void)unused;
    VALUE object;
    rb_data_typed_object_zalloc(INT2FIX(1), 16, &check_type, &object);
    return object;
}
static VALUE identity(VALUE self) { return self; }
static void failing_init(void) {
    rb_define_method(rb_cObject, "broken", RUBY_METHOD_FUNC(identity), 0);
    rb_raise(rb_eRuntimeError, "Init failed");
}
static VALUE (*bad_slots[2])(ANYARGS);
static sp_cext_extension bad = {failing_init, bad_slots, 2, 0, NULL, 0};
static VALUE initialize_bad(VALUE unused) {
    (void)unused;
    sp_cext_init(&bad);
    return Qnil;
}
static VALUE register_outside_init(VALUE unused) {
    (void)unused;
    rb_define_method(rb_cObject, "outside", RUBY_METHOD_FUNC(identity), 0);
    return Qnil;
}
static VALUE wrong_arity(VALUE unused) {
    (void)unused;
    VALUE (*slots[])(ANYARGS) = {RUBY_METHOD_FUNC(identity)};
    sp_cext_extension ready = {NULL, slots, 1, 1, NULL, 0};
    sp_cext_invoke(&ready, 0, 1, sp_box_nil(), sp_PolyArray_new(), NULL);
    return Qnil;
}
int main(void) {
    sp_tu_init();
    _sp_cext_setup();
    sp_cext_init(&_sp_cext_0);
    sp_cext_arena_mark arena = sp_cext_arena_enter();
    int state = 0, roots = sp_gc_nroots;
    rb_protect(invalid_data_class, Qnil, &state);
    assert(state != 0 && native_allocations == 0);
    VALUE object;
    rb_data_typed_object_zalloc(sp_cext_value(sp_cext_class_lookup_fn("CextBox")), 16, &check_type, &object);
    assert(native_allocations == 1 && rb_check_typeddata(object, &check_type));
    for (int retry = 0; retry < 3; ++retry) {
        rb_protect(initialize_bad, Qnil, &state);
        assert(state != 0 && !bad.initialized);
        assert(sp_cext_arena_snapshot().depth == arena.depth + 1 && sp_gc_nroots == roots);
        rb_protect(register_outside_init, Qnil, &state);
        assert(state != 0 && bad_slots[1] == NULL);
    }
    rb_protect(wrong_arity, Qnil, &state);
    assert(state != 0);
    assert(!strcmp(sp_exc_message(sp_cext_rbval(rb_errinfo()).v.p), "wrong number of arguments (given 0, expected 1)"));
    sp_cext_arena_restore(arena);
    puts("C bridge allocation, Init recovery and arity checks passed");
    return 0;
}
