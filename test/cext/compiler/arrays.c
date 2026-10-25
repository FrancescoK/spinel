#include <ruby.h>

static VALUE subseq(VALUE self, VALUE array, VALUE begin, VALUE length) {
    (void)self;
    return rb_ary_subseq(array, FIX2LONG(begin), FIX2LONG(length));
}
static VALUE fresh(VALUE self) {
    (void)self;
    VALUE array = rb_ary_new2(64);
    rb_ary_push(array, INT2FIX(RARRAY_LEN(array)));
    return array;
}
static VALUE lookup(VALUE self, VALUE hash, VALUE key) {
    (void)self;
    return rb_hash_aref(hash, key);
}
void Init_arrays(void) {
    VALUE mod = rb_define_module("CextArrays");
    rb_define_module_function(mod, "subseq", subseq, 3);
    rb_define_module_function(mod, "fresh", fresh, 0);
    rb_define_module_function(mod, "lookup", lookup, 2);
}
