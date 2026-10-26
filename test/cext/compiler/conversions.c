#include <ruby.h>
#include <ruby/encoding.h>

/* the conversions, readers and String API sqlite3's extension uses */
static VALUE numbers(VALUE self, VALUE v) {
    (void)self;
    VALUE out = rb_ary_new();
    rb_ary_push(out, LL2NUM(NUM2LL(v)));
    rb_ary_push(out, DBL2NUM(NUM2DBL(v)));
    rb_ary_push(out, SIZET2NUM((size_t)NUM2ULONG(v)));
    rb_ary_push(out, ULL2NUM(18446744073709551615ULL));
    return out;
}
static VALUE pack(VALUE self, VALUE v) {
    (void)self;
    long long word = 0;
    int sign = rb_integer_pack(v, &word, 1, sizeof word, 0, INTEGER_PACK_NATIVE_BYTE_ORDER | INTEGER_PACK_2COMP);
    return rb_ary_new3(2, INT2NUM(sign), LL2NUM(word));
}
static VALUE freeze_it(VALUE self, VALUE v) { (void)self; return rb_obj_freeze(v); }
static VALUE class_by_path(VALUE self, VALUE name) { (void)self; return rb_path2class(StringValueCStr(name)); }
static VALUE delete_from(VALUE self, VALUE ary, VALUE item) { (void)self; return rb_ary_delete(ary, item); }
static VALUE sym_name(VALUE self, VALUE sym) { (void)self; return rb_sym2str(sym); }
static VALUE plus(VALUE self, VALUE a, VALUE b) { (void)self; return rb_str_plus(a, b); }
static VALUE arity_of(VALUE self, VALUE proc) { (void)self; return INT2NUM(rb_proc_arity(proc)); }
static VALUE as_string(VALUE self, VALUE v) {
    (void)self;
    StringValue(v);
    return rb_ary_new3(2, v, rb_obj_class(CLASS_OF(v) == rb_cString ? Qtrue : Qfalse));
}
static VALUE encodings(VALUE self, VALUE s) {
    (void)self;
    VALUE out = rb_ary_new();
    rb_ary_push(out, INT2NUM(rb_enc_get_index(s) == rb_utf8_encindex()));
    rb_ary_push(out, INT2NUM(rb_enc_get_index(s) == rb_ascii8bit_encindex()));
    rb_ary_push(out, INT2NUM(rb_enc_get_index(s) == rb_usascii_encindex()));
    rb_ary_push(out, INT2NUM(rb_enc_find_index("UTF-16LE") == rb_enc_get_index(s)));
    rb_ary_push(out, rb_enc_from_encoding(rb_utf8_encoding()));
    rb_ary_push(out, rb_default_internal_encoding() ? Qtrue : Qnil);
    VALUE utf8 = rb_utf8_str_new_cstr("caf\xc3\xa9");
    rb_ary_push(out, utf8);
    VALUE bin = rb_str_new("ab", 2);
    rb_enc_associate_index(bin, rb_ascii8bit_encindex());
    rb_ary_push(out, bin);
    rb_ary_push(out, rb_str_encode(bin, rb_enc_from_encoding(rb_utf8_encoding()), 0, Qnil));
    rb_ary_push(out, rb_enc_interned_str_cstr("key", rb_utf8_encoding()));
    rb_ary_push(out, rb_str_export_to_enc(rb_utf8_str_new_cstr("x"), rb_ascii8bit_encoding()));
    return out;
}
static VALUE allocs(VALUE self) {
    (void)self;
    int *p = ALLOC_N(int, 4);
    p[3] = 7;
    REALLOC_N(p, int, 8);
    p[7] = p[3] + 1;
    int v = p[7];
    xfree(p);
    char *z = ZALLOC_N(char, 3);
    int zero = z[0] + z[1] + z[2];
    xfree(z);
    return rb_ary_new3(2, INT2NUM(v), INT2NUM(zero));
}
void Init_conversions(void) {
    VALUE mod = rb_define_module("CextConv");
    rb_define_module_function(mod, "numbers", numbers, 1);
    rb_define_module_function(mod, "pack", pack, 1);
    rb_define_module_function(mod, "freeze_it", freeze_it, 1);
    rb_define_module_function(mod, "class_by_path", class_by_path, 1);
    rb_define_module_function(mod, "delete_from", delete_from, 2);
    rb_define_module_function(mod, "sym_name", sym_name, 1);
    rb_define_module_function(mod, "plus", plus, 2);
    rb_define_module_function(mod, "arity_of", arity_of, 1);
    rb_define_module_function(mod, "as_string", as_string, 1);
    rb_define_module_function(mod, "encodings", encodings, 1);
    rb_define_module_function(mod, "allocs", allocs, 0);
}
