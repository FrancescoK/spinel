# Each poly arm calls its own operator before the builtin delegates.
class A; def initialize(v) = @v = v; def ==(o) = (o.is_a?(A) ? nil : 0); end
a = A.new(1)
p(a != A.new(2)); p(a != 5)
class B; def initialize(v) = @v = v; def ==(o) = o.is_a?(B); def !=(o) = :own; end
p(B.new(1) != B.new(1))
class C < A; end
p(C.new(1) != C.new(1))
xs = [A.new(1), B.new(2)]
xs.each { |x| p(x != x) }
class D < B; end
[A.new(1), D.new(2)].each { |x| p(x != x) }

# Case equality keeps both an inherited override and the delegated fallback.
class CaseDefault
  def ==(other) = false
end
class CaseOwn
  def ==(other) = false
  def ===(other) = :case_own
end
class CaseChild < CaseOwn; end
[CaseDefault.new, CaseOwn.new, CaseChild.new].each do |x|
  p(x === x); p(x === CaseDefault.new)
end

# Comparable operators take the same per-arm route, including Boolean overrides.
class OrderDefault
  include Comparable
  def <=>(other) = 0
end
class OrderOwn
  include Comparable
  def <=>(other) = 0
  def <(other) = :less
  def <=(other) = false
  def >(other) = :greater
  def >=(other) = false
end
class OrderChild < OrderOwn; end
[OrderDefault.new, OrderOwn.new, OrderChild.new].each do |x|
  p(x < x); p(x <= x); p(x > x); p(x >= x)
end

# A value-returning protocol remains on its existing builtin dispatch.
class Clamper
  def clamp(other) = true
end
[1, Clamper.new].each { |x| p x.clamp(1..2) }
