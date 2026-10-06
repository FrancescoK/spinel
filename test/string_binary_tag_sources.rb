# spinel has two encodings, UTF-8 and ASCII-8BIT, and one rule for which is
# which: a string is ASCII-8BIT when the PROGRAM ASKED FOR BYTES. CRuby's third
# encoding, US-ASCII, carries only "these bytes are 7-bit" -- measurably nothing
# else, since compatibility keys on the content being 7-bit rather than on the
# encoding's identity -- and spinel carries that as a header bit with no name.
#
# pack and String#b followed the rule. Marshal.dump, Random#bytes, binread,
# unpack and force_encoding did not: they answered UTF-8 over byte data, which
# is not only the wrong name. The tag makes #length count bytes, so
# `Random.bytes(8).length` was under 8 whenever the draw happened to be valid
# UTF-8 -- about three times in a thousand.

File.write("/tmp/_sp_enc_test_#{Process.pid}.bin", "abc")

# the ones that ask for bytes
puts [65].pack("C").encoding.to_s
puts "abc".b.encoding.to_s
puts Marshal.dump(1).encoding.to_s
puts Random.bytes(4).encoding.to_s
puts File.binread("/tmp/_sp_enc_test_#{Process.pid}.bin").encoding.to_s
puts IO.binread("/tmp/_sp_enc_test_#{Process.pid}.bin").encoding.to_s
puts "abc".unpack("a*")[0].encoding.to_s
puts "abc".unpack("A*")[0].encoding.to_s
puts "abc".unpack("Z*")[0].encoding.to_s
puts "abc".dup.force_encoding("ASCII-8BIT").encoding.to_s
puts "abc".dup.force_encoding(Encoding::BINARY).encoding.to_s
puts "abc".dup.force_encoding(Encoding::ASCII_8BIT).encoding.to_s

# the ones that do not
puts File.read("/tmp/_sp_enc_test_#{Process.pid}.bin").encoding.to_s
puts "abc".encoding.to_s
puts "abc".upcase.encoding.to_s
puts [65].pack("C").dup.force_encoding("UTF-8").encoding.to_s

# BINARY and ASCII-8BIT are one encoding, not two
p Encoding::BINARY == Encoding::ASCII_8BIT
p Encoding::BINARY.to_s
p Encoding::ASCII_8BIT.to_s

# the tag is load-bearing: a byte count, not a character count
bad = 0
1000.times { bad += 1 if Random.bytes(8).length != 8 }
p bad
m = Marshal.dump([1, 2, 3])
p m.length == m.bytesize
b = File.binread("/tmp/_sp_enc_test_#{Process.pid}.bin")
p b.length

# a String reached through a poly array answers #encoding: the poly dispatch
# had no arm for it, so it raised NoMethodError naming its own class -- and
# once it had one, the call had no type, so emit_boxed's untyped arm rendered
# `(expr, sp_box_nil())` and threw the answer away
a = ["abc", 1][0]
p a.encoding
p a.encoding.to_s
h = { "k" => [65].pack("C") }
p h["k"].encoding.to_s
def enc_of(v) = v.encoding.to_s
puts enc_of("abc")
puts enc_of([65].pack("C"))
