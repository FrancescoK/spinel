# spinel: not-cruby -- ffi_func and ffi_callback are Spinel's own.
# A String argument a C function is handed is often a fresh copy (`s + "b"`,
# or the copy of a String shared with another name), held by nothing but
# the call. When the C function can run Ruby code -- an ffi_callback handed
# to this call or stored by an earlier one -- that code can collect the copy
# while C still reads it. Such a call roots its String arguments for the
# call, the variadic ones too. Each callback here allocates enough to collect.
module Hook
  ffi_source <<~C
    #include <stdarg.h>
    #include <string.h>
    typedef void (*hook_fn)(void);
    static hook_fn hook_cb;
    void hook_set(hook_fn f) { hook_cb = f; }
    long hook_then_len(const char *s) { hook_cb(); return (long)strlen(s); }
    long call_then_len(const char *s, hook_fn f) { f(); return (long)strlen(s); }
    long vhook_then_len(int n, ...) {
      va_list ap; long t = 0;
      hook_cb();
      va_start(ap, n);
      for (int i = 0; i < n; i++) t += (long)strlen(va_arg(ap, const char *));
      va_end(ap);
      return t;
    }
  C
  ffi_callback :hook_fn, [], :void
  ffi_func :hook_set, [:hook_fn], :void
  ffi_func :hook_then_len, [:str], :long
  ffi_func :call_then_len, [:str, :hook_fn], :long
  ffi_func :vhook_then_len, [:int, :varargs], :long
end

def churn
  $junk = Array.new(20) { "x" * 1_000_000 }
  nil
end

Hook.hook_set(method(:churn))
s = "a" * 1_000_000
p Hook.hook_then_len(s + "b")
p Hook.call_then_len(s + "cd", method(:churn))
p Hook.vhook_then_len(1, s + "efg")
t = +"q"
u = t
u << s
p Hook.hook_then_len(t)
