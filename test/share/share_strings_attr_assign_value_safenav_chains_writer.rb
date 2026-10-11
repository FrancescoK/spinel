# spinel: gc-minor
# The value of a safe-navigation attribute assignment: the right-hand side's
# String when every receiver of the chain is non-nil, and nil when one is nil
# (the rest of the chain is skipped), here for an explicit writer. The kept value is the
# String itself: it changes with the right-hand side and answers equal? true.
class Hold
  def initialize(k) = (@k = k)
  def b = @k
end
def hold_or_nil(o, f) = f ? Hold.new(o) : nil
class K
  attr_reader :a
  def initialize = (@a = +"x")
  def a=(v)
    @a = v
    0
  end
end

o = K.new
s = +"s"
none = hold_or_nil(o, false)
r = (none&.b&.a = s)
p r
h = hold_or_nil(o, true)
r = (h&.b&.a = s)
s << "1"
p [o.a, s, r, r.equal?(s), o.a.equal?(s)]
r << "2"
p [o.a, s, r]
q = (h&.b&.a = +"t")
q << "3"
p [o.a, q, q.equal?(o.a)]
u = (h&.b.a = s)
u << "4"
p [o.a, s, u.equal?(s)]
