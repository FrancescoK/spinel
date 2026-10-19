# A constant table of Integer rows, whose rows are held by an instance
# variable that is only read by an index, in the body, a rescue clause and
# the else of a `begin`, and in a method whose body is a `begin`. The
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
    begin
      @clocks = CLOCKS[0]
    rescue IndexError
      @clocks = CLOCKS[1]
    else
      @clocks = CLOCKS[i % 2]
    end
    nil
  end

  def reset
    @clocks = CLOCKS[0]
  rescue IndexError
    @clocks = CLOCKS[1]
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
c.reset
p c.clock(1)
