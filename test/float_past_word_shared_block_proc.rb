# A Float past the Integer word reaching a block through the proc a
# dispatch shares (a program class defines a yielding each): the block
# reads the Float, and nothing converts it to an Integer (#9298).
class Bag
  include Enumerable
  def initialize(xs) = (@xs = xs)
  def each
    @xs.each { |x| yield x }
    self
  end
end
def walk(u)
  s = 0.0
  u.each_with_index { |x, j| s += x * (j + 1) }
  s
end
big = [1.0e19, 2.5e30, -3.0e25]
p walk(big)
p walk(Bag.new([1.5, 2.5]))
h = { a: 1.0e20 }.merge({ a: 2.0e20 }) { |k, old, new| old + new }
p h
