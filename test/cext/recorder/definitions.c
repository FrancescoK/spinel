#include "ruby.h"
static VALUE answer(VALUE self) { (void)self; return INT2FIX(42); }
static VALUE unary(VALUE self, VALUE arg) { (void)self; (void)arg; return INT2FIX(42); }
static VALUE many(int argc, VALUE *argv, VALUE self) { (void)argc; (void)argv; return answer(self); }
static VALUE packed(VALUE self, VALUE args) { (void)args; return answer(self); }
static VALUE call(VALUE self) { return rb_funcall(self, rb_intern("str" "ip"), 0); }
/* The fixture records allocation registration without invoking it. */
static VALUE allocator(VALUE klass) { return klass; }
#define CONSTANT(owner, name, number) rb_define_const(owner, #name, INT2FIX(number))
void Init_sample(void) {
    VALUE m = rb_define_module("Sample");
    VALUE c = rb_define_class_under(m, "Box", rb_cObject);
    rb_define_alloc_func(c, allocator);
    rb_define_method(c, "answer", RUBY_METHOD_FUNC(answer), 0);
    rb_define_private_method(c, "hidden", RUBY_METHOD_FUNC(many), -1);
    rb_define_singleton_method(c, "call", RUBY_METHOD_FUNC(call), 0);
    rb_define_module_function(m, "answer", RUBY_METHOD_FUNC(packed), -2);
    rb_define_attr(c, "data", 1, 1);
    rb_define_alias(c, "result", "answer");
    CONSTANT(m, ANSWER, 42);
    rb_define_const(m, "NOTHING", Qnil);
    rb_define_const(m, "YES", Qtrue);
    rb_define_const(m, "NO", Qfalse);
    rb_define_const(m, "NAME", ID2SYM(rb_intern("sample")));
    VALUE string = rb_str_freeze(rb_str_new("x\0\xff", 3));
    rb_define_const(m, "BYTES", string);
    rb_define_const(m, "SAME_BYTES", string);
    rb_define_const(m, "BOX", c);
    for (int i = 0; i < 2; i++) rb_define_method(c, i ? "second" : "first", i ? RUBY_METHOD_FUNC(unary) : RUBY_METHOD_FUNC(answer), i);
    rb_include_module(c, m);
    rb_extend_object(c, m);
    /* Reopening a module must retain its identity and qualification. */
    VALUE same = rb_define_module("Sample");
    rb_define_const(same, "SAME", same == m ? Qtrue : Qfalse);
}
