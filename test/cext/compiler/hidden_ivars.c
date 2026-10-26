#include <ruby.h>

/* sqlite3's aggregator keeps its state in ivars named without the @ */
static VALUE stash(VALUE self, VALUE obj, VALUE value) {
    (void)self;
    rb_iv_set(obj, "-stash", value);
    return obj;
}
static VALUE fetch(VALUE self, VALUE obj) {
    (void)self;
    return rb_iv_get(obj, "-stash");
}
static VALUE stashed_p(VALUE self, VALUE obj) {
    (void)self;
    return rb_ivar_defined(obj, rb_intern("-stash"));
}
static VALUE keep(VALUE self, VALUE obj) {
    (void)self;
    VALUE kept = rb_ary_new();
    rb_ary_push(kept, rb_str_new_cstr("kept"));
    rb_ary_push(kept, rb_str_new_cstr("alive"));
    rb_iv_set(obj, "-kept", kept);
    return Qnil;
}
static VALUE fetch_kept(VALUE self, VALUE obj) {
    (void)self;
    return rb_iv_get(obj, "-kept");
}
void Init_hidden_ivars(void) {
    VALUE mod = rb_define_module("CextHidden");
    rb_define_module_function(mod, "stash", stash, 2);
    rb_define_module_function(mod, "fetch", fetch, 1);
    rb_define_module_function(mod, "stashed?", stashed_p, 1);
    rb_define_module_function(mod, "keep", keep, 1);
    rb_define_module_function(mod, "fetch_kept", fetch_kept, 1);
}
