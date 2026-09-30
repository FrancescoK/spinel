# A call naming keywords beside a `**` typed the keyword parameters from the
# `**`'s value type alone and never from the keywords it names. A String-keyed
# `**` (whose keys go to the `**kwrest`) has Integer values here, so
# `m(k1: "a", **h)` typed k1 an Integer, and the String read out of the merged
# hash printed as its pointer. The named keywords bind by name as well.

def m(k1:, **kw) = [k1, kw]
def opt(k1: 0, k2: 2, **kw) = [k1, k2, kw]

h = {"s" => 3}
p m(k1: "a", **h)
p m(**h, k1: 1.5)
p m(k1: [1], "t" => 4, **h)
p opt(k1: "b", **h)
p opt(k2: :x, **h)
p m(k1: "c", **{"u" => 5})

class K
  attr_reader :v
  def initialize(k1:, **kw) = (@v = [k1, kw])
end
class L
  def m(k1:, **kw) = [k1, kw]
end
p K.new(k1: "d", **h).v
p L.new.m(k1: "e", **h)

class A
  def m(k1:, **kw) = [k1, kw]
end
class B < A
  def m(o) = super(k1: "f", **o)
end
p B.new.m(h)
p method(:m).call(k1: "g", **h)
p send(:m, k1: "i", **h)

# a Symbol-keyed `**` was already right
p m(k1: "j", **{s: 6})
