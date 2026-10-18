# `size` on a boxed value inside a block a dispatch lifts into a proc (the
# default arm of a call whose other arm splices the block in): the call is
# typed boxed when a program class's size answers more than an Integer,
# and its value is read as that box.
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

def has_one?(x)
  x.each_node do |n|
    return true if n.size + 1 == 2
  end
  false
end

def lens(x)
  out = []
  x.each_node { |n| out << n.length + 1 }
  out
end

p has_one?(Coll.new([[1, 2, 3], [1, 2]]))
p has_one?(Coll.new([[1], "ab"]))
p has_one?(Fwd.new([Coll.new([7, 8, 9])]))
p has_one?(Fwd.new([Coll.new([])]))
p has_one?(Fwd.new([[1]]))
p lens(Fwd.new([[1, 2], "abc"]))
p lens(Coll.new(["x"]))
p Coll.new([]).size
