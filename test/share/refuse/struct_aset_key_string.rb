# Refused under --share-strings: a String stored into a Struct member by
# `[]=` with a key that is no literal, on a receiver typed as the Struct,
# is a copy, so the append through the variable would not reach the
# member (CRuby: "abcd").
S = Struct.new(:x)
o = S.new(+"value")
k = ARGV.size
o[k] = 4
s = +"abc"
o[k] = s
s << "d"
p o.x
