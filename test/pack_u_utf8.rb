# A pack template of U directives answers a UTF-8 String, as CRuby's does:
# one character per code point, equal to the same text written as a literal.
# Any other directive keeps the bytes ASCII-8BIT.
s = [233, 0x3042].pack("U*")
p s.encoding
p s.length
p s.bytesize
p s == "éあ"
p s.chars.size
p s.valid_encoding?
p [104, 105].pack("U*")
p [104, 105].pack("U2") == "hi"
p [233].pack(" U ").encoding
p [65, 66].pack("UC").encoding
p [65, 66].pack("CU").encoding
p [233].pack("U").reverse.length
xs = [233, "x"]
p [xs[0]].pack("U").length
p [1.5].pack("e").encoding
p ["a", "b"].pack("a2a").encoding
p [0xE9].pack("C").length
