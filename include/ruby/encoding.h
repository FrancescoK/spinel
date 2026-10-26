#ifndef SPINEL_RUBY_ENCODING_H
#define SPINEL_RUBY_ENCODING_H
#include <ruby.h>
/* Encoding operations arrive with the runtime API; no CRuby layout leaks. */
typedef struct sp_cext_encoding rb_encoding;
enum { ENC_CODERANGE_UNKNOWN = 0, ENC_CODERANGE_7BIT = 1,
       ENC_CODERANGE_VALID = 2, ENC_CODERANGE_BROKEN = 3 };
rb_encoding *rb_ascii8bit_encoding(void);
rb_encoding *rb_utf8_encoding(void);
rb_encoding *rb_usascii_encoding(void);
/* CRuby's indexes of the three encodings a Spinel String can carry: a String
 * is ASCII-8BIT or UTF-8; US-ASCII is an encoding no String answers with */
int rb_ascii8bit_encindex(void);
int rb_utf8_encindex(void);
int rb_usascii_encindex(void);
int rb_enc_get_index(VALUE);
rb_encoding *rb_enc_get(VALUE);
int rb_enc_find_index(const char *);
rb_encoding *rb_enc_from_index(int);
int rb_enc_to_index(rb_encoding *);
VALUE rb_enc_from_encoding(rb_encoding *);
VALUE rb_enc_associate(VALUE, rb_encoding *);
VALUE rb_enc_associate_index(VALUE, int);
int rb_enc_str_coderange(VALUE);
VALUE rb_utf8_str_new(const char *, long);
VALUE rb_utf8_str_new_cstr(const char *);
VALUE rb_enc_interned_str_cstr(const char *, rb_encoding *);
VALUE rb_str_encode(VALUE, VALUE, int, VALUE);
VALUE rb_str_export_to_enc(VALUE, rb_encoding *);
rb_encoding *rb_default_internal_encoding(void);
#endif
