# Refused under --share-strings: a String a variable holds, stored into a
# Struct member by `[]=` through a boxed receiver, is a copy, so the
# append through the member would not reach the variable (CRuby: "abce").
S = Struct.new(:x)
o = [S.new(+"value"), 0][0]
o[0] = 4
s = +"abc"
o[0] = s
o.x << "e"
p s
