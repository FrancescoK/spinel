/* Windows: dlopen and friends over LoadLibrary / GetProcAddress. dlopen(NULL)
   answers the program itself; dlsym on it also searches the C runtime, as a
   POSIX global namespace would. */
#ifndef SP_WIN32_DLFCN_H
#define SP_WIN32_DLFCN_H
#define RTLD_LAZY   0x1
#define RTLD_NOW    0x2
#define RTLD_GLOBAL 0x100
#define RTLD_LOCAL  0x0
#define RTLD_DEFAULT ((void *)0)
#ifdef __cplusplus
extern "C" {
#endif
void *dlopen(const char *file, int mode);
void *dlsym(void *handle, const char *name);
int dlclose(void *handle);
char *dlerror(void);
#ifdef __cplusplus
}
#endif
#endif
