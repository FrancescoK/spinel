# A block over a boxed receiver runs inline for a builtin, through the
# dispatch for a program's own each
# Where a class of the program has an each of its own, a boxed receiver's
# `each { }` made the block a proc and called the run-time dispatch for
# every receiver. Now an Array, Hash, Range or Enumerator walks inline, and
# any other value still goes to the dispatch. Both arms see the same
# captured locals, `next`, `break` and the call's value.

class Bag
  def initialize(*xs) = @xs = xs
  def each
    @xs.each { |x| yield x * 10 }
    :bag_done
  end
end

def total(v)
  sum = 0
  v.each { |x| sum += x }
  sum
end

def first_big(v)
  found = nil
  v.each do |x|
    next if x < 3
    found = x
    break
  end
  found
end

def walk(v)
  seen = []
  r = v.each { |x| seen << x }
  [seen, r.is_a?(Bag) ? :bag : r]
end

values = [[1, 2, 3, 4], Bag.new(1, 2), (1..3), [5, 6].each]
values.each do |v|
  p total(v), first_big(v)
end
p walk([7, 8]), walk(Bag.new(4))
h = { a: 1, b: 2 }
h.each { |k, x| p [k, x] }
p total([[1, 2], 3].flatten), total(Bag.new(3, 4))

# a nested walk whose inner receivers are Arrays and Bags in turn
grid = [[1, 2], Bag.new(3), [4]]
count = 0
grid.each { |row| row.each { |x| count += x } }
p count

# the receiver kinds the inline walk takes, each read out of a box
def box(x) = [x, Bag.new].first
gen = box(Enumerator.new { |y| n = 0; loop { y << (n += 1) } })
got = []
gen.each { |x| got << x; break if x == 3 }
p got
got = []
box(1..1_000_000).each { |x| got << x; break if x >= 4 }
p got
p(box(1...4).each { |x| x })
hh = box({ a: 1, b: 2 })
hh.each { |kv| p kv }
hh.each { |k, x| p [k, x] }

# break, return, next, raise and the call's value in both arms
def brk(v) = v.each { |x| break x * 2 if x > 1 }
p brk(box([1, 2, 3])), brk(box(Bag.new(5, 6)))
def ret(v)
  v.each { |x| return x * 3 if x > 1 }
  :none
end
p ret(box([1, 2, 3])), ret(box(Bag.new(0, 4)))
out = []
box([1, 2, 3]).each { |x| next if x == 2; out << x }
p out
begin
  box([1, 2]).each { |x| raise ArgumentError, "at #{x}" if x == 2 }
rescue ArgumentError => ex
  p ex.message
end

# a block passed as a Symbol or a Proc, and a receiver the block grows
class Cell
  attr_reader :n
  def initialize(n) = @n = n
  def tick = (@n += 1)
end
class Pack
  def initialize(*xs) = @xs = xs
  def each(&b) = @xs.each(&b)
end
rows = [[Cell.new(1), Cell.new(2)], Pack.new(Cell.new(3))]
rows.each { |row| row.each(&:tick) }
pr = proc { |c| c.tick }
rows.each { |row| row.each(&pr) }
p rows.first.map(&:n)
grow = box([1, 2, 3])
seen = []
grow.each { |x| seen << x; grow << 9 if x == 1; grow.pop if x == 2 }
p seen, grow

# an Enumerator walks inline too: a materialized one answers its source, a
# generator its body's value, the body running once
p(box([1, 2, 3].each).each { |x| x })
runs = 0
gen2 = box(Enumerator.new { |y| runs += 1; y << 1; y << 2; :body_done })
seen = []
gen2.each { |x| seen << x }
p seen, runs
runs = 0
p gen2.each { |x| x }, runs
def walk_gen(g) = g.each { |x| x }
runs = 0
p walk_gen(gen2), runs

# reverse_each keeps the dispatch beside a class with one of its own,
# whose walk ends where the block shortened the Array
class Rev
  def reverse_each = yield(42)
end
Rev.new.reverse_each { |x| p x }
def mk(x) = [x, 1].first
shrink = mk([1, 2, 3, 4])
out = []
shrink.reverse_each { |x| shrink.pop(2) if x == 4; out << x }
p out

# a boxed each inside a split's dispatch arm (the block's proc) takes the
# dispatch: the inline arm keeps its inner splits, the proc does not split
# again
def nest3(v)
  n = 0
  box(v).each { |a| box(a).each { |b| box(b).each { |x| n += x } } }
  n
end
p nest3([[[1, 2]], [[3]]])
