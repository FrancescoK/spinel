# spinel: not-cruby -- ffi_func and ffi_callback are Spinel's own.
# spinel: wasm
# The :binstr and :string argument specs (the ffi-gem spelling) lower exactly
# as :str does: a boxed String, a String read out of a mixed Array or Hash, nil
# (NULL), and a non-String (TypeError, never an Integer passed as a pointer),
# and two String arguments in one call. So is an ffi_callback parameter: the
# method gets the String, or nil for NULL, even when another call site makes
# its parameter polymorphic. Each is a `const char *`, so before only a
# String-typed value worked, by accident.
module M
  ffi_source <<~'C'
    #include <stddef.h>
    static int cnt(const char *p, size_t n) {
      if (!p) return -1;
      int c = 0;
      for (size_t i = 0; i < n; i++) if (p[i] == 0) c++;
      return c;
    }
    int cnt_str(const char *p, size_t n) { return cnt(p, n); }
    int cnt_string(const char *p, size_t n) { return cnt(p, n); }
    int cnt_bin(const char *p, size_t n) { return cnt(p, n); }
    int cnt_two_string(const char *a, const char *b, size_t n) { return cnt(a, n) * 10 + cnt(b, n); }
    int cnt_two_bin(const char *a, const char *b, size_t n) { return cnt(a, n) * 10 + cnt(b, n); }
    typedef int (*cb_t)(const char *);
    int call_s(cb_t f) { return f("hello") + f(0) * 100; }
    int call_b(cb_t f) { return f("hello") + f(0) * 100; }
  C
  ffi_callback :cb_s, [:string], :int
  ffi_callback :cb_b, [:binstr], :int
  ffi_func :call_s, [:cb_s], :int
  ffi_func :call_b, [:cb_b], :int
  ffi_func :cnt_str, [:str, :size_t], :int
  ffi_func :cnt_string, [:string, :size_t], :int
  ffi_func :cnt_bin, [:binstr, :size_t], :int
  ffi_func :cnt_two_string, [:string, :string, :size_t], :int
  ffi_func :cnt_two_bin, [:binstr, :binstr, :size_t], :int
end

def h(x)
  x.nil? ? 7 : (x.is_a?(String) ? x.size : 0)
end

def try
  yield
rescue TypeError => e
  puts "TypeError: #{e.message}"
end

s = "a\0b\0c"
t = "\0\0\0\0\0"
arr = [1, s]
h = { a: 1, b: s }
x = ARGV.empty? ? s : 1
n = ARGV.empty? ? nil : "z"

# a String-typed value
p M.cnt_str(s, 5)
p M.cnt_string(s, 5)
p M.cnt_bin(s, 5)
# nil is NULL
p M.cnt_str(nil, 0)
p M.cnt_string(nil, 0)
p M.cnt_bin(nil, 0)
# an element of a mixed Array, a value of a mixed Hash
p M.cnt_string(arr[1], 5)
p M.cnt_bin(arr[1], 5)
p M.cnt_string(h[:b], 5)
p M.cnt_bin(h[:b], 5)
# a poly local, boxed String or nil
p M.cnt_string(x, 5)
p M.cnt_bin(x, 5)
p M.cnt_string(n, 5)
p M.cnt_bin(n, 5)
# a boxed non-String is a TypeError, as for :str
try { p M.cnt_str(arr[0], 5) }
try { p M.cnt_string(arr[0], 5) }
try { p M.cnt_bin(arr[0], 5) }
try { p M.cnt_bin(h[:a], 5) }
# two String arguments in one call
p M.cnt_two_string(s, t, 5)
p M.cnt_two_bin(s, t, 5)
p M.cnt_two_string(arr[1], h[:b], 5)
p M.cnt_two_bin(arr[1], nil, 5)
# a callback parameter: "hello" then NULL (nil); h is also called with an
# Integer, so its parameter is polymorphic
p M.call_s(method(:h))
p M.call_b(method(:h))
p h(42)
