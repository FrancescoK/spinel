#include <ruby.h>

struct sealed { long value; };
static const rb_data_type_t sealed_type = {
    "sealed",
    { NULL, RUBY_TYPED_DEFAULT_FREE, NULL, },
    0, 0, RUBY_TYPED_FREE_IMMEDIATELY,
};
static VALUE Sealed;

static VALUE make(VALUE self, VALUE value) {
    (void)self;
    struct sealed *data;
    VALUE object = TypedData_Make_Struct(Sealed, struct sealed, &sealed_type, data);
    data->value = FIX2LONG(value);
    return object;
}
static VALUE value(VALUE self) {
    struct sealed *data;
    TypedData_Get_Struct(self, struct sealed, &sealed_type, data);
    return LONG2FIX(data->value);
}
void Init_sealed(void) {
    Sealed = rb_define_class("CextSealed", rb_cObject);
    rb_undef_alloc_func(Sealed);
    rb_undef_method(Sealed, "initialize");
    rb_undef_method(Sealed, "initialize_copy");
    rb_define_singleton_method(Sealed, "make", make, 1);
    rb_define_method(Sealed, "value", value, 0);
}
