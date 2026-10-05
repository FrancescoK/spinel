/* Windows: name resolution over winsock. struct addrinfo is winsock's
   ADDRINFOA, field for field (its ai_canonname precedes ai_addr, unlike
   glibc's; code that names the fields does not notice), so getaddrinfo's
   list is handed over as winsock built it. The EAI_ codes are winsock's. */
#ifndef SP_WIN32_NETDB_H
#define SP_WIN32_NETDB_H
#include <sys/socket.h>
#include <netinet/in.h>

struct addrinfo {
  int ai_flags, ai_family, ai_socktype, ai_protocol;
  size_t ai_addrlen;
  char *ai_canonname;
  struct sockaddr *ai_addr;
  struct addrinfo *ai_next;
};
struct hostent {
  char *h_name; char **h_aliases;
  short h_addrtype, h_length;
  char **h_addr_list;
};
#define h_addr h_addr_list[0]

#define AI_PASSIVE     0x0001
#define AI_CANONNAME   0x0002
#define AI_NUMERICHOST 0x0004
#define AI_NUMERICSERV 0x0008
#define AI_ALL         0x0100
#define AI_ADDRCONFIG  0x0400
#define AI_V4MAPPED    0x0800

#define NI_NOFQDN      0x01
#define NI_NUMERICHOST 0x02
#define NI_NAMEREQD    0x04
#define NI_NUMERICSERV 0x08
#define NI_DGRAM       0x10
#define NI_MAXHOST     1025
#define NI_MAXSERV     32

#define EAI_AGAIN    11002
#define EAI_BADFLAGS 10022
#define EAI_FAIL     11003
#define EAI_FAMILY   10047
#define EAI_MEMORY   8
#define EAI_NONAME   11001
#define EAI_NODATA   EAI_NONAME
#define EAI_SERVICE  10109
#define EAI_SOCKTYPE 10044
#define EAI_SYSTEM   (-11)
#define EAI_OVERFLOW (-12)

#ifdef __cplusplus
extern "C" {
#endif
int sp_w32_getaddrinfo(const char *node, const char *service, const struct addrinfo *hints, struct addrinfo **res);
void sp_w32_freeaddrinfo(struct addrinfo *ai);
const char *sp_w32_gai_strerror(int code);
int sp_w32_getnameinfo(const struct sockaddr *sa, socklen_t salen, char *host, socklen_t hostlen,
                       char *serv, socklen_t servlen, int flags);
struct hostent *sp_w32_gethostbyname(const char *name);
#define getaddrinfo(n, s, h, r) sp_w32_getaddrinfo((n), (s), (h), (r))
#define freeaddrinfo(ai)        sp_w32_freeaddrinfo(ai)
#define gai_strerror(c)         sp_w32_gai_strerror(c)
#define getnameinfo(sa, sl, h, hl, s, svl, f) sp_w32_getnameinfo((sa), (sl), (h), (hl), (s), (svl), (f))
#define gethostbyname(n)        sp_w32_gethostbyname(n)
#ifdef __cplusplus
}
#endif
#endif
