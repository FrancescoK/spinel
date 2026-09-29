# A String holding NUL bytes keeps its length when the slot it is stored in is
# promoted to a shared mutable handle. The conversion sized the source with
# strlen unless it carried the ASCII-8BIT tag, and a string of NUL bytes is
# all-ASCII: it arrived EMPTY, and the first setbyte raised "index 0 out of
# string" against a zero-length buffer. length/bytes are byte-exact for
# embedded NUL (docs/limitations.md), so this was a storage bug, not one of
# the documented C-string transforms.
#
# The promotion is what brings the handle in: @s is mutated through its reader.
class Box
  attr_reader :s
  def initialize(s)
    @s = s
  end
end
b = Box.new("\0" * 8)
puts b.s.length
b.s.setbyte(0, 65)
p b.s.bytes

# A NUL in the middle, so the truncation would be partial rather than total.
class Mid
  attr_reader :s
  def initialize(s)
    @s = s
  end
end
m = Mid.new(+"ab\0cd")
puts m.s.length
m.s.setbyte(4, 90)
p m.s.bytes

# The binary-tagged path this guard already covered stays correct.
class Packed
  attr_reader :s
  def initialize(s)
    @s = s
  end
end
pk = Packed.new([0, 0, 0].pack("C*"))
puts pk.s.length
pk.s.setbyte(1, 7)
p pk.s.bytes

# And a plain string with no NUL is unchanged.
class Plain
  attr_reader :s
  def initialize(s)
    @s = s
  end
end
pl = Plain.new(+"abcd")
puts pl.s.length
pl.s.setbyte(0, 88)
p pl.s.bytes
