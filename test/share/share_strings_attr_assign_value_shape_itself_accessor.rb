# spinel: gc-minor
# The value of an attribute assignment passed through `itself` and kept is the very String the writer was handed,
# so a change through the value shows in the field and the right-hand side.
class Acc
  attr_accessor :a
  def initialize = (@a = +"x")
end
o = Acc.new
u = +"u"
z = (o.a = u).itself
z << "9"
p [o.a, u, z]
