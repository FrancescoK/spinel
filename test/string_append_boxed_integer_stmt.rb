# String#<< in statement position with an Integer held in a boxed value
# appends the codepoint, as it does for a typed Integer: it appended the
# decimal digits instead ("19" for 19).
out = "R".b
v = [19, "x"][ARGV.size]
out << v
p out.bytes
w = [200, nil][ARGV.size]
out << w
p out.bytes

# The same box holding a String appends the String.
u = ["xy", 1][ARGV.size]
out << u
p out.bytes

# A chain appends each, left to right.
out << v << u << w
p out.bytes

# A UTF-8 receiver takes the Integer as a codepoint.
t = +"caf"
cp = [233, :e][ARGV.size]
t << cp
p t
p t.encoding

# An instance variable receiver, fed by a varint writer whose value is boxed.
class Writer
  def initialize = @buf = "".b
  attr_reader :buf

  def varint(n)
    while n >= 0x80
      @buf << ((n & 0x7f) | 0x80)
      n >>= 7
    end
    @buf << n
  end
end
wr = Writer.new
wr.varint([300, "s"][ARGV.size])
wr.varint(5)
p wr.buf.bytes
