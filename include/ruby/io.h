#ifndef SPINEL_RUBY_IO_H
#define SPINEL_RUBY_IO_H
#include <ruby.h>
/* Deliberately contains no CRuby FILE*, buffers, or encoding state. */
typedef struct { int fd; int mode; } rb_io_t;
#define FPTR_TO_FD(fptr) ((fptr)->fd)
#endif
