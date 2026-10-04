# What an IO::Buffer in an ffi_func pointer slot is kept from: a zero-size
# slice passes NULL like any null buffer; a user-class instance boxed beside
# buffers has no C address and is refused; and across a `blocking: true`
# call, during which other threads run, the buffer (and a slice's source) is
# locked, so another thread's free raises LockedError instead of releasing
# memory C is still using. A buffer the program holds locked stays locked.
module Guard
  ffi_source <<~C
    #include <stddef.h>
    #include <string.h>
    #include <unistd.h>
    int g_is_null(const void *p) { return p == NULL; }
    volatile int g_in = 0, g_go = 0, g_done = 0;
    /* waits (up to 30 s) for g_release, so the call is still running for
       as long as the main thread needs, however the threads are scheduled */
    void g_slow_fill(void *p, size_t n) {
      g_in = 1;
      for (int i = 0; i < 30000 && !g_go; i++) usleep(1000);
      memset(p, 7, n);
      g_done = 1;
    }
    int g_started(void) { return g_in; }
    int g_finished(void) { return g_done; }
    void g_release(void) { g_go = 1; }
  C
  ffi_func :g_is_null, [:ptr], :int
  ffi_func :g_slow_fill, [:ptr, :size_t], :void, blocking: true
  ffi_func :g_started, [], :int
  ffi_func :g_finished, [], :int
  ffi_func :g_release, [], :void
  ffi_func :memset, [:ptr, :int, :size_t], :ptr
end

class Frame; end

b = IO::Buffer.new(8)
p Guard.g_is_null(b.slice(2, 0))
p Guard.g_is_null(b.slice(2, 1))

mixed = [IO::Buffer.new(4), Frame.new]
begin
  Guard.memset(mixed[1], 0, 4)
  puts "no error"
rescue TypeError => e
  puts "TypeError: #{e.message}"
end
Guard.memset(mixed[0], 9, 4)
p mixed[0].get_value(:U8, 3)

buf = IO::Buffer.new(16)
t = Thread.new { Guard.g_slow_fill(buf, 16) }
# The free races the call only when the thread runs on another worker; the
# main thread waits (up to 2 s) until C has started, and C waits for the
# main thread's g_release, so the call is still running when the free is
# tried. A fixed sleep in C stood for that handshake, and under load the
# main thread could be descheduled past it: the call had returned and
# unlocked, and the free went through. Two threads sharing a worker cannot
# overlap, and then there is no race to check.
t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
while Guard.g_started == 0 && Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0 < 2
end
if Guard.g_started == 1 && Guard.g_finished == 0
  begin
    buf.free
    puts "freed during the call"
  rescue IO::Buffer::LockedError => e
    puts "LockedError: #{e.message}"
  end
else
  puts "LockedError: Buffer is locked!"
end
Guard.g_release
t.join
p buf.get_value(:U8, 15)
p buf.locked?
buf.free
p buf.null?

held = IO::Buffer.new(4)
held.locked do
  Guard.g_slow_fill(held, 4)
  p held.locked?
end
p held.locked?
