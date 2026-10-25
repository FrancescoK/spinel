#include <ruby.h>

#define FORMATS_VERSION 1.8.1
#define FORMATS_VERSION_STRING STRINGIZE(FORMATS_VERSION)

static rb_block_call_func collect;

static VALUE fail_with(VALUE self, VALUE value) {
    (void)self;
    rb_raise(rb_eTypeError, "%s() returned %"PRIsVALUE" (must be Array[%d]): %+"PRIsVALUE"",
             "next_token", rb_obj_class(value), 2, value);
    return Qnil;
}
static VALUE collect(RB_BLOCK_CALL_FUNC_ARGLIST(item, seen)) {
    rb_ary_push(seen, item);
    return Qnil;
}
static VALUE items(VALUE self, VALUE receiver) {
    (void)self;
    VALUE seen = rb_ary_new();
    rb_block_call(receiver, rb_intern("each"), 0, NULL, collect, seen);
    return seen;
}
void Init_formats(void) {
    VALUE mod = rb_define_module("CextFormats");
    rb_define_module_function(mod, "fail_with", fail_with, 1);
    rb_define_module_function(mod, "items", items, 1);
    rb_define_const(mod, "VERSION", rb_str_freeze(rb_str_new_cstr(FORMATS_VERSION_STRING)));
}
