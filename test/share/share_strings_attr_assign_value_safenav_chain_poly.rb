# spinel: gc-minor
# A safe-navigation assignment chain whose receiver is a String-or-nil boxed
# value, through an explicit writer: nil when a receiver is nil, the
# right-hand side's String when none is, and kept values change with it.
class K
  attr_reader :a
  def initialize = (@a = +"x")
  def a=(v)
    @a = v
    0
  end
end
class B
  def initialize(k) = (@k = k)
  def b = @k
end
o = K.new
s = +"s"
bo = [B.new(o), nil][1]
r = (bo&.b&.a = s)
p r
bo2 = B.new(o)
bo2&.b&.a = s
s << "1"
p [o.a, s]
bo3 = [B.new(o), nil][0]
r3 = (bo3&.b&.a = s)
s << "2"
p [r3, o.a, s, r3.equal?(s)]
