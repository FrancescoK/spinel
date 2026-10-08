/* Windows: address text conversions over winsock's inet_pton / inet_ntop. */
#ifndef SP_WIN32_ARPA_INET_H
#define SP_WIN32_ARPA_INET_H
#include <netinet/in.h>
#ifdef __cplusplus
extern "C" {
#endif
int sp_w32_inet_pton(int af, const char *src, void *dst);
const char *sp_w32_inet_ntop(int af, const void *src, char *dst, socklen_t size);
in_addr_t sp_w32_inet_addr(const char *cp);
char *sp_w32_inet_ntoa(struct in_addr in);
int sp_w32_inet_aton(const char *cp, struct in_addr *in);
#define inet_pton(af, s, d)     sp_w32_inet_pton((af), (s), (d))
#define inet_ntop(af, s, d, n)  sp_w32_inet_ntop((af), (s), (d), (n))
#define inet_addr(cp)           sp_w32_inet_addr(cp)
#define inet_ntoa(in)           sp_w32_inet_ntoa(in)
#define inet_aton(cp, in)       sp_w32_inet_aton((cp), (in))
#ifdef __cplusplus
}
#endif
#endif
