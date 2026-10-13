# `str << int` with an ASCII codepoint appends that byte without making a
# one-character String for it; the receiver still gets its own copy, and
# Integer#chr's shared one-byte Strings stay as they were.
s = +""
i = 65
while i < 70
  s << i
  i += 1
end
puts s
s[0] = "z"
puts s
puts 65.chr

t = +"x"
t.concat(0, 127, 98)
p t
p t.bytesize

u = +"a"
u << 233
p u
p u.encoding == Encoding::UTF_8

b = "".b
b << 65
b << 200
p b.bytes
p b.encoding == Encoding::BINARY

class Buf
  def initialize; @s = +""; end
  def add(n); @s << n; self; end
  def s; @s; end
end
w = Buf.new.add(104).add(105).s
w << 33
puts w
w.upcase!
puts w
puts 104.chr + 105.chr

vals = [72, "i", 33]
v = +""
vals.each { |x| v << x }
puts v

begin
  +"" << -1
rescue RangeError => e
  puts e.message
end
