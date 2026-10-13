# An attribute's `||=` stores into the attribute, and an index's
# operator write stores what the operator answers: the class facts (#8530)
# took none of them for a write, so a poly call on the value read back had
# no arm for the class stored there (NoMethodError).
class A; def foo = "A"; end
class B; def foo = "B"; end
class C; def foo = "C"; end
class D
  def foo = "D"
  def +(_) = C.new
end
class Box; attr_accessor :x; end

b = Box.new
b.x ||= B.new
[A.new, b.x].each { |o| puts o.foo }

h = { k: D.new }
h[:k] += 1
[A.new, h[:k]].each { |o| puts o.foo }
