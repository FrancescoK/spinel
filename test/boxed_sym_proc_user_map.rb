# &:m over a boxed receiver whose map may be a user method yielding two
# values: m is called on the first with the second

class V
  attr_reader :n

  def initialize(n)
    @n = n
  end

  def +(other = V.new(100)) = V.new(n + other.n)
end

class Two
  def map = [yield(V.new(1), V.new(2))]
end

class Pairs
  def map = [yield([1, 2, 3], 2), yield([4, 5], 1)]
end

xs = [Two.new, [V.new(5), V.new(6)]]
xs.each { |x| p x.map(&:+).map(&:n) }

ys = [Pairs.new, [[7, 8], [9]]]
ys.each { |y| p y.map(&:first) }
ys.each { |y| p y.map(&:last) }
