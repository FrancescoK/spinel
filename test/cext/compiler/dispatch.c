#include <ruby.h>
/* C API calls that CRuby answers through the receiver's Ruby method. */
static VALUE equal(VALUE self, VALUE a, VALUE b) { (void)self; return rb_equal(a, b); }
static VALUE eql(VALUE self, VALUE a, VALUE b) { (void)self; return rb_eql(a, b) ? Qtrue : Qfalse; }
static VALUE responds(VALUE self, VALUE obj) {
  (void)self;
  return rb_respond_to(obj, rb_intern("size")) ? Qtrue : Qfalse;
}
static VALUE responds_private(VALUE self, VALUE obj, VALUE priv) {
  (void)self;
  return rb_obj_respond_to(obj, rb_intern("secret"), RTEST(priv)) ? Qtrue : Qfalse;
}
void Init_dispatch(void) {
  VALUE mod = rb_define_module("CextDispatch");
  rb_define_module_function(mod, "equal", equal, 2);
  rb_define_module_function(mod, "eql", eql, 2);
  rb_define_module_function(mod, "responds", responds, 1);
  rb_define_module_function(mod, "responds_private", responds_private, 2);
}
