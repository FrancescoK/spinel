/* spinel-timeout for native Windows: what scripts/spinel-timeout.c does
 * with fork, exec and SIGALRM, done with CreateProcess and a timed wait.
 *
 * Usage: spinel-timeout SECONDS COMMAND [ARG...]
 *
 * The command runs on this process's standard handles; one that runs past
 * SECONDS is terminated and the wrapper answers 124, as GNU timeout does,
 * otherwise the command's own exit status. win32.mk builds this in place of
 * scripts/spinel-timeout.c. */
/* Arguments are re-quoted the way the MSVC runtime splits a command line,
   and a program named without an extension is the .exe beside the name
   (MSYS hands over a path the C compiler gave a .exe to without one). */
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <wchar.h>

static void quote_arg(wchar_t *out, size_t *len, const wchar_t *a) {
  if (*len) out[(*len)++] = L' ';
  if (*a && !wcspbrk(a, L" \t\n\v\"")) { while (*a) out[(*len)++] = *a++; return; }
  out[(*len)++] = L'"';
  for (;;) {
    size_t bs = 0;
    while (*a == L'\\') { a++; bs++; }
    if (!*a) { while (bs--) { out[(*len)++] = L'\\'; out[(*len)++] = L'\\'; } break; }
    if (*a == L'"') { for (size_t i = 0; i < bs * 2 + 1; i++) out[(*len)++] = L'\\'; out[(*len)++] = L'"'; }
    else { while (bs--) out[(*len)++] = L'\\'; out[(*len)++] = *a; }
    a++;
  }
  out[(*len)++] = L'"';
}

int wmain(int argc, wchar_t **argv) {
  if (argc < 3) {
    fputs("usage: spinel-timeout SECONDS COMMAND [ARG...]\n", stderr);
    return 2;
  }
  long secs = wcstol(argv[1], NULL, 10);
  if (secs <= 0) secs = 1;
  size_t cap = 64;
  for (int i = 2; i < argc; i++) cap += wcslen(argv[i]) * 2 + 3;
  wchar_t *cmd = (wchar_t *)malloc(sizeof(wchar_t) * cap);
  size_t len = 0;
  for (int i = 2; i < argc; i++) quote_arg(cmd, &len, argv[i]);
  cmd[len] = 0;
  wchar_t app[32768];
  const wchar_t *appp = NULL;
  if (wcschr(argv[2], L'\\') || wcschr(argv[2], L'/')) {
    DWORD a = GetFileAttributesW(argv[2]);
    if (a == INVALID_FILE_ATTRIBUTES || (a & FILE_ATTRIBUTE_DIRECTORY)) {
      _snwprintf(app, 32768, L"%ls.exe", argv[2]); app[32767] = 0;
      appp = app;
    } else appp = argv[2];
  }
  STARTUPINFOW si; memset(&si, 0, sizeof si);
  si.cb = sizeof si;
  PROCESS_INFORMATION pi;
  if (!CreateProcessW(appp, cmd, NULL, NULL, TRUE, 0, NULL, NULL, &si, &pi)) {
    fprintf(stderr, "spinel-timeout: cannot run %ls (error %lu)\n", argv[2], GetLastError());
    return 127;
  }
  CloseHandle(pi.hThread);
  DWORD w = WaitForSingleObject(pi.hProcess, (DWORD)secs * 1000);
  if (w == WAIT_TIMEOUT) {
    TerminateProcess(pi.hProcess, 124);
    WaitForSingleObject(pi.hProcess, INFINITE);
    return 124;
  }
  DWORD code = 1;
  GetExitCodeProcess(pi.hProcess, &code);
  return (int)code;
}
