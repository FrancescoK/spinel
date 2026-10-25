#include <ruby.h>

static VALUE drain(VALUE self, VALUE feed) {
    (void)self;
    VALUE out = rb_ary_new();
    for (;;) {
        VALUE item = rb_funcall(feed, rb_intern("next_item"), 0);
        if (NIL_P(item)) break;
        rb_ary_push(out, LONG2FIX(RARRAY_LEN(item)));
        rb_ary_push(out, rb_ary_entry(item, 0));
    }
    return out;
}
void Init_feed(void) {
    VALUE mod = rb_define_module("CextFeed");
    rb_define_module_function(mod, "drain", drain, 1);
}
