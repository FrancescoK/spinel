#include <ruby.h>
#include <ruby/encoding.h>
#include <ruby/thread.h>
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
static VALUE array_operations(VALUE self) {
  (void)self;VALUE array=rb_ary_new_capa(4);
  Check_Type(array,T_ARRAY);
  rb_ary_store(array,2,INT2FIX(7));
  if(RARRAY_LEN(array)!=3 || !NIL_P(rb_ary_entry(array,0)))rb_raise(rb_eRuntimeError,"array gap");
  if(FIX2INT(rb_ary_pop(array))!=7 || RARRAY_LEN(array)!=2)rb_raise(rb_eRuntimeError,"array pop");
  rb_ary_store(array,-1,INT2FIX(9));
  return rb_ary_entry(array,1);
}
static VALUE number_operations(VALUE self,VALUE value) { (void)self;return LL2NUM(NUM2INT(value)); }
static VALUE large_integer(VALUE self) { (void)self;return LL2NUM(9223372036854775807LL); }
static VALUE floating_number(VALUE self) { (void)self;return DBL2NUM(1.25); }
static VALUE hash_operations(VALUE self) {
  (void)self;VALUE hash=rb_hash_new_capa(2);
  rb_hash_aset(hash,rb_str_new_cstr("answer"),INT2FIX(7));
  rb_hash_aset(hash,rb_str_new_cstr("answer"),INT2FIX(9));
  rb_hash_aset(hash,INT2FIX(3),rb_str_new_cstr("three"));
  return hash;
}
static VALUE check_string(VALUE self,VALUE value) { (void)self;Check_Type(value,T_STRING);return value; }
static VALUE response_string(VALUE self,VALUE input) {
  (void)self;VALUE result=rb_utf8_str_new(RSTRING_PTR(input),RSTRING_LEN(input));
  if(rb_enc_str_coderange(result)==ENC_CODERANGE_BROKEN)rb_enc_associate(result,rb_ascii8bit_encoding());
  return result;
}
static VALUE c_string(VALUE self,VALUE input) { (void)self;return rb_str_new_cstr(StringValueCStr(input)); }
static VALUE temporary_buffer(VALUE self) {
  (void)self;VALUE handle;long *values=RB_ALLOCV_N(long,handle,3);
  values[0]=7;values[1]=11;values[2]=13;
  rb_gc_start();
  return LL2NUM(values[0]+values[1]+values[2]);
}
static VALUE fdset_operations(VALUE self) {
  (void)self;rb_fdset_t set;rb_fd_init(&set);
  rb_fd_set(5000,&set);
  int valid=rb_fd_isset(5000,&set) && !rb_fd_isset(4999,&set);
  rb_fd_term(&set);
  struct timeval timeout={0,0};
  if(rb_thread_fd_select(0,NULL,NULL,NULL,&timeout)!=0)rb_raise(rb_eRuntimeError,"empty fd select");
  return valid ? Qtrue : Qfalse;
}
static VALUE buffer(VALUE self) { (void)self;VALUE s=rb_str_new(NULL,6);memcpy(RSTRING_PTR(s),"buffer",6);return s; }
static VALUE extension_error;
static VALUE custom_error(VALUE self) { (void)self;rb_raise(extension_error,"custom");return Qnil; }
static VALUE module_value(VALUE self) { (void)self;return INT2FIX(41); }
static VALUE held_constant;
static VALUE sentinel;
static VALUE ruby_error;
static VALUE external_error(VALUE self) { (void)self;rb_raise(ruby_error,"external Ruby error");return Qnil; }
static VALUE get_sentinel(VALUE self) { (void)self;return sentinel; }
static VALUE constant(VALUE self) { (void)self;return held_constant; }
static void define_box(VALUE cls) {
  rb_define_alloc_func(cls,alloc);
  rb_define_method(cls,"store",store,1);
  rb_define_method(cls,"get",get,0);
}
void Init_sample(void) {
  rb_global_variable(&sentinel);
  sentinel=rb_obj_alloc(rb_cObject);
  VALUE external=rb_const_get(rb_cObject,rb_intern("CextRubyOwner"));
  ruby_error=rb_const_get(external,rb_intern("Failure"));
  rb_define_class("CextRubyFailure", ruby_error);
  rb_global_variable(&ruby_error);
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
  rb_define_method(cls,"array_operations",array_operations,0);
  rb_define_method(cls,"number_operations",number_operations,1);
  rb_define_method(cls,"large_integer",large_integer,0);
  rb_define_method(cls,"floating_number",floating_number,0);
  rb_define_method(cls,"hash_operations",hash_operations,0);
  rb_define_method(cls,"check_string",check_string,1);
  rb_define_method(cls,"response_string",response_string,1);
  rb_define_method(cls,"c_string",c_string,1);
  rb_define_method(cls,"sentinel",get_sentinel,0);
  rb_define_method(cls,"external_error",external_error,0);
  rb_define_method(cls,"temporary_buffer",temporary_buffer,0);
  rb_define_method(cls,"fdset_operations",fdset_operations,0);
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
