#include <ruby.h>

static VALUE answer(VALUE self) {
    (void)self;
    return INT2FIX(42);
}
void Init_const_defined(void) {
    VALUE outer;
    if (rb_const_defined(rb_cObject, rb_intern("CextDefinedOuter")))
        outer = rb_const_get_at(rb_cObject, rb_intern("CextDefinedOuter"));
    else
        outer = rb_define_module("CextDefinedOuter");
    rb_define_module_function(outer, "answer", answer, 0);
    rb_define_const(outer, "STRING_DEFINED", rb_const_defined(rb_cObject, rb_intern("String")) ? Qtrue : Qfalse);
    rb_define_const(outer, "MISSING_DEFINED", rb_const_defined(rb_cObject, rb_intern("CextDefinedMissing")) ? Qtrue : Qfalse);
    rb_define_const(outer, "INNER_BEFORE", rb_const_defined(outer, rb_intern("Inner")) ? Qtrue : Qfalse);
    rb_define_class_under(outer, "Inner", rb_cObject);
    rb_define_const(outer, "INNER_AFTER", rb_const_defined(outer, rb_intern("Inner")) ? Qtrue : Qfalse);
}
