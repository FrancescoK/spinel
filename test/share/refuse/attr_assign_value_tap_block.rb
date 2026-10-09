# An attribute assignment's value passed through `tap` with a block and then
# appended to: the block's temp is declared where the value is not yet read.
class K
  attr_accessor :a
end
o = K.new
s = +"s"
v = (o.a = s).tap { }
v << "3"
p s, o.a, v
p 1
