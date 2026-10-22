# A BasicObject descendant does not inherit Object's include of Comparable:
# its < raises NoMethodError, while an Object subclass compares.
class Object; include Comparable; end
class B < BasicObject
  def initialize(n) = @n = n
  def n = @n
  def <=>(o) = @n <=> o.n
end
class P; def initialize(n) = @n = n; def n = @n; def <=>(o) = @n <=> o.n; end
xs = [B.new(1), P.new(1), 3]
[0, 1].each do |i|
  begin; ::Kernel.p(xs[i] < xs[i]); rescue ::NoMethodError => e; ::Kernel.p :NoMethodError; end
end
