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
