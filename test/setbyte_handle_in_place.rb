# setbyte on a shared-handle String writes the byte into the handle's OWN
# buffer. It used to read the whole String out, mutate that copy and append it
# back -- two O(len) passes to write one byte -- so filling a column of a large
# buffer one row at a time was quadratic in the buffer.
#
# Every alias must still observe the write: that is what the handle is for.
class Holder
  attr_reader :buf
  def initialize(b)
    @buf = b
  end
end

h = Holder.new(+"AAAA")
a = h.buf
b = h.buf
a.setbyte(0, 66)
p b.getbyte(0)          # through a second alias
p h.buf.getbyte(0)      # through the reader
h.buf.setbyte(1, 67)    # and written through the reader
p a.getbyte(1)
p h.buf

# the value is the one given, and the receiver is mutated
s = +"xyz"
p s.setbyte(0, 90)
p s

# a negative index counts from the end
s.setbyte(-1, 88)
p s

# out of range still raises, against the real length
begin
  s.setbyte(9, 66)
rescue IndexError
  puts "IndexError"
end

# a run of writes, the shape that was quadratic
buf = Holder.new(+("A" * 16))
w = buf.buf
i = 0
while i < 16
  w.setbyte(i, 65 + i)
  i += 1
end
p buf.buf
