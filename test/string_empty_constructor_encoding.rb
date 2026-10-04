# Empty String constructors start in ASCII-8BIT, while copying a String keeps
# its source encoding. Appending an Integer to the empty result writes one byte.
p String.new.encoding.to_s
p String.allocate.encoding.to_s

klass = String
p klass.new.encoding.to_s
p klass.allocate.encoding.to_s

def make_string(klass)
  klass.new
end
p make_string(String).encoding.to_s

s = String.new
s << 255
p s.bytes

s = String.allocate
s << 255
p s.bytes

p String.new("é").encoding.to_s
p String.new(encoding: Encoding::UTF_8).encoding.to_s

s = String.new
s << "a"
s << "é"
p s.encoding.to_s
p s[1]

def make_string
  s = String.new
  s << "A"
  s << "é"
  s
end

s = make_string
p s.encoding.to_s
p s.length
p s.bytesize
p s[1]
