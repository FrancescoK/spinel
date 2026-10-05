# String#unpack with a block yields each value it decodes and answers nil,
# as CRuby's does. The block was ignored and the call answered the Array.

p "Hello".unpack("C*") { |x| p x }
seen = []
r = "AB".unpack("C*") { |v| seen << v }
p r, seen
p "Hi".unpack("C*", offset: 1) { |x| p x }
p "\x01\x00\x02\x00".unpack("v*") { |v| p v * 10 }
p "ab".unpack("a1 a1") { |s| p s.upcase }
show = proc { |v| p v }
p "AB".unpack("C*", &show)

def decode(s)
  total = 0
  s.unpack("C*") { |b| total += b }
  total
end
p decode("AB")

def first_word(str) = str.unpack("a2") { |w| p w }
p first_word("xyz")
p "AB".unpack("C*")
