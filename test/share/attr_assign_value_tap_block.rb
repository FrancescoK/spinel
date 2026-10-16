# An attribute assignment's value passed through `tap` with a block and then
# appended to is the String the attribute holds (#9258).
class K
  attr_accessor :a
end
o = K.new
s = +"s"
v = (o.a = s).tap { }
v << "3"
p s, o.a, v
p 1
