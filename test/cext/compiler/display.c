#include <ruby.h>
/* A data class whose display, comparison and hashing methods are C. */
typedef struct { long n; } Point;
static const rb_data_type_t type={"CextPoint",{0,RUBY_TYPED_DEFAULT_FREE,0,0,{0}},0,0,0};
static VALUE alloc(VALUE cls) { Point *p;VALUE obj=TypedData_Make_Struct(cls,Point,&type,p);p->n=0;return obj; }
static long value(VALUE self) { Point *p;TypedData_Get_Struct(self,Point,&type,p);return p->n; }
static VALUE init(VALUE self,VALUE n) { Point *p;TypedData_Get_Struct(self,Point,&type,p);p->n=FIX2LONG(n);return self; }
static VALUE to_s(VALUE self) { char s[]="P0";s[1]=(char)('0'+value(self)%10);return rb_str_new_cstr(s); }
static VALUE inspect(VALUE self) { char s[]="#<P 0>";s[4]=(char)('0'+value(self)%10);return rb_str_new_cstr(s); }
static VALUE cmp(VALUE self,VALUE other) { long a=value(self),b=value(other);return INT2FIX(a<b?-1:a>b?1:0); }
static VALUE eq(VALUE self,VALUE other) { return value(self)==value(other)?Qtrue:Qfalse; }
static VALUE hash(VALUE self) { return INT2FIX(value(self)); }
void Init_display(void) {
  VALUE cls=rb_define_class("CextPoint",rb_cObject);
  rb_define_alloc_func(cls,alloc);
  rb_define_method(cls,"initialize",init,1);
  rb_define_method(cls,"to_s",to_s,0);
  rb_define_method(cls,"inspect",inspect,0);
  rb_define_method(cls,"<=>",cmp,1);
  rb_define_method(cls,"==",eq,1);
  rb_define_method(cls,"eql?",eq,1);
  rb_define_method(cls,"hash",hash,0);
}
