/* Windows: no <fnmatch.h>; fnmatch(3) as glibc defines it, flags included
   (sp_win32.c). */
#ifndef SP_WIN32_FNMATCH_H
#define SP_WIN32_FNMATCH_H
#define FNM_NOMATCH     1
#define FNM_NOESCAPE    0x01
#define FNM_PATHNAME    0x02
#define FNM_PERIOD      0x04
#define FNM_LEADING_DIR 0x08
#define FNM_CASEFOLD    0x10
#define FNM_EXTMATCH    0x20
#define FNM_FILE_NAME   FNM_PATHNAME
#define FNM_IGNORECASE  FNM_CASEFOLD
#ifdef __cplusplus
extern "C" {
#endif
int fnmatch(const char *pattern, const char *string, int flags);
#ifdef __cplusplus
}
#endif
#endif
