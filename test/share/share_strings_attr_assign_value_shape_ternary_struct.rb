# spinel: gc-minor
# The value of an attribute assignment in a ternary branch is the very String the writer was handed,
# so a change through the value shows in the field and the right-hand side.
S = Struct.new(:a)
o = S.new(+"x")
s = +"s"
x = s.size > 0 ? (o.a = s) : +"no"
x << "3"
p [o.a, s, x]
