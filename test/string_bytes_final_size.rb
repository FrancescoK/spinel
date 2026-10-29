# String#bytes makes its Array at the String's byte length
# The Array was pushed into from 16 slots; it is now made at its final size
# and filled in place. It is an ordinary Array after that: it grows, shrinks
# and takes other values.

p "".bytes, "a".bytes, ("x" * 16).bytes.size, ("x" * 17).bytes.size
p "héllo ☃".bytes
p "\xff\x00\x80".b.bytes
long = ("abc" * 1000).bytes
p long.size, long.sum, long.first(4), long.last(2)

a = "seventeen bytes!!".bytes
a << 1 << 2
a.concat("xyz".bytes)
p a.size, a.last(5)
p a.pop, a.shift, a.size

s = +"grow"
b = s.bytes
s << "n"
p b, s.bytes

sum = 0
("q" * 40).each_byte { |x| sum += x }
p sum

begin
  nil.bytes
rescue NoMethodError => e
  p e.class
end
