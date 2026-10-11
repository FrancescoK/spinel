# spinel: gc-minor
# The value of an attribute assignment in a ternary branch is the very String the writer was handed,
# so a change through the value shows in the field and the right-hand side.
class W
  attr_reader :a
  def initialize = (@a = +"x")
  def a=(v)
    @a = v
    0
  end
end
o = W.new
s = +"s"
x = s.size > 0 ? (o.a = s) : +"no"
x << "3"
p [o.a, s, x]
