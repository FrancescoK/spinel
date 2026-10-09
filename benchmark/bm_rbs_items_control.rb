# The control for bm_rbs_items.rb (tools/rbs_bench.rb): the same loop over a
# method inference already types precisely, every bag holding an array. Its
# annotation says what inference already knows, and changes nothing.
class Bag
  def initialize(items)
    @items = items
  end

  #: () -> Array[Integer]
  def items
    @items
  end
end

n = (ARGV[0] || 3_000_000).to_i
bags = Array.new(64) { |i| Bag.new(Array.new(i % 7 + 1) { |j| j }) }
t = 0
i = 0
while i < n
  t += bags[i & 63].items.size
  i += 1
end
p t
