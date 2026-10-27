# A blockless take_while / drop_while answers an Enumerator that runs the
# method with the block its consumer gives. to_a's block answers nil, so
# take_while stops and drop_while stops dropping at the first element.

require "set"

class Bag
  include Enumerable

  def initialize(*items)
    @items = items
  end

  def each
    @items.each { |x| yield x }
    self
  end
end

a = [3, 1, 2]
p a.take_while.to_a
p a.drop_while.to_a
p a.take_while.entries
p a.drop_while.to_a { |x| true }
p a.take_while.map { |x| x * 2 }
p a.take_while.count
p a.take_while.size
p a.take_while.first
p a.take_while.each { |x| x > 1 }
p a.drop_while.each { |x| x > 1 }
p a.take_while.with_index.to_a
seen = []
p a.take_while.with_index { |x, i| seen << [x, i]; i < 1 }
p seen

p (3..5).take_while.to_a
p (3..5).drop_while.to_a
p (1..).take_while.first(2)
p({ a: 1, b: 2 }.take_while.to_a)
p({ a: 1, b: 2 }.drop_while.to_a)
p Set[3, 1].take_while.to_a
p Set[3, 1].drop_while.to_a
p Bag.new(3, 1).take_while.to_a
p Bag.new(3, 1).drop_while.to_a

def take_fwd(items, &blk) = items.take_while(&blk)
def drop_fwd(items, &blk) = items.drop_while(&blk)
p take_fwd([3, 1]).to_a
p drop_fwd([3, 1]).to_a
p take_fwd([3, 1, 2]) { |x| x > 2 }
p drop_fwd([3, 1, 2]) { |x| x > 2 }

e = %w[x y].drop_while
p e.class
p e.to_a
