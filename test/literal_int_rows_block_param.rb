# A constant built by a map over a literal table of Integer rows, whose
# rows are only ever read by an index, hands the map's block each row as the
# Integer array the row's literal built. The block's parameter was bound
# boxed, so `row.map { |n| ... }` answered boxed values, and a constant built
# that way (optcarrot's OSCILLATOR_CLOCKS) boxed every slot computed from its
# rows: an Integer read back through a box. Everything else keeps the
# general Array: `each`'s value is the literal itself, a map's result held
# anywhere but such a constant hands its rows on, and a row stored into,
# copied or handed on, or one the block does more than read, needs rows
# that take any element.
SCALE = 12
CLOCKS = [
  [7458, 7456, 7458, 7458],
  [7458, 7456, 7458, 7458 + 7452]
].map { |a| a.map { |n| SCALE * n } }

class Counter
  def initialize = (@clocks = CLOCKS[0]; @counter = 0)
  def pick(i)
    @clocks = CLOCKS[i]
    self
  end
  def step(k) = (@counter += @clocks[k] * 2)
  attr_reader :counter
end

c = Counter.new
c.step(0)
c.pick(1)
c.step(3)
p c.counter
p c.counter + 1
p CLOCKS[1][3]

# not a constant's map: the rows stay general
total = 0
[[1, 2], [3, 4]].each { |row| total += row.sum + row[0] }
p total
p [[1, 2], [3]].map { |row| row.size * 10 }

# a block that hands its row on, stores into it or answers it keeps the
# general Array: the row may take an element of another kind there
[[1, 2], [3]].each { |row| row << "s"; p row }
p [[1, 2], [3]].map { |row| row }
[[1, 2], [3]].each { |row| r2 = row; r2 << 1.5; p r2 }
def grow(r) = r.push(:x)
p [[1], [2]].map { |row| grow(row) }
p [[1, 2], [3, nil]].map { |row| row.compact.sum }

# a nil or empty row is no Integer array to bind
p [[1, 2], nil].map { |row| row.nil? ? 0 : row.size }
p [[1, 2], []].map { |row| row.size }
begin
  [[1, 2], nil].each { |row| p row.size }
rescue NoMethodError => e
  p e.class
end

# each answers the literal; a local's map hands its rows on; a constant's
# rows stored into take any element
a = [[1, 2], [3, 4]].each { |row| row.sum }
a << "x"
p a, a.frozen?
y = [[1, 2], [3, 4]].map { |row| row.map { |n| n * 2 } }
y[0] << "s"
p y
z = [[1, 2], [3, 4]].map { |row| row.first(1) }
z[0] << 2.5
p z
GROWN = [[1, 2], [3, 4]].map { |row| row.map { |n| n + 1 } }
GROWN[0] << "s"
p GROWN

# a mapped constant whose rows leave through another name
T = [[1, 2], [3]].map { |a| a.sort }
x = T[0]
x << "s"
p T
U = [[1, 2], [3]].map { |a| a.map { |n| n + 1 } }
def mut(r) = r.push("s")
mut(U[1])
p U
V = [[1, 2], [3]].map { |a| a.reverse }
V.each { |r| r << 1.5 }
p V
W = [[1, 2], [3]].map { |a| a.take(1) }
w = W[0].map { |n| n }
w << "s"
p w
