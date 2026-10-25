# An ffi_source fragment that calls an ffi_func by its C name without
# declaring it. The ffi_func's extern is under a private name bound to the
# symbol by an asm label, so nothing declares `lfind` here (<search.h> is not
# included), and C took the call to return int: the pointer lost its upper
# half and the offset came out as -4294967294 instead of 2. The build is
# refused instead (reject-test builds it and expects cc to name the call).
module Probe
  ffi_func :lfind, %i[ptr ptr ptr size_t ptr], :ptr
  ffi_source <<~C
    #include <stddef.h>
    static int probe_cmp(const void *a, const void *b) { return *(const char *)a != *(const char *)b; }
    long probe_find(const char *s) {
      size_t n = 5; char key = 'l';
      const char *hit = (const char *)lfind(&key, s, &n, 1, probe_cmp);
      return hit ? (long)(hit - s) : -1;
    }
  C
  ffi_func :probe_find, [:str], :long
end

puts Probe.probe_find("hello")
