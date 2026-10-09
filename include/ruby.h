/* Restricted source API for Spinel extensions. This is not the CRuby ABI. */
#ifndef SPINEL_RUBY_H
#define SPINEL_RUBY_H

#include <stdint.h>
#include <stddef.h>
#include <limits.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef uintptr_t VALUE;
typedef uintptr_t ID;
typedef intptr_t SIGNED_VALUE;

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
#define FLONUM_P(v) 0
#define SPECIAL_CONST_P(v) (FIXNUM_P(v) || SYMBOL_P(v) || (VALUE)(v) == Qfalse || (VALUE)(v) == Qnil || (VALUE)(v) == Qtrue || (VALUE)(v) == Qundef)
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
#define ID2SYM(id) (((VALUE)(id) << RUBY_SPECIAL_SHIFT) | RUBY_SYMBOL_FLAG)
#define SYM2ID(v) ((ID)((VALUE)(v) >> RUBY_SPECIAL_SHIFT))
#define RB_GC_GUARD(v) (v)

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
VALUE rb_eval_string(const char *) SP_CEXT_REFUSED("Ruby eval requires the C extension literal scanner");

#ifdef __cplusplus
}
#endif
#endif
