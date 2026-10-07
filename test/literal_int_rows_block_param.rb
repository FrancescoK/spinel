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

# a table built in place (a local narrowed to one, a method's answer) runs
# its rows in source order: a row a call answers runs before a row literal
# whose element reads what that call did; a constant's map over such a
# table builds it as before
BUILT = []
def make_row = (BUILT << 1; [10, 20])
ORDERED = [make_row, [BUILT.size, 5]].map { |r| r.map { |n| n + 1 } }
p ORDERED[0][1], ORDERED[1][0]
held = [make_row, [BUILT.size, 5]]
p held[0][1], held[1][0]
def table_of_rows = [make_row, [BUILT.size, 5]]
tr = table_of_rows
p tr[0][1], tr[1][0]

# a constant's rows bind as Integer arrays only when each is a literal of
# Integers no later inference can widen: literals, unary minus, Integer
# constants and arithmetic over them
ROW_BASE = 7
ROW_NEG = -ROW_BASE
SETTLED = [[ROW_BASE, -ROW_BASE, (ROW_BASE + 1) * 2], [ROW_NEG % 5, 10 / 3 - 1]].map { |r| r.map { |n| n * 3 } }
p SETTLED[0][2], SETTLED[1][0], SETTLED[1][1]
# a global that later holds a String, a method's Integer answer: the row is
# built as the general Array it is
$row_v = 3
$row_v = "s" if ARGV.size > 5
def row_v = $row_v
GLOBAL_ROW = [[1, 2], [row_v, 5]].map { |r| r.map { |n| n * 2 } }
p GLOBAL_ROW[1][0], GLOBAL_ROW[1][1]
def row_id(x) = x
CALL_ROW = [[1, 2], [row_id(4), 5]].map { |r| r.map { |n| n + 1 } }
p CALL_ROW[1][0], CALL_ROW[1][1]
def row_four = 4
METHOD_ROW = [[1, 2], [row_four, 5]].map { |r| r.map { |n| n + 1 } }
p METHOD_ROW[1][0]
