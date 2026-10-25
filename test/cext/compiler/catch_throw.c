#include <ruby.h>

static VALUE step(RB_BLOCK_CALL_FUNC_ARGLIST(tag, receiver)) {
    return rb_funcall(receiver, rb_intern("step"), 1, tag);
}
static VALUE run(VALUE self, VALUE receiver) {
    (void)self;
    return rb_catch("cext_jump", step, receiver);
}
static VALUE throw_value(VALUE self, VALUE value) {
    (void)self;
    rb_throw("ruby_jump", value);
    return Qnil;
}
static VALUE collect(RB_BLOCK_CALL_FUNC_ARGLIST(item, seen)) {
    rb_ary_push(seen, item);
    if (RARRAY_LEN(seen) == 2) rb_iter_break();
    return Qnil;
}
static VALUE first_two(VALUE self, VALUE receiver) {
    (void)self;
    VALUE seen = rb_ary_new();
    VALUE result = rb_block_call(receiver, rb_intern("each"), 0, NULL, collect, seen);
    rb_ary_push(seen, result);
    return seen;
}
static VALUE above(RB_BLOCK_CALL_FUNC_ARGLIST(item, limit)) {
    if (FIX2LONG(item) > FIX2LONG(limit)) rb_iter_break_value(item);
    return Qnil;
}
static VALUE first_above(VALUE self, VALUE receiver, VALUE limit) {
    (void)self;
    return rb_block_call(receiver, rb_intern("each"), 0, NULL, above, limit);
}
void Init_catch_throw(void) {
    VALUE mod = rb_define_module("CextCatch");
    rb_define_module_function(mod, "run", run, 1);
    rb_define_module_function(mod, "throw_value", throw_value, 1);
    rb_define_module_function(mod, "first_two", first_two, 1);
    rb_define_module_function(mod, "first_above", first_above, 2);
}
