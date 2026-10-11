# A case subject that is an attribute assignment, bound by a pattern and changed:
# the bound value would be a copy.
K = Struct.new(:a)
o = K.new(+"x")
s = +"s"
case o.a = s
in String => x
  x << "1"
end
p [o.a, s, x]
p 1
