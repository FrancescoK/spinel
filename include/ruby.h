/* Restricted source API for Spinel extensions. This is not the CRuby ABI. */
#ifndef SPINEL_RUBY_H
#define SPINEL_RUBY_H

/* What CRuby's ruby.h brings in for every extension, ahead of any system
   header as its config.h does: the GNU / Darwin feature macros, so a
   -std=c11 build still declares clock_gettime and getpid, and <time.h>,
   <unistd.h>, bool and rb_pid_t (sqlite3 keeps a struct timespec deadline
   and the pid that opened the database) */
#ifndef _GNU_SOURCE
#define _GNU_SOURCE 1
#endif
#ifndef _DARWIN_C_SOURCE
#define _DARWIN_C_SOURCE 1
#endif
#include <stdint.h>
#include <inttypes.h>
#include <stddef.h>
#include <limits.h>
#include <stdbool.h>
#include <time.h>
#include <sys/types.h>
#ifndef _WIN32
#include <unistd.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef uintptr_t VALUE;
typedef uintptr_t ID;
typedef intptr_t SIGNED_VALUE;
typedef pid_t rb_pid_t;

/* config.h's helper for a -D value an extension prints (racc's
   RACC_INFO_VERSION) */
#define STRINGIZE(expr) STRINGIZE0(expr)
#define STRINGIZE0(expr) #expr
/* "%"PRIsVALUE in an rb_raise format takes a VALUE and prints its to_s, or
   its inspect with the + flag, as CRuby's does */
#define PRI_VALUE_PREFIX "l"
#define RUBY_PRI_VALUE_MARK "\v"
#define PRIsVALUE PRIiPTR RUBY_PRI_VALUE_MARK

#define Qfalse ((VALUE)0x00)
#define Qnil   ((VALUE)0x08)
#define Qtrue  ((VALUE)0x14)
#define Qundef ((VALUE)0x34)
#define RUBY_Qfalse Qfalse
#define RUBY_Qnil Qnil
#define RUBY_Qtrue Qtrue
#define RUBY_Qundef Qundef
#define USE_FLONUM 0
#define RUBY_FIXNUM_FLAG ((VALUE)1)
#define RUBY_SYMBOL_FLAG ((VALUE)0x0c)
#define RUBY_SPECIAL_SHIFT 8
#define RUBY_FIXNUM_MAX (INTPTR_MAX / 2)
#define RUBY_FIXNUM_MIN (INTPTR_MIN / 2)

#define NIL_P(v) ((VALUE)(v) == Qnil)
#define RTEST(v) (((VALUE)(v) & ~(VALUE)Qnil) != Qfalse)
#define FIXNUM_P(v) (((VALUE)(v) & RUBY_FIXNUM_FLAG) != 0)
#define SYMBOL_P(v) (((VALUE)(v) & (VALUE)0xff) == RUBY_SYMBOL_FLAG)
static inline int sp_cext_flonum_p(VALUE v) { (void)v; return 0; }
static inline int sp_cext_special_const_p(VALUE v) {
    return FIXNUM_P(v) || SYMBOL_P(v) || v == Qfalse || v == Qnil || v == Qtrue || v == Qundef;
}
#define FLONUM_P(v) sp_cext_flonum_p((VALUE)(v))
#define SPECIAL_CONST_P(v) sp_cext_special_const_p((VALUE)(v))
#define RB_NIL_P NIL_P
#define RB_TEST RTEST
#define RB_FIXNUM_P FIXNUM_P
#define RB_SYMBOL_P SYMBOL_P
#define RB_FLONUM_P FLONUM_P
#define RB_SPECIAL_CONST_P SPECIAL_CONST_P

/* Unsigned shifting avoids undefined behaviour for negative integers. Decode
 * without an implementation-defined unsigned-to-signed conversion or shift. */
static inline VALUE sp_cext_int2fix(SIGNED_VALUE n) {
    return ((VALUE)n << 1) | RUBY_FIXNUM_FLAG;
}
static inline SIGNED_VALUE sp_cext_fix2long(VALUE v) {
    VALUE magnitude = v >> 1;
    return (v & ((VALUE)1 << (sizeof(VALUE) * CHAR_BIT - 1)))
        ? -1 - (SIGNED_VALUE)(~magnitude & (VALUE)INTPTR_MAX)
        : (SIGNED_VALUE)magnitude;
}
#define INT2FIX(n) sp_cext_int2fix((SIGNED_VALUE)(n))
#define LONG2FIX INT2FIX
#define FIX2LONG(v) sp_cext_fix2long((VALUE)(v))
#define FIX2INT(v) ((int)FIX2LONG(v))
int rb_num2int(VALUE);
VALUE rb_ll2inum(long long);
VALUE rb_float_new(double);
#define NUM2INT(v) rb_num2int((VALUE)(v))
#define LL2NUM(v) rb_ll2inum((long long)(v))
long rb_num2long(VALUE);
#define NUM2LONG(v) rb_num2long((VALUE)(v))
#define INT2NUM(v) LL2NUM((int)(v))
#define LONG2NUM(v) LL2NUM((long)(v))
#define DBL2NUM(v) rb_float_new((double)(v))
#define ID2SYM(id) (((VALUE)(id) << RUBY_SPECIAL_SHIFT) | RUBY_SYMBOL_FLAG)
#ifdef SP_CEXT_RECORDER
/* Keep this ID-producing operation visible in preprocessed extension source. */
ID sp_cext_scanned_sym2id(VALUE);
#define SYM2ID(v) sp_cext_scanned_sym2id((v))
#else
#define SYM2ID(v) ((ID)((VALUE)(v) >> RUBY_SPECIAL_SHIFT))
#endif
#define RB_GC_GUARD(v) (v)
#define RUBY_FUNC_EXPORTED
void ruby_xfree(void *);
#define xfree ruby_xfree
void *sp_cext_allocv(VALUE *, size_t, size_t);
#define RB_ALLOCV_N(type,handle,count) ((type *)sp_cext_allocv(&(handle),sizeof(type),(size_t)(count)))
/* CRuby's value_type.h numbers */
enum { T_NONE = 0x00, T_OBJECT = 0x01, T_CLASS = 0x02, T_MODULE = 0x03, T_FLOAT = 0x04,
       T_STRING = 0x05, T_REGEXP = 0x06, T_ARRAY = 0x07, T_HASH = 0x08, T_STRUCT = 0x09,
       T_BIGNUM = 0x0a, T_FILE = 0x0b, T_DATA = 0x0c, T_MATCH = 0x0d, T_COMPLEX = 0x0e,
       T_RATIONAL = 0x0f, T_NIL = 0x11, T_TRUE = 0x12, T_FALSE = 0x13, T_SYMBOL = 0x14,
       T_FIXNUM = 0x15, T_UNDEF = 0x16 };
int rb_type(VALUE);
#define TYPE(v) rb_type((VALUE)(v))
#define RB_TYPE_P(v,t) (rb_type((VALUE)(v)) == (t))
VALUE rb_obj_class(VALUE);
const char *rb_class2name(VALUE);
void rb_check_type(VALUE, int);
#define Check_Type(value,type) rb_check_type((VALUE)(value),(type))

void rb_gc_mark(VALUE);
void rb_gc_mark_movable(VALUE);
VALUE rb_gc_location(VALUE);
void rb_gc_register_address(VALUE *);
void rb_gc_unregister_address(VALUE *);
void rb_global_variable(VALUE *);

typedef void (*RUBY_DATA_FUNC)(void *);
typedef struct rb_data_type_struct {
    const char *wrap_struct_name;
    struct {
        RUBY_DATA_FUNC dmark;
        RUBY_DATA_FUNC dfree;
        size_t (*dsize)(const void *);
        RUBY_DATA_FUNC dcompact;
        void *reserved[1];
    } function;
    const struct rb_data_type_struct *parent;
    void *data;
    VALUE flags;
} rb_data_type_t;
#define RUBY_TYPED_DEFAULT_FREE ((RUBY_DATA_FUNC)-1)
#define RUBY_TYPED_NEVER_FREE ((RUBY_DATA_FUNC)0)
#define RUBY_TYPED_FREE_IMMEDIATELY ((VALUE)1)
#define RUBY_TYPED_WB_PROTECTED ((VALUE)32)

VALUE rb_data_typed_object_wrap(VALUE, void *, const rb_data_type_t *);
void *rb_data_typed_object_zalloc(VALUE, size_t, const rb_data_type_t *, VALUE *);
void *rb_check_typeddata(VALUE, const rb_data_type_t *);
void *sp_cext_data_ptr(VALUE);
const rb_data_type_t *sp_cext_data_type(VALUE);
#define TypedData_Wrap_Struct(k,t,p) rb_data_typed_object_wrap((k),(p),(t))
#define TypedData_Make_Struct(k,T,t,p) ({ VALUE _v; (p)=(T *)rb_data_typed_object_zalloc((k),sizeof(T),(t),&_v); _v; })
#define TypedData_Get_Struct(v,T,t,p) ((p)=(T *)rb_check_typeddata((v),(t)))
#define DATA_PTR(v) sp_cext_data_ptr(v)
#define RTYPEDDATA_TYPE(v) sp_cext_data_type(v)
char *sp_cext_string_ptr(VALUE);
long sp_cext_string_len(VALUE);
#define RSTRING_PTR(v) sp_cext_string_ptr(v)
#define RSTRING_LEN(v) sp_cext_string_len(v)
char *sp_cext_string_cstr(VALUE);
#define StringValuePtr(v) sp_cext_string_ptr((v))
#define StringValueCStr(v) sp_cext_string_cstr((v))
VALUE rb_str_cat(VALUE, const char *, long);
VALUE rb_str_cat_cstr(VALUE, const char *);
int rb_block_given_p(void);
VALUE rb_block_proc(void);
VALUE rb_yield(VALUE);
VALUE rb_yield_values(int, ...);
VALUE rb_yield_values2(int, const VALUE *);
void rb_gc_start(void);

VALUE rb_ary_new(void);
VALUE rb_hash_new(void);
VALUE rb_hash_new_capa(long);
VALUE rb_hash_aset(VALUE, VALUE, VALUE);
VALUE rb_ary_new_capa(long);
#define rb_ary_new2 rb_ary_new_capa
VALUE rb_ary_subseq(VALUE, long, long);
VALUE rb_hash_aref(VALUE, VALUE);
VALUE rb_ary_push(VALUE, VALUE);
VALUE rb_ary_pop(VALUE);
void rb_ary_store(VALUE, long, VALUE);
VALUE rb_ary_entry(VALUE, long);
long sp_cext_array_len(VALUE);
#define RARRAY_LEN(v) sp_cext_array_len(v)
#define RARRAY_AREF(v,i) rb_ary_entry((v),(i))

extern VALUE rb_eException, rb_eStandardError, rb_eRuntimeError, rb_eTypeError;
extern VALUE rb_eArgError, rb_eRangeError, rb_eNoMemError, rb_eSystemCallError;
VALUE rb_protect(VALUE (*)(VALUE), VALUE, int *);
VALUE rb_ensure(VALUE (*)(VALUE), VALUE, VALUE (*)(VALUE), VALUE);
VALUE rb_rescue(VALUE (*)(VALUE), VALUE, VALUE (*)(VALUE, VALUE), VALUE);
VALUE rb_rescue2(VALUE (*)(VALUE), VALUE, VALUE (*)(VALUE, VALUE), VALUE, ...);
VALUE rb_exc_new(VALUE, const char *, long);
VALUE rb_exc_new_cstr(VALUE, const char *);
#define rb_exc_new2 rb_exc_new_cstr
VALUE rb_errinfo(void);
void rb_set_errinfo(VALUE);
#if defined(__GNUC__) || defined(__clang__)
#define SP_CEXT_NORETURN __attribute__((noreturn))
#else
#define SP_CEXT_NORETURN
#endif
void rb_raise(VALUE, const char *, ...) SP_CEXT_NORETURN;
void rb_exc_raise(VALUE) SP_CEXT_NORETURN;
void rb_jump_tag(int);
void rb_sys_fail(const char *) SP_CEXT_NORETURN;
void rb_bug(const char *, ...) SP_CEXT_NORETURN;
void rb_fatal(const char *, ...) SP_CEXT_NORETURN;

/* APIs requiring CRuby's layout or VM are deliberately diagnosed at the
 * call site. No dummy layout or unresolved linker symbol is supplied. */
#if defined(__GNUC__) || defined(__clang__)
#define SP_CEXT_REFUSED(reason) __attribute__((error(reason)))
#else
#define SP_CEXT_REFUSED(reason)
#endif
void *sp_cext_no_layout(VALUE) SP_CEXT_REFUSED("CRuby object layout is not provided by Spinel's C extension layer");
#define RBASIC(v) sp_cext_no_layout(v)
#define ROBJECT(v) sp_cext_no_layout(v)
#define RSTRUCT(v) sp_cext_no_layout(v)
#if defined(SP_CEXT_RECORDER) || defined(SP_CEXT)
#include "ruby/spinel_record.h"
#else
VALUE rb_eval_string(const char *) SP_CEXT_REFUSED("Ruby eval requires the C extension literal scanner");
#endif

#ifdef __cplusplus
}
#endif
#endif
