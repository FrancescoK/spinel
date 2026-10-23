# An array of one class walked by each binds its block parameter as the
# element class, so `pt.x` in the walks is a direct field read; the class
# defines its own each, which keeps nothing boxed. infer-test greps the C.
class Pt
  attr_reader :x
  def initialize(x) = @x = x
  def each = yield(@x)
end
class Cloud
  def initialize = @pts = [Pt.new(1)]
  def add(pt) = @pts << pt
  def sum
    s = 0
    @pts.each { |pt| s += pt.x }
    @pts.reverse_each { |pt| s += pt.x }
    @pts.each_with_index { |pt, i| s += pt.x * i }
    s
  end
end
c = Cloud.new
c.add(Pt.new(2))
p c.sum
