# The rows of a `[[], []]` literal under an `Array[Array[Integer]]` /
# `Array[Array[Float]]` seed are built at the seed's kind (#4484), though
# a push into a row came before the row had a kind of its own: they were
# built as boxed arrays that the table read back as typed rows, so a row of
# two reported length 10 and its second element read 0.
class Table
  def initialize
    @ints = [[], []]
    @floats = [[], [], []]
  end

  def fill
    @ints[0] << 1
    @ints[0] << 2
    @ints[1] << 7
    @floats[2] << 1.5
    @floats[2] << 2.25
  end

  def report
    p @ints[0].length, @ints[0][1], @ints[1].length
    row = @floats[2]
    p row.length, row[1], @floats[0].length
    p @ints[0][0] + @ints[1][0], @floats[1].empty?
  end
end

t = Table.new
t.fill
t.report

# A nil, or a value whose class is not known until it runs, pushed into such
# a row fits the seed's typed row, as it fits a row of `Array.new(n) { [] }`:
# the rows are still built at the seed's kind.
class NilRows
  def initialize
    @rows = [[], []]
  end

  def fill(v)
    @rows[0] << 1
    @rows[0] << nil
    @rows[1] << v
    @rows[1] << 4
  end

  def report
    p @rows[0].length, @rows[0][1], @rows[1].length, @rows[1][0] + @rows[1][1]
  end
end

n = NilRows.new
n.fill(ARGV.size > 5 ? "s" : 3)
n.report

# An Integer pushed into a Float row is kept as a Float, as a row of
# `Array.new(n) { [] }` keeps it: the rows are still built at the seed's kind.
class MixedFloatRows
  def initialize
    @rows = [[], []]
  end

  def fill
    @rows[0] << 1.5
    @rows[0] << 2
    @rows[1] << 3
  end

  def report
    p @rows[0].length, @rows[0][1] + 0.5, @rows[1].length, @rows[1][0] * 0.5
  end
end

m = MixedFloatRows.new
m.fill
m.report
