# A mutable byte buffer passed, once per row, to a method that only reads it
# (#7482). A second name for the buffer (`peek`, never called) makes it a
# shared handle, and a handle passed to a `const char *` parameter used to be
# copied in full at every call: O(len) per call. A parameter that only reads
# the bytes for the length of the call borrows the handle's buffer instead,
# so the time is flat in the buffer's length.

class Holder
  def initialize(len)
    @buf = "\0".b * len
    i = 0
    while i < 64
      @buf.setbyte(i, i * 3 % 251)
      i += 1
    end
  end

  def self.use(s, i)
    s.getbyte(i % 64)
  end

  def peek
    b = @buf
    b.getbyte(1)
  end

  def run(n)
    t = 0
    n.times { |i| t += Holder.use(@buf, i) }
    t
  end
end

h = Holder.new(1 << 24)
puts h.run(1000)
