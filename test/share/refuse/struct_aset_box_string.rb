# Refused under --share-strings: a String stored into a Struct member by
# `[]=` through a boxed receiver is a copy (the dispatch hands the arm the
# String read out, not its handle), so the append through the variable
# would not reach the member (CRuby: "abcd").
S = Struct.new(:x)
o = [S.new(+"value"), 0][0]
o[0] = 4
s = +"abc"
o[0] = s
s << "d"
p o.x
