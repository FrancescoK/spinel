# An initialize that forwards `...` to its parent takes as many synthesized
# parameters as the widest `new` passes, and a narrower `new` would fill the
# rest with nil where the parent expects its default: `B.new(1)` beside
# `B.new(1, 5)` answered [1, nil]. The shape is refused instead.
class A
  def initialize(a, b = 2) = @v = [a, b]
  def v = @v
end
class B < A
  def initialize(...) = super(...)
end
p B.new(1).v
p B.new(1, 5).v
