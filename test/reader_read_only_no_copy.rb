# A reader whose result is only READ hands out the live buffer, not a copy of
# it. `ctx.buf.getbyte(i)` in a loop copied the WHOLE string to answer one
# byte -- O(len) per read, so a per-row scan over a large buffer was quadratic.
#
# The answers must not move: the read is of the live buffer, so a mutation
# made through any other reference is visible to the next read, exactly as in
# CRuby. That is what this test pins; the copy elision is the point of it.
# spinel: decisions
class Holder
  attr_reader :buf
  def initialize(buf)
    @buf = buf
  end
end

class Writer
  def initialize(h)
    @h = h
  end
  def poke(i, v)
    b = @h.buf
    b.setbyte(i, v)
  end
end

h = Holder.new(+"AAAAAAAA")
w = Writer.new(h)

# read-only accessors over the reader: each sees the CURRENT bytes
p h.buf.getbyte(0)
p h.buf.length
p h.buf.bytesize
p h.buf.empty?

w.poke(0, 66)
p h.buf.getbyte(0)      # the mutation is visible: 66, not a stale 65
w.poke(1, 67)
p h.buf.getbyte(1)
p h.buf.getbyte(0)      # and the earlier one is still there

# a loop of reads, the shape the copy made quadratic
n = 0
i = 0
while i < 8
  n += 1 if h.buf.getbyte(i) == 65
  i += 1
end
p n

# a kept reference aliases the same String in CRuby, so a later mutation
# through the holder is visible through it too -- both read 68.
kept = h.buf
w.poke(2, 68)
p kept.getbyte(2)
p h.buf.getbyte(2)

# The hoisted alias: the reader is read into a local once and that local is
# read in a loop. The assignment used to copy the whole String -- O(len) per
# call, which in a per-feature scan is most of the run. The local holds the
# live buffer now, so a mutation through the holder is visible to it, as in
# CRuby.
def scan(holder, n, v)
  bytes = holder.buf
  c = 0
  i = 0
  while i < n
    c += 1 if bytes.getbyte(i) == v
    i += 1
  end
  c
end
p scan(h, 8, 65)
w.poke(3, 90)
p scan(h, 8, 65)
