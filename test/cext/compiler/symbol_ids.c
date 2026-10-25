#include <ruby.h>

static VALUE call0(VALUE self, VALUE receiver, VALUE name) {
    (void)self;
    return rb_funcall(receiver, SYM2ID(name), 0);
}
static VALUE call2(VALUE self, VALUE receiver, VALUE name, VALUE a, VALUE b) {
    (void)self;
    return rb_funcall(receiver, SYM2ID(name), 2, a, b);
}
static VALUE collect(RB_BLOCK_CALL_FUNC_ARGLIST(item, seen)) {
    rb_ary_push(seen, item);
    return Qnil;
}
static VALUE iterate(VALUE self, VALUE receiver, VALUE name) {
    (void)self;
    VALUE seen = rb_ary_new();
    rb_block_call(receiver, SYM2ID(name), 0, NULL, collect, seen);
    return seen;
}
static VALUE name_of(VALUE self, VALUE name) {
    (void)self;
    return rb_str_new_cstr(rb_id2name(SYM2ID(name)));
}
static VALUE literal(VALUE self, VALUE receiver) {
    (void)self;
    return rb_funcall(receiver, rb_intern("area"), 0);
}
void Init_symbol_ids(void) {
    VALUE mod = rb_define_module("CextSymbolIds");
    rb_define_module_function(mod, "call0", call0, 2);
    rb_define_module_function(mod, "call2", call2, 4);
    rb_define_module_function(mod, "iterate", iterate, 2);
    rb_define_module_function(mod, "name_of", name_of, 1);
    rb_define_module_function(mod, "literal", literal, 1);
}
