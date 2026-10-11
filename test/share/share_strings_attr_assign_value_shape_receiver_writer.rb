# spinel: gc-minor
# The value of an attribute assignment as the receiver of a mutating call is the very String the writer was handed,
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
t = +"t"
(o.a = t).concat("8")
p [o.a, t]
