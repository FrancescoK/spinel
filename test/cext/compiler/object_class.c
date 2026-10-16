#include <ruby.h>

static VALUE object_class(VALUE self, VALUE object) {
    (void)self;
    return rb_obj_class(object);
}
static VALUE class_name(VALUE self, VALUE klass) {
    (void)self;
    return rb_str_new_cstr(rb_class2name(klass));
}
void Init_object_class(void) {
    VALUE mod = rb_define_module("CextObjectClass");
    rb_define_module_function(mod, "of", object_class, 1);
    rb_define_module_function(mod, "name_of", class_name, 1);
}
