# An initialize that forwards `...` to its parent passes only what each
# `new` gave it, so a narrower `new` leaves the parent's default in place:
# `B.new(1)` beside `B.new(1, 5)` answers [1, 2].
class A
  def initialize(a, b = 2) = @v = [a, b]
  def v = @v
end
class B < A
  def initialize(...) = super(...)
end
p B.new(1).v
p B.new(1, 5).v
