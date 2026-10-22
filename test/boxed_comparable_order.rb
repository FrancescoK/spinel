# Boxed ordering uses Comparable only when the receiver includes it.
class PlainOrder
  def initialize(n) = @n = n
  attr_reader :n
  def <=>(other) = n <=> other.n
end
class IncludedOrder < PlainOrder
  include Comparable
end
class InheritedOrder < IncludedOrder
end
class ReopenedOrder < PlainOrder
end
class ReopenedOrder
  include Comparable
end
class OwnOrder < PlainOrder
  def <(other) = n < other.n
end
class NilOrder
  include Comparable
  def <=>(other) = nil
end
lo = PlainOrder.new(0)
hi = PlainOrder.new(2)
a = PlainOrder.new(1)
[ a, 3, a, PlainOrder.new(1), IncludedOrder.new(1), InheritedOrder.new(1), ReopenedOrder.new(1), OwnOrder.new(1), NilOrder.new ].each do |x|
  begin; p(x < a); rescue NoMethodError, ArgumentError => e; p e.class; end
  begin; p(x <= a); rescue NoMethodError, ArgumentError => e; p e.class; end
  begin; p(x > a); rescue NoMethodError, ArgumentError => e; p e.class; end
  begin; p(x >= a); rescue NoMethodError, ArgumentError => e; p e.class; end
  begin; p x.between?(lo, hi); rescue NoMethodError, ArgumentError => e; p e.class; end
  begin; p x.clamp(lo, hi).equal?(x); rescue NoMethodError, ArgumentError => e; p e.class; end
  p(x == a)
  p(x != a)
end
# Ordering collections keep using <=> without requiring Comparable.
[ [PlainOrder.new(2), IncludedOrder.new(1), PlainOrder.new(0)] ].each do |xs|
  p xs.sort.map { |v| v.n }
  p xs.min.n
  p xs.max.n
end
# The identical receiver is equal even when Comparable's <=> returns nil.
n = NilOrder.new
[n, 0].each do |x|
  p(x == n)
  p(x != n)
end
class DefaultOrder
  include Comparable
end
d = DefaultOrder.new
[d, 0].each do |x|
  begin; p(x < d); rescue ArgumentError => e; p e.class; end
end
