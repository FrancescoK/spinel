/* Windows: the UCRT's <locale.h> plus POSIX 2008's per-thread locales,
   which the runtime uses for one thing: formatting a float under the "C"
   locale. The UCRT's numeric formatting is the "C" locale's unless the
   program calls setlocale, so the shim's newlocale answers a token and
   uselocale switches the calling thread to a per-thread locale for the
   duration (_configthreadlocale), which is the same guarantee. */
#ifndef SP_WIN32_LOCALE_H
#define SP_WIN32_LOCALE_H
#include_next <locale.h>
typedef struct sp_w32_locale *locale_t;
#define LC_CTYPE_MASK    (1 << 0)
#define LC_NUMERIC_MASK  (1 << 1)
#define LC_TIME_MASK     (1 << 2)
#define LC_COLLATE_MASK  (1 << 3)
#define LC_MONETARY_MASK (1 << 4)
#define LC_MESSAGES_MASK (1 << 5)
#define LC_ALL_MASK      0x3f
#define LC_GLOBAL_LOCALE ((locale_t)-1)
#ifdef __cplusplus
extern "C" {
#endif
locale_t newlocale(int mask, const char *name, locale_t base);
locale_t uselocale(locale_t loc);
void freelocale(locale_t loc);
locale_t duplocale(locale_t loc);
#ifdef __cplusplus
}
#endif
#endif
