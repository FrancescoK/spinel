# A splat argument to `new` of a class whose initialize forwards `...`
# spreads into the parent's parameters.
class A
  def initialize(a, b) = @v = [a, b]
  def v = @v
end
class B < A
  def initialize(...) = super(...)
end
arr = [1, 2]
p B.new(*arr).v
