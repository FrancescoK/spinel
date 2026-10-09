# One call site an RBS signature narrows (tools/rbs_bench.rb). Some bags hold
# no array, so `items` returns either an instance variable or a shared
# default; without the annotation inference sees a boxed value there, and
# every `.size` in the loop is dispatched at run time. With it, `items`
# returns an Array[Integer] and `.size` is a direct call.
class Bag
  EMPTY = [0]

  def initialize(items)
    @items = items
  end

  #: () -> Array[Integer]
  def items
    @items || EMPTY
  end
end

n = (ARGV[0] || 3_000_000).to_i
bags = Array.new(64) { |i| Bag.new(i.even? ? Array.new(i % 7 + 1) { |j| j } : nil) }
t = 0
i = 0
while i < n
  t += bags[i & 63].items.size
  i += 1
end
p t
