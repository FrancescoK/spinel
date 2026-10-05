/* Windows: no <sys/ioctl.h>. ioctl answers the two requests the runtime
   makes: TIOCGWINSZ (the console's window) and FIONREAD (bytes waiting on a
   pipe or a socket); FIONBIO sets a socket's blocking mode. */
#ifndef SP_WIN32_SYS_IOCTL_H
#define SP_WIN32_SYS_IOCTL_H
struct winsize { unsigned short ws_row, ws_col, ws_xpixel, ws_ypixel; };
#define TIOCGWINSZ 0x5413
#define TIOCSWINSZ 0x5414
#ifndef FIONREAD
#define FIONREAD   0x4004667f
#endif
#ifndef FIONBIO
#define FIONBIO    0x8004667e
#endif
#ifdef __cplusplus
extern "C" {
#endif
int ioctl(int fd, unsigned long req, ...);
#ifdef __cplusplus
}
#endif
#endif
