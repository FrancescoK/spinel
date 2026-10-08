/* Windows: the musl/Solaris <stdio_ext.h> call the runtime uses -- how many
   bytes a read stream holds in its buffer -- answered from the UCRT's own
   stream pointers. */
#ifndef SP_WIN32_STDIO_EXT_H
#define SP_WIN32_STDIO_EXT_H
#include <stdio.h>
#ifdef __cplusplus
extern "C" {
#endif
size_t __freadahead(FILE *f);
size_t __fpending(FILE *f);
void __fpurge(FILE *f);
#ifdef __cplusplus
}
#endif
#endif
