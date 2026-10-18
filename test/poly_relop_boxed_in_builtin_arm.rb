# A comparison on a boxed value, typed boxed because a program class's
# operator of the name answers more than a bool (one through an alias,
# one defined directly), read inside a dispatch's builtin arm: there the
# builtin comparison answers, and its bool is boxed for the call's readers.
class Coll
  def initialize(xs) = @xs = xs
  def each_node
    @xs.each { |x| yield x }
    self
  end
  def size = @xs.empty? ? 0.5 : @xs.size - 2
end

class Fwd
  def initialize(xs) = @xs = xs
  def each_node(&blk) = @xs.each(&blk)
end

class Bag
  def initialize(xs) = @xs = xs
  def covers?(o) = @xs.include?(o) ? o : nil
  alias >= covers?
  def <(o) = @xs.size < o ? :fewer : nil
end

def big?(x)
  x.each_node do |n|
    return true if n.size + 1 >= 3 && n.is_a?(Array)
  end
  false
end

def small?(x)
  x.each_node do |n|
    return true if n.size + 1 < 3 && !n.is_a?(Coll)
  end
  false
end

p big?(Coll.new([[1, 2, 3], [1, 2]]))
p big?(Fwd.new([Coll.new([7, 8, 9])]))
p big?(Fwd.new([[1]]))
p big?(Fwd.new([[1, 2]]))
p small?(Fwd.new([[1]]))
p small?(Coll.new([[1, 2, 3]]))
p Bag.new([1, :a]) >= :a
p Bag.new([1, :a]) >= :b
p Bag.new([1]) < 2
