# An Integer appended to an ASCII-8BIT string is one byte, 0..255, and a
# larger one is RangeError; a UTF-8 receiver still takes the codepoint.
s = "".b
s << 231
p s.bytes, s.encoding
s.concat(0, 255)
p s.bytes
begin
  s << 256
rescue RangeError => e
  p e.message
end
b = String.new(capacity: 16, encoding: Encoding::BINARY)
b << 200
b << 65
p b.bytes, b.encoding
u = +""
u << 231
p u.bytes
