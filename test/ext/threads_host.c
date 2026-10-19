/* A pure-C host over an ext-init library that spawns threads: each entry
   starts and joins its own, after an init that already started some. */
#include <stdio.h>
#include "t.h"

int main(void) {
  Init_ext_threads();
  printf("%lld\n", (long long)sp_ExtThreads_s_par(4LL));
  printf("%lld\n", (long long)sp_ExtThreads_s_par(6LL));
  printf("%lld\n", (long long)sp_ExtThreads_s_bg());
  return 0;
}
