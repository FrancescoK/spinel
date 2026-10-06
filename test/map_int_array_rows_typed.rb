# A block of map or each over a table of Integer Arrays -- an Array literal
# of them, or a constant built as one -- binds each row as the Integer Array
# it is, so what the block builds from it is typed: a constant built by
# mapping such a table reads back typed rows (optcarrot's APU clock table).
# Rows of any other kind, an empty row and a second block parameter keep the
# boxed path, and so does a constant table a push gives another kind of
# row: only an index store was looked at, so its String row read back as
# Integers.

CC = 12
CLOCKS = [
  [7458, 7456, 7458, 7458],
  [7458, 7456, 7458, 7458 + 7452]
].map { |a| a.map { |n| CC * n } }
FRAME = [29830, 1, 1, 29828].map { |n| CC * n }
p CLOCKS, CLOCKS[1][3] + 1, CLOCKS.size, FRAME[0]

class Apu
  def initialize(mode) = @clocks = CLOCKS[mode]
  def tick(i) = @clocks[i] * 2
end
p Apu.new(0).tick(1), Apu.new(1).tick(3)

lit = [[1, 2], [3, 4]].map { |r| r.sum + r.size }
p lit
sums = []
[[5, 6], [7]].each { |r| sums << r.first * 10 }
p sums
TBL = [[1, 2], [3, 4]]
p TBL.map { |r| r.map { |x| x * x } }, TBL.map { |r| r.reverse }[0][0] + 100
TBL.each { |r| p r.max - r.min }

grown = [[1], [2]].map { |r| r << 9; r.size }
p grown
nxt = [[1, 2], [3]].map { |r| next [0] if r.size == 1; r.map { |x| -x } }
p nxt
mixed = [[1, 2], ["a"]].map { |r| r.size }
empty_row = [[1, 2], []].map { |r| r.size }
pairs = [[1, 2], [3, 4]].map { |a, b| a + b }
p mixed, empty_row, pairs

ROWS = [[1, 2]]
ROWS << ["x", "y"] if ARGV.size < 9
p ROWS.map { |r| r.size }
p ROWS[0], ROWS[1], ROWS.size
ROWS.each { |r| p r.first }
