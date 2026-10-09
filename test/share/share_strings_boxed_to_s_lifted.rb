# spinel: share
# spinel: gc-minor
# A boxed local read through to_s and changed in place is the String its
# caller passed, whether the caller holds it in a local or a captured local,
# and a second to_s on it answers the same String.
class Own
  def initialize(n) = (@n = n)
  def to_s = @n
end
def grow(o)
  s = o.to_s
  s << "!"
  o
end
def twice(o)
  s = o.to_s
  s << "1"
  t = o.to_s
  t << "2"
  [o, s, t]
end
l = +"loc"
grow(l)
own = Own.new(+"own")
grow(own)
cap = +"cap"
bump = -> { cap << "?" }
grow(cap)
bump.call
p l, own.to_s, cap
p grow(+"lit")
p twice(+"b")
p twice(Own.new(+"c")).map(&:to_s)
