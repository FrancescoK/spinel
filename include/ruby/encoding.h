#ifndef SPINEL_RUBY_ENCODING_H
#define SPINEL_RUBY_ENCODING_H
#include <ruby.h>
/* Encoding operations arrive with the runtime API; no CRuby layout leaks. */
typedef struct sp_cext_encoding rb_encoding;
#endif
