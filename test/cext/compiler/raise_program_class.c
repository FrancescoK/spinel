#include <ruby.h>

/* sqlite3's exception.c: an exception of a class the program's Ruby defines,
   made in C and raised with an ivar set */
static VALUE fail_with(VALUE self, VALUE code) {
    (void)self;
    VALUE klass = rb_path2class("Store::QueryError");
    VALUE exception = rb_exc_new2(klass, "near \"frm\": syntax error");
    rb_iv_set(exception, "@code", code);
    rb_exc_raise(exception);
    return Qnil;
}
static VALUE fail_plain(VALUE self) {
    (void)self;
    rb_raise(rb_path2class("Store::Closed"), "cannot use a closed database");
    return Qnil;
}
/* sqlite3's step(): the exception being handled, nil once a rescue is done */
static VALUE errinfo(VALUE self) {
    (void)self;
    return rb_errinfo();
}
void Init_raise_program_class(void) {
    VALUE mod = rb_define_module("CextRaiser");
    rb_define_module_function(mod, "fail_with", fail_with, 1);
    rb_define_module_function(mod, "fail_plain", fail_plain, 0);
    rb_define_module_function(mod, "errinfo", errinfo, 0);
}
