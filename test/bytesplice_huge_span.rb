# spinel: int64
p "abc".dup.bytesplice(1..9223372036854775807, "x")
p "abc".dup.bytesplice(0, 1, "xyz", 1, 9223372036854775807)
p "abc".dup.bytesplice(0..0, "xyz", 1..9223372036854775807)
