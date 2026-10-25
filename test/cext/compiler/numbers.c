#include <ruby.h>

static VALUE to_long(VALUE self, VALUE value) {
    (void)self;
    return LONG2NUM(NUM2LONG(value));
}
static VALUE next_long(VALUE self, VALUE value) {
    (void)self;
    return LONG2NUM(NUM2LONG(value) + 1);
}
static VALUE double_int(VALUE self, VALUE value) {
    (void)self;
    return INT2NUM(NUM2INT(value) * 2);
}
void Init_numbers(void) {
    VALUE mod = rb_define_module("CextNumbers");
    rb_define_module_function(mod, "to_long", to_long, 1);
    rb_define_module_function(mod, "next_long", next_long, 1);
    rb_define_module_function(mod, "double_int", double_int, 1);
}
