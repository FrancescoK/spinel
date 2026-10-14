#include "ruby.h"
static ID answer_id;
static VALUE send0(VALUE self, VALUE obj) {
    (void)self;
    return rb_funcall(obj, answer_id, 0);
}
static VALUE send1(VALUE self, VALUE obj, VALUE arg) {
    (void)self;
    VALUE argv[] = {arg};
    return rb_funcallv(obj, rb_intern("add"), 1, argv);
}
static VALUE get(VALUE self, VALUE obj) { (void)self; return rb_iv_get(obj, "@payload"); }
static VALUE set(VALUE self, VALUE obj, VALUE value) { (void)self; return rb_ivar_set(obj, rb_intern("@payload"), value); }
static VALUE constant(VALUE self, VALUE klass) { (void)self; return rb_const_get(klass, rb_intern("ANSWER")); }
static VALUE builtin_constant(VALUE self) {
    (void)self;
    VALUE klass = rb_const_get(rb_cObject, rb_intern("Regexp"));
    return rb_const_get(klass, rb_intern("IGNORECASE"));
}
static VALUE evaluate_env(VALUE self) { (void)self; return rb_eval_string("ENV['SPINEL_CEXT_STAGE6_ENV']"); }
static VALUE evaluate(VALUE self) { (void)self; return rb_eval_string("6 * 7"); }
static VALUE callback(RB_BLOCK_CALL_FUNC_ARGLIST(yielded, data)) {
    (void)yielded; (void)blockarg;
    rb_gc_start();
    VALUE sum = rb_funcall(data, rb_intern("+"), 1, argv[0]);
    if (rb_block_given_p()) return rb_yield(sum);
    return sum;
}
static VALUE collect(VALUE self, VALUE receiver, VALUE data) {
    (void)self;
    return rb_block_call(receiver, rb_intern("map"), 0, NULL, callback, data);
}
static VALUE callback_info(RB_BLOCK_CALL_FUNC_ARGLIST(yielded, data)) {
    VALUE result = rb_ary_new();
    rb_ary_push(result, INT2FIX(argc)); rb_ary_push(result, yielded);
    rb_ary_push(result, data); rb_ary_push(result, blockarg);
    for (int i = 0; i < argc; i++) rb_ary_push(result, argv[i]);
    rb_gc_start(); return result;
}
static VALUE info(VALUE self, VALUE receiver) {
    (void)self;
    return rb_block_call(receiver, rb_intern("emit"), 0, NULL, callback_info, Qtrue);
}
static VALUE intern_value(VALUE self, VALUE value) { (void)self; return rb_str_intern(value); }
static VALUE mutate(VALUE self, VALUE obj) {
    (void)self;
    VALUE value = rb_funcall(obj, rb_intern("container"), 0);
    rb_ary_push(value, INT2FIX(7));
    rb_str_cat_cstr(rb_ary_entry(value, 0), " C");
    rb_gc_start(); return value;
}
typedef struct { int value; } NativePayload;
static const rb_data_type_t native_type = {"NativePayload", {0, RUBY_TYPED_DEFAULT_FREE, 0}, 0, 0, RUBY_TYPED_FREE_IMMEDIATELY};
static VALUE native_alloc(VALUE klass) {
    NativePayload *payload;
    VALUE value = TypedData_Make_Struct(klass, NativePayload, &native_type, payload);
    payload->value = 123; return value;
}
static VALUE many(VALUE self, VALUE obj) {
    (void)self;
    return rb_funcall(obj, rb_intern("many"), 17,
      INT2FIX(1), INT2FIX(2), INT2FIX(3), INT2FIX(4), INT2FIX(5), INT2FIX(6),
      INT2FIX(7), INT2FIX(8), INT2FIX(9), INT2FIX(10), INT2FIX(11), INT2FIX(12),
      INT2FIX(13), INT2FIX(14), INT2FIX(15), INT2FIX(16), INT2FIX(17));
}
static VALUE text_mutate(VALUE self, VALUE obj) {
    (void)self;
    VALUE value = rb_funcall(obj, rb_intern("text"), 0);
    rb_str_cat_cstr(value, " C"); return value;
}
static VALUE ivar_text_mutate(VALUE self, VALUE obj) {
    (void)self;
    VALUE value = rb_iv_get(obj, "@payload");
    rb_str_cat_cstr(value, "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz");
    rb_gc_start(); return value;
}
static VALUE constant_mutate(VALUE self, VALUE klass) {
    (void)self;
    VALUE array = rb_const_get(klass, rb_intern("VALUES"));
    rb_ary_push(array, INT2FIX(9));
    rb_str_cat_cstr(rb_ary_entry(array, 0), " C");
    VALUE text = rb_const_get(klass, rb_intern("TEXT"));
    rb_str_cat_cstr(text, " C"); rb_gc_start(); return text;
}
void Init_send_sample(void) {
    answer_id = rb_intern2("answer_extra", 6);
    VALUE native = rb_define_class("CextNative", rb_cObject);
    rb_define_alloc_func(native, native_alloc);
    VALUE mod = rb_define_module("CextSend");
    rb_define_singleton_method(mod, "constant_mutate", RUBY_METHOD_FUNC(constant_mutate), 1);
    rb_define_singleton_method(mod, "ivar_text_mutate", RUBY_METHOD_FUNC(ivar_text_mutate), 1);
    rb_define_singleton_method(mod, "builtin_constant", RUBY_METHOD_FUNC(builtin_constant), 0);
    rb_define_singleton_method(mod, "evaluate_env", RUBY_METHOD_FUNC(evaluate_env), 0);
    rb_define_singleton_method(mod, "text_mutate", RUBY_METHOD_FUNC(text_mutate), 1);
    rb_define_singleton_method(mod, "many", RUBY_METHOD_FUNC(many), 1);
    rb_define_singleton_method(mod, "mutate", RUBY_METHOD_FUNC(mutate), 1);
    rb_define_singleton_method(mod, "info", RUBY_METHOD_FUNC(info), 1);
    rb_define_singleton_method(mod, "intern_value", RUBY_METHOD_FUNC(intern_value), 1);
    rb_define_singleton_method(mod, "collect", RUBY_METHOD_FUNC(collect), 2);
    rb_define_singleton_method(mod, "send0", RUBY_METHOD_FUNC(send0), 1);
    rb_define_singleton_method(mod, "send1", RUBY_METHOD_FUNC(send1), 2);
    rb_define_singleton_method(mod, "get", RUBY_METHOD_FUNC(get), 1);
    rb_define_singleton_method(mod, "set", RUBY_METHOD_FUNC(set), 2);
    rb_define_singleton_method(mod, "constant", RUBY_METHOD_FUNC(constant), 1);
    rb_define_singleton_method(mod, "evaluate", RUBY_METHOD_FUNC(evaluate), 0);
}
