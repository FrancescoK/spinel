/* Windows: <netinet/in.h> in winsock's layouts (ws2def.h / ws2ipdef.h). */
#ifndef SP_WIN32_NETINET_IN_H
#define SP_WIN32_NETINET_IN_H
#include <sys/socket.h>
#include <stdint.h>

typedef uint16_t in_port_t;
typedef uint32_t in_addr_t;
struct in_addr { in_addr_t s_addr; };
struct in6_addr { unsigned char s6_addr[16]; };
struct sockaddr_in {
  sa_family_t sin_family;
  in_port_t sin_port;
  struct in_addr sin_addr;
  char sin_zero[8];
};
struct sockaddr_in6 {
  sa_family_t sin6_family;
  in_port_t sin6_port;
  uint32_t sin6_flowinfo;
  struct in6_addr sin6_addr;
  uint32_t sin6_scope_id;
};
struct ip_mreq { struct in_addr imr_multiaddr, imr_interface; };
struct ipv6_mreq { struct in6_addr ipv6mr_multiaddr; unsigned int ipv6mr_interface; };

#define in6addr_any sp_w32_in6addr_any
#define in6addr_loopback sp_w32_in6addr_loopback
extern const struct in6_addr in6addr_any;
extern const struct in6_addr in6addr_loopback;
#define IN6ADDR_ANY_INIT      {{0}}
#define IN6ADDR_LOOPBACK_INIT {{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1}}

#define IPPROTO_IP   0
#define IPPROTO_ICMP 1
#define IPPROTO_IGMP 2
#define IPPROTO_TCP  6
#define IPPROTO_UDP  17
#define IPPROTO_IPV6 41
#define IPPROTO_ICMPV6 58
#define IPPROTO_RAW  255

#define INADDR_ANY       ((in_addr_t)0x00000000)
#define INADDR_LOOPBACK  ((in_addr_t)0x7f000001)
#define INADDR_BROADCAST ((in_addr_t)0xffffffff)
#define INADDR_NONE      ((in_addr_t)0xffffffff)
#define INET_ADDRSTRLEN  22
#define INET6_ADDRSTRLEN 65

#define IP_OPTIONS         1
#define IP_HDRINCL         2
#define IP_TOS             3
#define IP_TTL             4
#define IP_MULTICAST_IF    9
#define IP_MULTICAST_TTL   10
#define IP_MULTICAST_LOOP  11
#define IP_ADD_MEMBERSHIP  12
#define IP_DROP_MEMBERSHIP 13
#define IPV6_UNICAST_HOPS   4
#define IPV6_MULTICAST_IF   9
#define IPV6_MULTICAST_HOPS 10
#define IPV6_MULTICAST_LOOP 11
#define IPV6_JOIN_GROUP     12
#define IPV6_LEAVE_GROUP    13
#define IPV6_ADD_MEMBERSHIP  IPV6_JOIN_GROUP
#define IPV6_DROP_MEMBERSHIP IPV6_LEAVE_GROUP
#define IPV6_V6ONLY         27

#define IN6_IS_ADDR_UNSPECIFIED(a) (sp_w32_in6_is_zero((a)->s6_addr, 16))
#define IN6_IS_ADDR_LOOPBACK(a)    (sp_w32_in6_is_zero((a)->s6_addr, 15) && (a)->s6_addr[15] == 1)
#define IN6_IS_ADDR_V4MAPPED(a)    (sp_w32_in6_is_zero((a)->s6_addr, 10) && (a)->s6_addr[10] == 0xff && (a)->s6_addr[11] == 0xff)
#define IN6_IS_ADDR_LINKLOCAL(a)   ((a)->s6_addr[0] == 0xfe && ((a)->s6_addr[1] & 0xc0) == 0x80)
#define IN6_IS_ADDR_MULTICAST(a)   ((a)->s6_addr[0] == 0xff)
static inline int sp_w32_in6_is_zero(const unsigned char *b, int n) {
  for (int i = 0; i < n; i++) if (b[i]) return 0;
  return 1;
}

static inline uint16_t sp_w32_bswap16(uint16_t x) { return (uint16_t)((x << 8) | (x >> 8)); }
#define htons(x) sp_w32_bswap16((uint16_t)(x))
#define ntohs(x) sp_w32_bswap16((uint16_t)(x))
#define htonl(x) __builtin_bswap32((uint32_t)(x))
#define ntohl(x) __builtin_bswap32((uint32_t)(x))
#endif
