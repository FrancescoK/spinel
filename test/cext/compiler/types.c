#include <ruby.h>

static VALUE type_of(VALUE self, VALUE value) {
    (void)self;
    return INT2FIX(TYPE(value));
}
static VALUE hash_p(VALUE self, VALUE value) {
    (void)self;
    return RB_TYPE_P(value, T_HASH) ? Qtrue : Qfalse;
}
static VALUE check_hash(VALUE self, VALUE value) {
    (void)self;
    Check_Type(value, T_HASH);
    return value;
}
static VALUE check_array(VALUE self, VALUE value) {
    (void)self;
    Check_Type(value, T_ARRAY);
    return value;
}
void Init_types(void) {
    VALUE mod = rb_define_module("CextTypes");
    rb_define_module_function(mod, "type_of", type_of, 1);
    rb_define_module_function(mod, "hash?", hash_p, 1);
    rb_define_module_function(mod, "check_hash", check_hash, 1);
    rb_define_module_function(mod, "check_array", check_array, 1);
}
