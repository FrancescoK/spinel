# A lambda parameter that its body writes an Integer to holds both that
# Integer and the value of the call.

class Pt
  attr_reader :v
  def initialize(v) = (@v = v)
end

l = ->(q) { q = 5; p q }
l.call(Pt.new(1))

m = ->(q) { r = q.v; q = 7 if r > 2; p [r, q.is_a?(Pt)] }
m.call(Pt.new(2))
m.call(Pt.new(3))

k = proc { |q| q = 0 if q.v > 1; q }
p [1, 2].map { |v| k.call(Pt.new(v)).is_a?(Pt) }
