/* Windows: the TCP options winsock has (ws2ipdef.h / mstcpip.h). */
#ifndef SP_WIN32_NETINET_TCP_H
#define SP_WIN32_NETINET_TCP_H
#define TCP_NODELAY   1
#define TCP_MAXSEG    4
#define TCP_KEEPIDLE  3
#define TCP_KEEPCNT   16
#define TCP_KEEPINTVL 17
#define TCP_FASTOPEN  15
#endif
