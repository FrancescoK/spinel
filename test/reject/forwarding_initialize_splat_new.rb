# A splat argument to `new` of a class whose initialize forwards `...` has no
# count to size the forward's parameters by, and was laid out as one
# argument. The shape is refused instead.
class A
  def initialize(a, b) = @v = [a, b]
  def v = @v
end
class B < A
  def initialize(...) = super(...)
end
arr = [1, 2]
p B.new(*arr).v
