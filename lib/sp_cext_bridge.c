/* Opted-in compiler bridge. The retained recorder objects are linked again;
 * deterministic Init registrations bind the same zero-based function slots. */
#ifdef SP_CEXT
#include "sp_cext.h"
#include "sp_string.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "sp_setjmp.h"
void sp_exc_arm(jmp_buf);
void sp_exc_disarm(void);
const char *sp_exc_cur_cls(void);
const char *sp_exc_cur_msg(void);
void *sp_exc_cur_obj(void);
void sp_fiber_reraise(const char *, const char *, void *);
extern void (*sp_user_init_copy_hook_lib)(sp_RbVal, sp_RbVal);
VALUE rb_cObject, rb_cBasicObject, rb_cClass, rb_cModule;
VALUE rb_cString, rb_cArray, rb_cHash, rb_cInteger, rb_cFloat, rb_cIO;
sp_RbVal (*sp_cext_class_lookup_fn)(const char *);
void *(*sp_cext_object_alloc_fn)(int);
void *(*sp_cext_class_alloc_fn)(int);
static sp_cext_extension *binding;
static size_t next_function, next_constant;
#define current_block ((sp_Proc *)sp_cext_current_block)
static const char *class_name(VALUE v) {
    sp_RbVal r = sp_cext_rbval(v);
    if (r.tag != SP_TAG_CLASS) sp_raise_cls("TypeError", "class or module expected");
    if (r.cls_id == SP_CLASS_BY_NAME) return r.v.s;
    if (sp_obj_cls_name_fn) return sp_obj_cls_name_fn((int)r.v.i);
    sp_raise_cls("TypeError", "unknown C extension class");
}
static VALUE lookup(const char *name) {
    if (!sp_cext_class_lookup_fn) sp_raise_cls("RuntimeError", "C extension class hook is missing");
    return sp_cext_value(sp_cext_class_lookup_fn(name));
}
static VALUE define_under(VALUE outer, const char *name) {
    const char *parent = class_name(outer);
    if (!strcmp(parent, "Object")) return lookup(name);
    size_t len = strlen(parent) + strlen(name) + 3;
    char *full = malloc(len); if (!full) rb_raise(rb_eNoMemError, "class name allocation failed");
    snprintf(full, len, "%s::%s", parent, name);
    VALUE v = lookup(full); free(full); return v;
}
VALUE rb_define_class(const char *name, VALUE superclass) { (void)superclass; return lookup(name); }
VALUE rb_define_class_under(VALUE outer, const char *name, VALUE superclass) { (void)superclass; return define_under(outer,name); }
VALUE rb_define_module(const char *name) { return lookup(name); }
VALUE rb_define_module_under(VALUE outer, const char *name) { return define_under(outer,name); }
static void bind_function(VALUE (*fn)(ANYARGS)) {
    if (!binding || next_function >= binding->count)
        sp_raise_cls("RuntimeError", "C extension definitions outside Init are unsupported");
    binding->functions[next_function++] = fn;
}
void rb_define_method(VALUE owner,const char *name,VALUE (*fn)(ANYARGS),int arity) { (void)owner;(void)name;(void)arity;bind_function(fn); }
void rb_define_private_method(VALUE o,const char *n,VALUE (*f)(ANYARGS),int a) { rb_define_method(o,n,f,a); }
void rb_define_singleton_method(VALUE o,const char *n,VALUE (*f)(ANYARGS),int a) { rb_define_method(o,n,f,a); }
void rb_define_module_function(VALUE o,const char *n,VALUE (*f)(ANYARGS),int a) { rb_define_method(o,n,f,a);rb_define_method(o,n,f,a); }
void rb_define_alloc_func(VALUE o,VALUE (*fn)(VALUE)) { (void)o;bind_function((VALUE (*)(ANYARGS))fn); }
void rb_define_alias(VALUE o,const char *n,const char *old) { (void)o;(void)n;(void)old; }
void rb_define_attr(VALUE o,const char *n,int r,int w) { (void)o;(void)n;(void)r;(void)w; }
void rb_include_module(VALUE o,VALUE m) { (void)o;(void)m; }
void rb_extend_object(VALUE o,VALUE m) { (void)o;(void)m; }
void rb_define_const(VALUE o,const char *n,VALUE v) {
    (void)o;(void)n;
    if(!binding || next_constant>=binding->constant_count)sp_raise_cls("RuntimeError","C constant definitions outside Init are unsupported");
    binding->constants[next_constant]=v;
    rb_gc_register_address(&binding->constants[next_constant++]);
}
void sp_cext_init(sp_cext_extension *extension) {
    if (extension->initialized) return;
    sp_cext_exceptions_init();
#define BUILTIN(var,name) do { var=lookup(name);rb_gc_register_address(&var); } while(0)
    BUILTIN(rb_cBasicObject,"BasicObject");BUILTIN(rb_cObject,"Object");
    BUILTIN(rb_cClass,"Class");BUILTIN(rb_cModule,"Module");
    BUILTIN(rb_cString,"String");BUILTIN(rb_cArray,"Array");
    BUILTIN(rb_cHash,"Hash");BUILTIN(rb_cInteger,"Integer");
    BUILTIN(rb_cFloat,"Float");BUILTIN(rb_cIO,"IO");
#undef BUILTIN
    sp_cext_arena_mark mark=sp_cext_arena_enter();
    sp_cext_extension *previous=binding;
    size_t previous_function=next_function, previous_constant=next_constant;
    int roots=sp_gc_nroots;
    jmp_buf frame;
    if(setjmp(frame)!=0) {
        int unwind=sp_cext_unwinding();
        const char *cls=sp_exc_cur_cls(), *msg=sp_exc_cur_msg();void *obj=sp_exc_cur_obj();
        sp_exc_disarm();binding=previous;
        next_function=previous_function;next_constant=previous_constant;
        sp_cext_arena_restore(mark);sp_gc_nroots=roots;
        if(unwind)sp_cext_resume_unwind();
        else sp_fiber_reraise(cls,msg,obj);
        abort();
    }
    sp_exc_arm(frame);
    binding=extension;next_function=0;next_constant=0;extension->init();
    sp_exc_disarm();binding=previous;
    next_function=previous_function;next_constant=previous_constant;
    extension->initialized=1;
    sp_cext_arena_restore(mark);
}
static sp_cext_data *data_object(VALUE object) {
    sp_RbVal r=sp_cext_rbval(object);
    if(r.tag!=SP_TAG_OBJ || r.cls_id<0 || !r.v.p || !sp_cext_data_class_fn || !sp_cext_data_class_fn(r.cls_id))
        rb_raise(rb_eTypeError,"expected TypedData object");
    return r.v.p;
}
VALUE rb_data_typed_object_wrap(VALUE klass,void *data,const rb_data_type_t *type) {
    sp_RbVal k=sp_cext_rbval(klass);
    if(k.tag!=SP_TAG_CLASS || k.cls_id==SP_CLASS_BY_NAME || !sp_cext_object_alloc_fn ||
       !sp_cext_data_class_fn || !sp_cext_data_class_fn((int)k.v.i)) rb_raise(rb_eTypeError,"class has no TypedData layout");
    void *ptr=sp_cext_object_alloc_fn((int)k.v.i);
    sp_cext_data *o=ptr; o->cext_data=data; o->cext_type=type;
    if(!(type->flags&RUBY_TYPED_WB_PROTECTED))sp_gc_pin_remembered(ptr);
    return sp_cext_value(sp_box_obj(ptr,(int)k.v.i));
}
void *rb_data_typed_object_zalloc(VALUE klass,size_t size,const rb_data_type_t *type,VALUE *value) {
    VALUE object=rb_data_typed_object_wrap(klass,NULL,type);
    void *data=calloc(1,size); if(!data)rb_raise(rb_eNoMemError,"TypedData allocation failed");
    data_object(object)->cext_data=data;
    *value=object;return data;
}
void *rb_check_typeddata(VALUE value,const rb_data_type_t *type) {
    sp_cext_data *o=data_object(value);
    if(!sp_cext_data_is_kind_of(o,type))rb_raise(rb_eTypeError,"wrong TypedData type");
    return o->cext_data;
}
void *sp_cext_data_ptr(VALUE value) { return data_object(value)->cext_data; }
const rb_data_type_t *sp_cext_data_type(VALUE value) { return data_object(value)->cext_type; }
void *sp_cext_allocate(sp_cext_extension *ext,int slot,int cls) {
    sp_cext_init(ext);sp_cext_arena_mark mark=sp_cext_arena_enter();
    sp_RbVal k={SP_TAG_CLASS,cls,{.i=cls}};
    VALUE obj=((VALUE (*)(VALUE))ext->functions[slot])(sp_cext_value(k));
    sp_RbVal r=sp_cext_rbval(obj);
    if(r.tag!=SP_TAG_OBJ || !r.v.p || r.cls_id!=cls)rb_raise(rb_eTypeError,"allocator returned the wrong class");
    void *ptr=r.v.p;sp_cext_arena_restore(mark);return ptr;
}
sp_RbVal sp_cext_duplicate(sp_RbVal value,int keep_frozen) {
    if(value.tag!=SP_TAG_OBJ || !value.v.p || value.cls_id<0 || !sp_cext_data_class_fn || !sp_cext_data_class_fn(value.cls_id))return value;
    value.cls_id=(int)((sp_cext_data *)value.v.p)->cls_id;
    SP_GC_ROOT_RBVAL(value);
    void *src=value.v.p;
    sp_gc_hdr *hdr=(sp_gc_hdr *)src-1;
    size_t size=hdr->size-sizeof(*hdr);
    void *ptr=sp_cext_class_alloc_fn(value.cls_id);SP_GC_ROOT(ptr);
    sp_cext_data *fresh=ptr;
    void *data=fresh->cext_data;const rb_data_type_t *type=fresh->cext_type;
    memcpy(ptr,src,size);fresh->cext_data=data;fresh->cext_type=type;
    sp_RbVal copy=value;copy.v.p=ptr;
    if(sp_user_init_copy_hook_lib)sp_user_init_copy_hook_lib(copy,value);
    if(keep_frozen && hdr->frozen)((sp_gc_hdr *)ptr-1)->frozen=1;
    return copy;
}
VALUE rb_str_new(const char *s,long len) {
    if(len<0)rb_raise(rb_eArgError,"negative string size");
    if(len>INT64_MAX/2-64)rb_raise(rb_eArgError,"string size too large");
    sp_String *str=sp_String_new_len(s?s:"",s?len:0);SP_GC_ROOT(str);
    if(!s) {
        if(!sp_fd_grow(str,len))rb_raise(rb_eNoMemError,"string allocation failed");
        memset(str->data,0,(size_t)len);str->len=len;str->data[len]=0;
    }
    str->binary=1;sp_fd_publish(str);
    return sp_cext_value(sp_box_obj(str,SP_BUILTIN_STRBUF));
}
VALUE rb_str_new_cstr(const char *s) { return rb_str_new(s,(long)strlen(s)); }
static sp_String *string(VALUE value) {
    sp_RbVal r=sp_cext_rbval(value);
    if(r.tag==SP_TAG_OBJ && r.cls_id==SP_BUILTIN_STRBUF)return r.v.p;
    if(r.tag==SP_TAG_STR && sp_str_is_frozen_val(r.v.s))sp_raise_frozen_str(r.v.s);
    rb_raise(rb_eTypeError,"expected a shared String");
}
VALUE rb_str_freeze(VALUE v) {
    sp_RbVal r=sp_cext_rbval(v);
    if(r.tag==SP_TAG_STR && sp_str_is_frozen_val(r.v.s))return v;
    sp_String_freeze(string(v));return v;
}
char *sp_cext_string_ptr(VALUE v) {
    sp_RbVal r=sp_cext_rbval(v);if(r.tag==SP_TAG_STR)return (char *)r.v.s;
    return string(v)->data;
}
long sp_cext_string_len(VALUE v) {
    sp_RbVal r=sp_cext_rbval(v);if(r.tag==SP_TAG_STR)return (long)sp_str_byte_len(r.v.s);
    return (long)string(v)->len;
}
VALUE rb_str_cat(VALUE v,const char *s,long len) { if(len<0)rb_raise(rb_eArgError,"negative string size");sp_String_append_n(string(v),s,(size_t)len);return v; }
VALUE rb_str_cat_cstr(VALUE v,const char *s) { return rb_str_cat(v,s,(long)strlen(s)); }
static sp_PolyArray *array(VALUE value) {
    sp_RbVal r=sp_cext_rbval(value);
    if(r.tag==SP_TAG_OBJ && r.cls_id==SP_BUILTIN_POLY_ARRAY)return r.v.p;
    rb_raise(rb_eTypeError,"expected a widened Array");
}
sp_PolyArray *sp_cext_share_new_array(sp_PolyArray *array) {
    SP_GC_ROOT(array);
    if(!array)return array;
    for(sp_int i=0;i<array->len;i++) {
        sp_RbVal value=array->data[i];
        if(value.tag==SP_TAG_STR && value.v.s && !sp_str_is_frozen_val(value.v.s)) {
            sp_RbVal shared=value;
            if(((const unsigned char *)value.v.s)[-1]==0xfd) {
                sp_String *owner=(sp_String *)(void *)((sp_str_hdr *)sp_fd_base(value.v.s))->next;
                if(owner && owner->data==value.v.s)shared=sp_box_obj(owner,SP_BUILTIN_STRBUF);
            }
            if(shared.tag==SP_TAG_STR)shared=sp_box_obj(sp_String_new_shared(value.v.s),SP_BUILTIN_STRBUF);
            sp_gc_wb(array);array->data[i]=shared;
        }
    }
    return array;
}
VALUE rb_ary_new(void) { return sp_cext_value(sp_box_poly_array(sp_PolyArray_new())); }
VALUE rb_ary_push(VALUE v,VALUE item) { sp_PolyArray_push(array(v),sp_cext_rbval(item));return v; }
VALUE rb_ary_entry(VALUE v,long i) { sp_PolyArray *a=array(v);if(i<0)i+=a->len;return i<0||i>=a->len?Qnil:sp_cext_value(a->data[i]); }
long sp_cext_array_len(VALUE v) { return (long)array(v)->len; }
ID rb_intern(const char *name) {
    if(!sp_json_sym_intern_fn)sp_raise_cls("RuntimeError","C extension symbol hook is missing");
    return (ID)sp_json_sym_intern_fn(name);
}
const char *rb_id2name(ID id) { return sp_sym_name_fn?sp_sym_name_fn((sp_sym)id):NULL; }
void rb_gc_start(void) { sp_gc_collect(); }
int rb_block_given_p(void) { return current_block!=NULL; }
VALUE rb_block_proc(void) {
    if(!current_block)rb_raise(rb_eArgError,"tried to create Proc object without a block");
    return sp_cext_value(sp_box_obj(current_block,SP_BUILTIN_PROC));
}
VALUE rb_yield_values2(int argc,const VALUE *argv) {
    if(!current_block)sp_raise_cls("LocalJumpError","no block given");
    if(argc<0 || argc>SP_PROC_ARG_SLOTS)rb_raise(rb_eArgError,"too many block arguments");
    sp_int raw[SP_PROC_ARG_SLOTS];
    for(int i=0;i<argc;i++) {
        sp_RbVal v=sp_cext_rbval(argv[i]);_sp_proc_poly_args[i]=v;
        raw[i]=v.v.i;
    }
    _sp_proc_poly_ret=sp_box_nil();sp_proc_call(current_block,argc,raw);
    return sp_cext_value(_sp_proc_poly_ret);
}
VALUE rb_yield(VALUE v) { return rb_yield_values2(1,&v); }
VALUE rb_yield_values(int argc,...) {
    if(argc<0 || argc>SP_PROC_ARG_SLOTS)rb_raise(rb_eArgError,"too many block arguments");
    VALUE values[SP_PROC_ARG_SLOTS];va_list args;va_start(args,argc);
    for(int i=0;i<argc;i++)values[i]=va_arg(args,VALUE);va_end(args);
    return rb_yield_values2(argc,values);
}
sp_RbVal sp_cext_invoke(sp_cext_extension *ext,int slot,int arity,sp_RbVal self,sp_PolyArray *args,sp_Proc *block) {
    sp_cext_init(ext);
    SP_GC_ROOT_RBVAL(self);SP_GC_ROOT(args);SP_GC_ROOT(block);
    sp_cext_arena_mark mark=sp_cext_arena_enter();
    int argc=args?(int)args->len:0;
    VALUE *argv=argc?sp_gc_alloc((size_t)argc*sizeof(VALUE),NULL,NULL):NULL;
    SP_GC_ROOT(argv);
    if(argc&&!argv)rb_raise(rb_eNoMemError,"C argument allocation failed");
    for(int i=0;i<argc;i++)argv[i]=sp_cext_value(args->data[i]);
    VALUE recv=sp_cext_value(self), result=Qnil;
    VALUE (*fn)(ANYARGS)=ext->functions[slot];
    sp_Proc *saved=current_block;sp_cext_current_block=block;
    const int roots=sp_gc_nroots;
    jmp_buf frame;
    if(setjmp(frame)!=0) {
        if(sp_cext_unwinding()) {
            sp_exc_disarm();sp_cext_arena_restore(mark);sp_gc_nroots=roots;
            sp_cext_current_block=saved;sp_cext_resume_unwind();abort();
        }
        const char *cls=sp_exc_cur_cls(), *msg=sp_exc_cur_msg();void *obj=sp_exc_cur_obj();
        sp_exc_disarm();sp_cext_arena_restore(mark);sp_gc_nroots=roots;
        sp_cext_current_block=saved;sp_fiber_reraise(cls,msg,obj);abort();
    }
    sp_exc_arm(frame);
    if(arity>=0 && argc!=arity) { rb_raise(rb_eArgError,"wrong number of arguments (given %d, expected %d)",argc,arity); }
    if(arity==-1)result=((VALUE (*)(int,VALUE *,VALUE))fn)(argc,argv,recv);
    else if(arity==-2)result=((VALUE (*)(VALUE,VALUE))fn)(recv,sp_cext_value(sp_box_poly_array(args)));
    else switch(arity) {
    case 0: result=((VALUE (*)(VALUE))fn)(recv);break;
    case 1: result=((VALUE (*)(VALUE, VALUE))fn)(recv, argv[0]);break;
    case 2: result=((VALUE (*)(VALUE, VALUE, VALUE))fn)(recv, argv[0], argv[1]);break;
    case 3: result=((VALUE (*)(VALUE, VALUE, VALUE, VALUE))fn)(recv, argv[0], argv[1], argv[2]);break;
    case 4: result=((VALUE (*)(VALUE, VALUE, VALUE, VALUE, VALUE))fn)(recv, argv[0], argv[1], argv[2], argv[3]);break;
    case 5: result=((VALUE (*)(VALUE, VALUE, VALUE, VALUE, VALUE, VALUE))fn)(recv, argv[0], argv[1], argv[2], argv[3], argv[4]);break;
    case 6: result=((VALUE (*)(VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE))fn)(recv, argv[0], argv[1], argv[2], argv[3], argv[4], argv[5]);break;
    case 7: result=((VALUE (*)(VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE))fn)(recv, argv[0], argv[1], argv[2], argv[3], argv[4], argv[5], argv[6]);break;
    case 8: result=((VALUE (*)(VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE))fn)(recv, argv[0], argv[1], argv[2], argv[3], argv[4], argv[5], argv[6], argv[7]);break;
    case 9: result=((VALUE (*)(VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE))fn)(recv, argv[0], argv[1], argv[2], argv[3], argv[4], argv[5], argv[6], argv[7], argv[8]);break;
    case 10: result=((VALUE (*)(VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE))fn)(recv, argv[0], argv[1], argv[2], argv[3], argv[4], argv[5], argv[6], argv[7], argv[8], argv[9]);break;
    case 11: result=((VALUE (*)(VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE))fn)(recv, argv[0], argv[1], argv[2], argv[3], argv[4], argv[5], argv[6], argv[7], argv[8], argv[9], argv[10]);break;
    case 12: result=((VALUE (*)(VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE))fn)(recv, argv[0], argv[1], argv[2], argv[3], argv[4], argv[5], argv[6], argv[7], argv[8], argv[9], argv[10], argv[11]);break;
    case 13: result=((VALUE (*)(VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE))fn)(recv, argv[0], argv[1], argv[2], argv[3], argv[4], argv[5], argv[6], argv[7], argv[8], argv[9], argv[10], argv[11], argv[12]);break;
    case 14: result=((VALUE (*)(VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE))fn)(recv, argv[0], argv[1], argv[2], argv[3], argv[4], argv[5], argv[6], argv[7], argv[8], argv[9], argv[10], argv[11], argv[12], argv[13]);break;
    case 15: result=((VALUE (*)(VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE, VALUE))fn)(recv, argv[0], argv[1], argv[2], argv[3], argv[4], argv[5], argv[6], argv[7], argv[8], argv[9], argv[10], argv[11], argv[12], argv[13], argv[14]);break;
    default: rb_raise(rb_eArgError,"unsupported C method arity");
    }
    sp_exc_disarm();sp_cext_current_block=saved;
    sp_RbVal value=sp_cext_rbval(result);
    sp_cext_arena_restore(mark);return value;
}
#endif
