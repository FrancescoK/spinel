/* A pure-C host over an ext-init library with at_exit hooks: they run after
   main returns, the last registered first, and the host's status stands. */
#include <stdio.h>
#include "a.h"

int main(void) {
  Init_ext_at_exit();
  fprintf(stderr, "init returned\n");
  fprintf(stderr, "%lld\n", (long long)sp_ExtAtExit_s_go(41LL));
  fprintf(stderr, "main returns\n");
  return 3;
}
