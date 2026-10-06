# A String parameter whose callee changes the same String keeps its copy
# (#7482, #6765). The parameter takes a shared handle's live buffer only in a
# callee that makes no user or dynamic call and changes no String; one that
# grows the String, through a second parameter, an instance variable, a
# block, a proc, `send` or a method it calls, would free the buffer the
# parameter points into. Each change below grows the String past its buffer,
# restores it, and allocates buffers of the same size: the copy reads what
# CRuby reads, a freed buffer reads their bytes. (A change that lasts is
# read stale through the copy: #6765 settles that case.)

class Buf
  def initialize
    @pr = proc { churn }
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

  def read(s) = [s.bytesize, s.getbyte(0), s.getbyte(1003)]

  def two(s, t)
    t << "x" * 100_000
    t.slice!(1004..)
    @junk = Array.new(32) { |i| j = +"Z"; j << "Z" * (900 + i); j }
    [s.bytesize, s.getbyte(0), s.getbyte(1003)]
  end

  def via_ivar(s)
    @buf << "x" * 100_000
    @buf.slice!(1004..)
    @junk = Array.new(32) { |i| j = +"Z"; j << "Z" * (900 + i); j }
    [s.bytesize, s.getbyte(0), s.getbyte(1003)]
  end

  def via_call(s)
    churn
    [s.bytesize, s.getbyte(0), s.getbyte(1003)]
  end

  def via_block(s)
    yield
    [s.bytesize, s.getbyte(0), s.getbyte(1003)]
  end

  def via_proc(s)
    @pr.call
    [s.bytesize, s.getbyte(0), s.getbyte(1003)]
  end

  def via_send(s)
    send(:churn)
    [s.bytesize, s.getbyte(0), s.getbyte(1003)]
  end

  def run
    r = []
    reset; r << read(@buf)
    reset; r << two(@buf, @buf)
    reset; r << via_ivar(@buf)
    reset; r << via_call(@buf)
    reset; r << via_block(@buf) { churn }
    reset; r << via_proc(@buf)
    reset; r << via_send(@buf)
    r
  end
end

Buf.new.run.each { |x| p x }
