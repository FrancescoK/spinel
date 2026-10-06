# A String parameter takes a shared handle's live buffer only where nothing
# can change the String while the callee runs (#7482). Ruby code the callee
# does not call can: another thread while the callee waits on IO, the code
# that resumes after the callee yields its fiber, a signal handler. Growing
# the String frees the buffer a borrowing parameter points into, so a
# program with any of them keeps the copy. Each change below grows the
# String past its buffer, restores it, and allocates buffers of the same
# size: the copy reads what CRuby reads, a freed buffer reads their bytes.

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

  def via_fiber(s)
    Fiber.yield
    [s.bytesize, s.getbyte(0), s.getbyte(1003)]
  end

  def via_thread(s, w, r)
    w.write("go")
    r.read(2)
    [s.bytesize, s.getbyte(0), s.getbyte(1003)]
  end

  def via_signal(s)
    Process.kill(:USR1, Process.pid)
    sleep 0.05
    [s.bytesize, s.getbyte(0), s.getbyte(1003)]
  end

  def run_fiber
    reset
    fb = Fiber.new { via_fiber(@buf) }
    fb.resume
    churn
    fb.resume
  end

  def run_thread
    reset
    r1, w1 = IO.pipe
    r2, w2 = IO.pipe
    th = Thread.new { r1.read(2); churn; w2.write("ok") }
    res = via_thread(@buf, w1, r2)
    th.join
    res
  end

  def run_signal
    reset
    old = Signal.trap(:USR1) { churn }
    res = via_signal(@buf)
    Signal.trap(:USR1, old)
    res
  end
end

b = Buf.new
p b.run_fiber
p b.run_thread
p b.run_signal
