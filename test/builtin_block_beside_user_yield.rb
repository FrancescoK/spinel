# A block handed to a builtin iterator, beside a class of the program's own
# that is the only one to define a yielding method of that name (Set#map,
# when `to_set` loads Set, did the same). Under --int-overflow=promote the
# widening after the fixpoint read the name alone, took the user method as
# the call's target and typed the block's parameter from its boxed yield;
# the each_slice / each_cons chains bind the slice itself, so the C did not
# build. A second class defining the name hid the bug, so there is one.
class Bag
  def initialize = @d = [1, "a"]
  def map = @d.map { |x| yield(x) }
  def each
    @d.each { |x| yield(x) }
    self
  end
end
g = Bag.new
p g.map { |v| v.to_s }
g.each { |v| p v }

b = [3, 1, 2]
p b.each_slice(1).map(&:first)
p b.each_slice(2).map { |s| s.sum }
p b.each_slice(2).map { |(x, y)| [x, y] }
p b.each_cons(2).map(&:first)
p b.each_cons(2).map { |(x, y)| x + y }
p (1..4).each_slice(2).map(&:sum)
p (1..4).each_cons(2).map(&:sum)
p [1.5, 2.5].each_slice(1).map(&:first)
p ["x", "y"].each_slice(1).map(&:first)
b.each { |v| p v + 1 }
p b.map { |v| v * 2 }

