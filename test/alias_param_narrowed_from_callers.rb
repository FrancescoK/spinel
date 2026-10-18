# A method called under an alias's name takes the arguments of those calls
# too. The parameter of on_a was narrowed to the one class its own callers
# hand it, a local or an Array element of that class, and a call through
# the alias with another class was refused.
class N
  def initialize(v) = @v = v
  def v = @v
end
class A < N; end
class B < N; end
class D < N; end

class C
  def on_a(node) = node.v
  alias on_b on_a
  alias on_d on_b

  def each_a(node) = node.v * 10
end

class E < C
  alias on_e each_a
end

c = C.new
a = A.new(1)
b = B.new(2)
p c.on_a(a)
p c.on_b(b)
as = [A.new(3), A.new(4)]
ds = [D.new(5)]
p c.on_a(as[1])
p c.on_d(ds[0])

e = E.new
p e.each_a(as[0])
p e.on_e(b)
