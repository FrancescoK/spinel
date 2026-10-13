# a method that hands its own block on to an Array, a Hash or a Range
# iterator, called without one: the iterator answers its Enumerator

class C
  def initialize(a) = (@a = a)
  def each(&blk) = @a.each(&blk)
  def map(&blk) = @a.map(&blk)
  def each_pair(&blk) = { a: 1 }.each_pair(&blk)
  def each_r(&blk) = (1..3).each(&blk)
  def select(&) = @a.select(&)
end
c = C.new([1, 2])
p c.each.to_a
p c.each { |v| }
p c.map.with_index.to_a
p c.map { |v| v * 3 }
p c.each_pair.to_a
p c.each_r.to_a
p c.each_r { }
p c.select.with_index { |v, i| i == 1 }
p c.select(&:odd?)

# iterators the builtins write in Ruby keep their own block_given? reading
class D
  def initialize(a) = (@a = a)
  def tw(&blk) = @a.take_while(&blk)
  def gb(&blk) = @a.group_by(&blk)
end
d = D.new([1, 2, 3])
p d.tw.class
p(d.tw { |x| x < 2 })
p d.gb.to_a
p(d.gb(&:odd?))
