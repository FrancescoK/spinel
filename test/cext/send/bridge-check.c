#define main compiled_main
#include "program.c"
#undef main
#include <assert.h>
static VALUE missing(VALUE ignored) {
    (void)ignored;
    VALUE args[19]; for (int i = 0; i < 19; i++) args[i] = Qnil;
    return rb_funcallv(rb_cObject, rb_intern("cext_never_defined_anywhere"), 19, args);
}
int main(int argc, char **argv) {
    compiled_main(argc, argv);
    sp_cext_arena_mark mark = sp_cext_arena_enter();
    if (argc > 1) {
        VALUE args[19]; for (int i = 0; i < 19; i++) args[i] = Qnil;
        rb_funcallv(rb_cObject, rb_intern("answer"), 19, args);
        return 2;
    }
    int state = 0;
    rb_protect(missing, Qnil, &state);
    assert(state != 0);
    sp_RbVal error = sp_cext_rbval(rb_errinfo());
    assert(sp_exc_is_a(error.v.p, "NoMethodError"));
    rb_set_errinfo(Qnil);
    sp_cext_arena_restore(mark);
    return 0;
}
