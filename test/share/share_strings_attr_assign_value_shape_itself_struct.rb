# spinel: gc-minor
# The value of an attribute assignment passed through `itself` and kept is the very String the writer was handed,
# so a change through the value shows in the field and the right-hand side.
S = Struct.new(:a)
o = S.new(+"x")
u = +"u"
z = (o.a = u).itself
z << "9"
p [o.a, u, z]
