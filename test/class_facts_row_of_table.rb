# A row read out of a table is not the table (#10520)
# The class facts took an element read's value to be its receiver too (a
# Proc's `[]` is its call), and `Array.new(n) { row }` to be its block's
# value, so a table was each of its rows: a key stored into one row
# (`seen[c.y][c.x] = true`, the key kept as an element, as a Hash's is)
# reached every read of the table. The store's receiver then held Cell, and
# Cell's members took `true`. A Proc's `[]` still answers its value.

Cell = Struct.new(:x, :y) do
  def dist(o) = (x - o.x).abs + (y - o.y).abs
end

def visited(w, h, walk)
  seen = Array.new(h) { Array.new(w) { false } }
  walk.each { |c| seen[c.y][c.x] = true }
  seen.sum { |row| row.count(true) }
end

cells = (0...60).map { |i| Cell.new(i % 6, i / 6) }
p visited(6, 10, cells.first(20))
s = 0
cells.each { |a| cells.each { |b| s += a.dist(b) } }
p s

# a grid of objects: a push into one cell's own Array is no element of the
# grid's rows
class Other; end
class Spot
  attr_reader :n
  def initialize = @n = []
end
spots = Array.new(2) { Array.new(2) { Spot.new } }
spots[1][1].n << Other.new
p spots[0].size, spots[1][1].n.size

# Procs called with `[]` answer what they answer
class A; def who = "A"; end
class B; def who = "B"; end
make = Proc.new { |x| x.zero? ? A.new : B.new }
p make[0].who, make[1].who
by_key = { a: ->(n) { n > 0 ? A.new : B.new } }
p by_key[:a][1].who, by_key[:a][0].who
fs = [->(n) { A.new }, ->(n) { B.new }]
p fs[1][0].who, fs[0][0].who
add = ->(x, y) { x > y ? A.new : B.new }
p add.curry[2][1].who
dh = Hash.new { |_, key| key == :a ? A.new : B.new }
p dh.default_proc[{}, :b].who, dh[:a].who

# a run of elements read with `[]` is a container holding the receiver's
# elements
mixed = [A.new, B.new, A.new]
p mixed[0, 1].first.who, mixed[0..0].pop.who, mixed[1..].last.who
run = mixed[1, 2]
p run.pop.who, run.first.who
