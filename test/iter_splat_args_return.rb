# an iterator that takes no argument, handed a splat with a block: it
# answers what the iterator answers, and a splat that is not empty raises
# CRuby's ArgumentError

class C
  def initialize(a) = (@a = a)
  def each(*args, &blk) = @a.each(*args, &blk)
  def map(*args, &blk) = @a.map(*args, &blk)
  def each_with_index(*args, &blk) = @a.each_with_index(*args, &blk)
end

c = C.new([1, 2])
p c.each { |v| print v, " " }
p c.map { |v| v * 2 }
p c.each_with_index { |v, i| print v + i, " " }

def f(a, *s) = a.each(*s) { |x| print x, " " }
p f([3, 4])
p((f([3], 9) rescue $!.message))
p((f([3], 9, 8) rescue $!.message))

def h(x, *s) = x.select(*s) { |k, v| v > 1 }
p h({ a: 1, b: 2 })
def r(x, *s) = x.map(*s) { |v| v * v }
p r(1..3)
p((r(1..3, :x) rescue $!.message))

# through a value that may be an Array or an object of the class
def g(x) = x.each { |v| }
p g(C.new([5]))
p g([6])
