# A method that yields from a block it passes to another yielding method, which
# in turn yields from a block it passes to a method keeping its block as a proc
# (`&blk` with an enum_for guard). The inner method takes its block as a proc,
# so the block the outer method passes it is a proc of its own, where the
# outer method's caller block is out of reach. When the outer method was
# defined before the inner one, it was still spliced into its caller, and the
# `yield` in its block raised LocalJumpError. Every method whose `yield` sits
# in such a block takes its block as a proc, whatever the order of the
# definitions.
class Box
  def initialize(xs) = @xs = xs

  def each_part(&blk)
    return enum_for(__method__) unless blk
    @xs.each { |x| blk.call(x) }
  end
end

class Walk
  def collect(box)
    out = []
    big(box) { |v| out << v }
    out
  end

  def big(box)
    even(box) do |v|
      next unless v > 1
      yield v * 10
    end
  end

  def even(box)
    box&.each_part do |v|
      next if v.odd?
      yield v
    end
  end

  # three links, each defined before the one it calls
  def top(box, out) = one(box) { |v| out << v }
  def one(box) = two(box) { |v| yield v + 1 }
  def two(box) = three(box) { |v| yield v * 100 }
  def three(box) = box.each_part { |v| yield v if v.even? }

  # the block's value comes back through both yields
  def total(box)
    sum(box) { |v| yield(v * 10) + 1 }
  end

  def sum(box)
    s = 0
    box.each_part { |v| s += yield v }
    s
  end
end

w = Walk.new
p w.collect(Box.new([1, 2, 3, 4]))
p w.collect(Box.new([]))
p w.collect(nil)
out = []
w.top(Box.new([1, 2, 3, 4]), out)
p out
p w.total(Box.new([1, 2])) { |v| v * 2 }

# called without a block: the inner yield raises as CRuby's does
begin
  w.big(Box.new([2]))
rescue LocalJumpError => e
  p e.message
end
