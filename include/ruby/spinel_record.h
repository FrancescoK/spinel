/* Declaration and literal-dispatch API shared by the build-time recorder
 * and the opted-in compiler bridge. */
#ifndef SPINEL_RECORD_H
#define SPINEL_RECORD_H
#ifndef ANYARGS
#ifdef __cplusplus
#define ANYARGS ...
#else
#define ANYARGS
#endif
#endif
#define RUBY_METHOD_FUNC(f) ((VALUE (*)(ANYARGS))(f))
extern VALUE rb_cObject, rb_cBasicObject, rb_cClass, rb_cModule;
extern VALUE rb_cString, rb_cArray, rb_cHash, rb_cInteger, rb_cFloat, rb_cIO;
VALUE rb_define_class(const char *, VALUE);
VALUE rb_define_class_under(VALUE, const char *, VALUE);
VALUE rb_define_module(const char *);
VALUE rb_define_module_under(VALUE, const char *);
void rb_define_method(VALUE, const char *, VALUE (*)(ANYARGS), int);
void rb_define_private_method(VALUE, const char *, VALUE (*)(ANYARGS), int);
void rb_define_singleton_method(VALUE, const char *, VALUE (*)(ANYARGS), int);
void rb_define_module_function(VALUE, const char *, VALUE (*)(ANYARGS), int);
void rb_define_alloc_func(VALUE, VALUE (*)(VALUE));
void rb_define_const(VALUE, const char *, VALUE);
void rb_define_alias(VALUE, const char *, const char *);
void rb_define_attr(VALUE, const char *, int, int);
void rb_include_module(VALUE, VALUE);
void rb_extend_object(VALUE, VALUE);
ID rb_intern(const char *);
ID rb_intern2(const char *, long);
#define rb_intern_const rb_intern
const char *rb_id2name(ID);
VALUE rb_str_new(const char *, long);
VALUE rb_str_new_cstr(const char *);
#define rb_str_new2 rb_str_new_cstr
VALUE rb_str_freeze(VALUE);
VALUE rb_str_intern(VALUE);
VALUE rb_funcall(VALUE, ID, int, ...);
VALUE rb_funcallv(VALUE, ID, int, const VALUE *);
#define RB_BLOCK_CALL_FUNC_ARGLIST(yielded, data) VALUE yielded, VALUE data, int argc, const VALUE *argv, VALUE blockarg
typedef VALUE (*rb_block_call_func_t)(VALUE, VALUE, int, const VALUE *, VALUE);
VALUE rb_block_call(VALUE, ID, int, const VALUE *, rb_block_call_func_t, VALUE);
VALUE rb_iv_get(VALUE, const char *);
VALUE rb_iv_set(VALUE, const char *, VALUE);
VALUE rb_ivar_get(VALUE, ID);
VALUE rb_ivar_set(VALUE, ID, VALUE);
VALUE rb_const_get(VALUE, ID);
VALUE rb_eval_string(const char *);
#endif
