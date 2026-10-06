# append_as_bytes copies raw bytes and keeps the receiver's encoding, even
# when ordinary concatenation would adopt the argument's encoding.
s = "".b
s.append_as_bytes("€")
p s.encoding, s.bytes

s = "abc".b
s.append_as_bytes("€")
p s.encoding, s.bytes

s = "\xff".b
s.append_as_bytes("€")
p s.encoding, s.bytes

s = +""
s.append_as_bytes("\xff".b)
p s.encoding, s.bytes, s.valid_encoding?

s = +"€"
s.append_as_bytes("\xff".b)
p s.encoding, s.bytes, s.valid_encoding?

# Integers are single bytes, including NUL and bytes invalid in UTF-8.
s = "".b
s.append_as_bytes(233)
p s.encoding, s.bytes
s = +""
s.append_as_bytes(233)
p s.encoding, s.bytes, s.valid_encoding?

s = "".b
s.append_as_bytes("a", "€", 0, "\xff".b, "")
p s.encoding, s.bytes
s = +""
s.append_as_bytes("a", "\xff".b, 0, "€", "".b)
p s.encoding, s.bytes, s.valid_encoding?

s = String.new
s.append_as_bytes("\0€")
p s.encoding, s.bytes

# A proc parameter uses the existing shared handle, including after growth.
append = proc { |str| str.append_as_bytes("€", 0, "\xff".b) }
binary = "".b
append.call(binary)
p binary.encoding, binary.bytes
text = +""
append.call(text)
p text.encoding, text.bytes, text.valid_encoding?
grow = proc { |str| str.append_as_bytes("€" * 100) }
grow.call(binary)
p binary.encoding, binary.bytesize, binary.getbyte(5)

# The boxed receiver reaches the same raw-byte operation.
boxed = ["".b, 1][0]
boxed.append_as_bytes("€", 0)
p boxed.encoding, boxed.bytes

frozen = "".b.freeze
begin
  append.call(frozen)
rescue FrozenError => e
  p e.class
end
p frozen.encoding, frozen.bytes

# String#+, concat and << still negotiate their encodings.
p ("".b + "€").encoding
s = "".b
s.concat("€")
p s.encoding, s.bytes
s = "".b
s << "€"
p s.encoding, s.bytes
