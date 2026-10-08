/* Windows: the UCRT's <errno.h> plus the POSIX numbers it has no name for,
   numbered past its own (the highest is EWOULDBLOCK, 140). */
#ifndef SP_WIN32_ERRNO_H
#define SP_WIN32_ERRNO_H
#include_next <errno.h>
/* POSIX lets these pairs share a number, and Linux and macOS do: code that
   tests one of a pair for a would-block or an unsupported operation sees
   the other too. The UCRT numbers each separately. */
#undef EWOULDBLOCK
#define EWOULDBLOCK EAGAIN
#undef EOPNOTSUPP
#define EOPNOTSUPP ENOTSUP
#ifndef ESTALE
#define ESTALE   151
#endif
#ifndef EDQUOT
#define EDQUOT   152
#endif
#ifndef ENOTBLK
#define ENOTBLK  153
#endif
#ifndef EUSERS
#define EUSERS   154
#endif
#ifndef ESHUTDOWN
#define ESHUTDOWN 155
#endif
#ifndef ETOOMANYREFS
#define ETOOMANYREFS 156
#endif
#ifndef EHOSTDOWN
#define EHOSTDOWN 157
#endif
#ifndef EPFNOSUPPORT
#define EPFNOSUPPORT 158
#endif
#ifndef ESOCKTNOSUPPORT
#define ESOCKTNOSUPPORT 159
#endif
#ifndef EREMOTE
#define EREMOTE 160
#endif
#ifndef EPROCLIM
#define EPROCLIM 161
#endif
#ifndef EMULTIHOP
#define EMULTIHOP 162
#endif
#ifndef ENOMEDIUM
#define ENOMEDIUM 163
#endif
#endif
