#include <ruby.h>
#include <string.h>
typedef struct { VALUE value; } Box;
static void mark(void *p) { rb_gc_mark(((Box *)p)->value); }
static const rb_data_type_t type={"Box",{mark,RUBY_TYPED_DEFAULT_FREE,0,0,{0}},0,0,0};
static VALUE alloc(VALUE cls) { Box *p;VALUE obj=TypedData_Make_Struct(cls,Box,&type,p);p->value=Qnil;return obj; }
static VALUE store(VALUE self,VALUE value) { Box *p;TypedData_Get_Struct(self,Box,&type,p);p->value=value;return self; }
static VALUE get(VALUE self) { Box *p;TypedData_Get_Struct(self,Box,&type,p);return p->value; }
static VALUE count(int argc,VALUE *argv,VALUE self) { (void)argv;(void)self;return INT2FIX(argc); }
static VALUE decorate(VALUE self,VALUE str) { (void)self;return rb_str_cat_cstr(str,"!"); }
static VALUE push(VALUE self,VALUE arr) { (void)self;return rb_ary_push(arr,rb_str_new_cstr("c")); }
static VALUE echo(VALUE self,VALUE value) { (void)self;return rb_yield(value); }
static VALUE explode(VALUE self) { (void)self;rb_raise(rb_eRuntimeError,"from C");return Qnil; }
static VALUE collect(VALUE self) { rb_gc_start();return self; }
static VALUE decorate_entry(VALUE self,VALUE array) { (void)self;return rb_str_cat_cstr(rb_ary_entry(array,0),"!"); }
static VALUE nested(VALUE self,VALUE array) { (void)self;return rb_ary_push(rb_ary_entry(array,0),INT2FIX(9)); }
static VALUE packed(VALUE self,VALUE array) { (void)self;return INT2FIX(RARRAY_LEN(array)); }
static VALUE buffer(VALUE self) { (void)self;VALUE s=rb_str_new(NULL,6);memcpy(RSTRING_PTR(s),"buffer",6);return s; }
static VALUE extension_error;
static VALUE custom_error(VALUE self) { (void)self;rb_raise(extension_error,"custom");return Qnil; }
static VALUE module_value(VALUE self) { (void)self;return INT2FIX(41); }
static VALUE held_constant;
static VALUE constant(VALUE self) { (void)self;return held_constant; }
static void define_box(VALUE cls) {
  rb_define_alloc_func(cls,alloc);
  rb_define_method(cls,"store",store,1);
  rb_define_method(cls,"get",get,0);
}
void Init_sample(void) {
  VALUE left=rb_define_module("CextLeft"),right=rb_define_module("CextRight");
  define_box(rb_define_class_under(left,"Box",rb_cObject));
  define_box(rb_define_class_under(right,"Box",rb_cObject));
  VALUE parent=rb_define_class("CextParent",rb_cObject);
  rb_define_attr(parent,"level",1,1);
  define_box(rb_define_class("CextDataChild",parent));
  VALUE cls=rb_define_class("CextBox",rb_cObject);
  rb_define_alloc_func(cls,alloc);
  extension_error=rb_define_class("CextCustomError",rb_eRuntimeError);
  rb_define_method(cls,"custom_error",custom_error,0);
  rb_define_attr(cls,"number",1,1);
  VALUE mod=rb_define_module("CextHelpers");
  rb_define_module_function(mod,"from_module",module_value,0);
  rb_include_module(cls,mod);
  rb_define_const(cls,"SYM",ID2SYM(rb_intern("entry")));
  rb_define_method(cls,"buffer",buffer,0);
  rb_define_method(cls,"decorate_entry",decorate_entry,1);
  rb_define_method(cls,"nested",nested,1);
  rb_define_method(cls,"packed",packed,-2);
  held_constant=rb_str_freeze(rb_str_new_cstr("constant"));
  rb_define_const(cls,"ONE",held_constant);
  rb_define_const(cls,"TWO",held_constant);
  rb_define_method(cls,"decorate",decorate,1);
  rb_define_method(cls,"push",push,1);
  rb_define_method(cls,"echo",echo,1);
  rb_define_method(cls,"explode",explode,0);
  rb_define_method(cls,"collect",collect,0);
  rb_define_method(cls,"constant",constant,0);
  rb_define_method(cls,"store",store,1);
  rb_define_method(cls,"get",get,0);
  rb_define_alias(cls,"value","get");
  rb_define_singleton_method(cls,"count",count,-1);
}
