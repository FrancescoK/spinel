# spinel: not-cruby -- ffi_func and ffi_callback are Spinel's own.
# A shared String handed to a C function's :str argument takes the handle's
# live buffer only where no Ruby code can run during the call. A C function
# can run some: an ffi_callback it was handed earlier, or a Signal.trap
# handler for a signal it raises. If that code grows the String, the buffer
# the argument points into is freed, so a program with either keeps the
# copy. Each callback below grows the String past its buffer, restores it,
# and allocates buffers of the same size: the copy sums the bytes it was
# handed, a freed buffer sums theirs.
module Hook
  ffi_source <<~C
    #include <signal.h>
    #include <string.h>
    typedef void (*hook_fn)(void);
    static hook_fn hook_cb;
    void hook_set(hook_fn f) { hook_cb = f; }
    static long sum(const char *s) {
      long t = 0;
      for (size_t i = 0, n = strlen(s); i < n; i++) t += (unsigned char)s[i];
      return t;
    }
    long hook_then_sum(const char *s) { hook_cb(); return sum(s); }
    long raise_then_sum(const char *s, int sig) { raise(sig); return sum(s); }
  C
  ffi_callback :hook_fn, [], :void
  ffi_func :hook_set, [:hook_fn], :void
  ffi_func :hook_then_sum, [:str], :long
  ffi_func :raise_then_sum, [:str, :int], :long
end

class Buf
  def initialize
    reset
  end

  # a String with a second name, in a buffer just big enough for it
  def reset
    @buf = +"abc"
    @buf << "d" * 1000
    b = @buf
    b << "e"
  end

  # grow past the buffer, restore, and reuse the freed memory
  def churn
    @buf << "x" * 100_000
    @buf.slice!(1004..)
    @junk = Array.new(32) { |i| j = +"Z"; j << "Z" * (900 + i); j }
    nil
  end

  def via_callback
    reset
    [Hook.hook_then_sum(@buf), @buf.bytesize]
  end

  def via_signal
    reset
    sig = Signal.list["USR1"]
    old = Signal.trap(:USR1) { churn }
    r = Hook.raise_then_sum(@buf, sig)
    Signal.trap(:USR1, old)
    [r, @buf.bytesize]
  end
end

$b = Buf.new
def churn_cb = $b.churn
Hook.hook_set(method(:churn_cb))
p $b.via_callback
p $b.via_signal
