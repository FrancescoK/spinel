#include <ruby.h>

/* sqlite3's aggregator: Class.new during Init, instances kept in a
   registered class, a method sent with the count SQLite gives, rb_apply,
   rb_scan_args and a C struct's slot written with the barrier */
static VALUE cWrapper, cInstance;
typedef struct { VALUE handler; long calls; } tracker_t;
static void tracker_mark(void *p) { rb_gc_mark(((tracker_t *)p)->handler); }
static const rb_data_type_t tracker_type = {
    "tracker", {tracker_mark, RUBY_TYPED_DEFAULT_FREE, NULL, NULL, {NULL}}, NULL, NULL, 0
};
static VALUE tracker_alloc(VALUE klass) {
    tracker_t *t;
    VALUE obj = TypedData_Make_Struct(klass, tracker_t, &tracker_type, t);
    t->handler = Qnil;
    return obj;
}
static VALUE tracker_handler_set(VALUE self, VALUE handler) {
    tracker_t *t;
    TypedData_Get_Struct(self, tracker_t, &tracker_type, t);
    RB_OBJ_WRITE(self, &t->handler, handler);
    return handler;
}
static VALUE tracker_send(int argc, VALUE *argv, VALUE self) {
    tracker_t *t;
    VALUE name, rest;
    TypedData_Get_Struct(self, tracker_t, &tracker_type, t);
    rb_scan_args(argc, argv, "1*", &name, &rest);
    t->calls++;
    VALUE *params = RARRAY_LEN(rest) ? ALLOC_N(VALUE, RARRAY_LEN(rest)) : NULL;
    for (long i = 0; i < RARRAY_LEN(rest); i++) params[i] = rb_ary_entry(rest, i);
    VALUE result = rb_funcall2(t->handler, SYM2ID(name), (int)RARRAY_LEN(rest), params);
    if (params) xfree(params);
    return result;
}
static VALUE tracker_apply(VALUE self, VALUE name, VALUE args) {
    tracker_t *t;
    TypedData_Get_Struct(self, tracker_t, &tracker_type, t);
    return rb_apply(t->handler, rb_intern("call"), args) == Qnil ? name : rb_apply(t->handler, SYM2ID(name), args);
}
static VALUE tracker_calls(VALUE self) {
    tracker_t *t;
    TypedData_Get_Struct(self, tracker_t, &tracker_type, t);
    return LONG2NUM(t->calls);
}
static VALUE scan(int argc, VALUE *argv, VALUE self) {
    (void)self;
    VALUE a, b, c, rest, blk;
    rb_scan_args(argc, argv, "11*&", &a, &b, &rest, &blk);
    c = rb_block_given_p() ? rb_yield(a) : Qnil;
    return rb_ary_new3(5, a, b, rest, blk == Qnil ? Qfalse : Qtrue, c);
}
static VALUE scan_opt(int argc, VALUE *argv, VALUE self) {
    (void)self;
    VALUE a, b;
    rb_scan_args(argc, argv, "02", &a, &b);
    return rb_ary_new3(2, a, b);
}
static VALUE wrap(VALUE self, VALUE handler) {
    (void)self;
    VALUE w = rb_class_new_instance(0, NULL, cWrapper);
    rb_iv_set(w, "-handler", handler);
    VALUE inst = rb_class_new_instance(0, NULL, cInstance);
    rb_iv_set(inst, "-wrapper", w);
    return rb_ary_new3(3, w, inst, rb_iv_get(rb_iv_get(inst, "-wrapper"), "-handler"));
}
void Init_spread_sends(void) {
    VALUE mod = rb_define_module("CextSpread");
    VALUE tracker = rb_define_class_under(mod, "Tracker", rb_cObject);
    rb_define_alloc_func(tracker, tracker_alloc);
    rb_define_method(tracker, "handler=", tracker_handler_set, 1);
    rb_define_method(tracker, "send_to", tracker_send, -1);
    rb_define_method(tracker, "apply", tracker_apply, 2);
    rb_define_method(tracker, "calls", tracker_calls, 0);
    rb_define_module_function(mod, "scan_args", scan, -1);
    rb_define_module_function(mod, "scan_opt", scan_opt, -1);
    rb_define_module_function(mod, "wrap", wrap, 1);
    cWrapper = rb_funcall(rb_cClass, rb_intern("new"), 0);
    rb_gc_register_mark_object(cWrapper);
    cInstance = rb_funcall(rb_cClass, rb_intern("new"), 0);
    rb_gc_register_mark_object(cInstance);
}
