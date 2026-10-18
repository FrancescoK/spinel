# A constant table of Integer rows, whose rows are held by an instance
# variable that is only read by an index, in the arms of a `case`. The
# table's rows can be Integer arrays only when each write that holds one is
# a statement whose value is thrown away; rows_value_dropped did not climb
# this shape, so the write was taken for a value that is kept and the
# table's rows stayed boxed. The output is the same either way: the
# generated C reads the rows unboxed now.
CLOCKS = [[1, 2], [3, 4]].map { |row| row.map { |n| 12 * n } }

class Channel
  def initialize
    @clocks = nil
  end

  def setup(i)
    case i
    when 0
      @clocks = CLOCKS[0]
    when 1
      @clocks = CLOCKS[1]
    else
      @clocks = CLOCKS[0]
    end
    nil
  end

  def clock(j) = @clocks[j]
end

c = Channel.new
c.setup(1)
p c.clock(0)
c.setup(0)
p c.clock(1)
c.setup(5)
p c.clock(0)
