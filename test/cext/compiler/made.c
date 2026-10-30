#include <ruby.h>

struct made { long value; };
static const rb_data_type_t made_type = {
    "made",
    { NULL, RUBY_TYPED_DEFAULT_FREE, NULL, },
    0, 0, RUBY_TYPED_FREE_IMMEDIATELY,
};
static VALUE Made;

static VALUE make(VALUE self, VALUE value) {
    (void)self;
    struct made *data;
    VALUE object = TypedData_Make_Struct(Made, struct made, &made_type, data);
    data->value = FIX2LONG(value);
    return object;
}
static struct made *get(VALUE self) {
    struct made *data;
    TypedData_Get_Struct(self, struct made, &made_type, data);
    return data;
}
static VALUE to_s(VALUE self) { (void)self; return rb_str_new_cstr("made"); }
static VALUE inspect(VALUE self) { (void)self; return rb_str_new_cstr("#<made>"); }
static VALUE to_int(VALUE self) { return LONG2FIX(get(self)->value); }
void Init_made(void) {
    Made = rb_define_class("CextMade", rb_cObject);
    rb_undef_alloc_func(Made);
    rb_undef_method(Made, "initialize");
    rb_define_singleton_method(Made, "make", make, 1);
    rb_define_method(Made, "to_s", to_s, 0);
    rb_define_method(Made, "inspect", inspect, 0);
    rb_define_method(Made, "to_int", to_int, 0);
}
