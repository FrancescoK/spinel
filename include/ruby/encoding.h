#ifndef SPINEL_RUBY_ENCODING_H
#define SPINEL_RUBY_ENCODING_H
#include <ruby.h>
/* Encoding operations arrive with the runtime API; no CRuby layout leaks. */
typedef struct sp_cext_encoding rb_encoding;
enum { ENC_CODERANGE_UNKNOWN = 0, ENC_CODERANGE_7BIT = 1,
       ENC_CODERANGE_VALID = 2, ENC_CODERANGE_BROKEN = 3 };
rb_encoding *rb_ascii8bit_encoding(void);
VALUE rb_enc_associate(VALUE, rb_encoding *);
int rb_enc_str_coderange(VALUE);
VALUE rb_utf8_str_new(const char *, long);
#endif
