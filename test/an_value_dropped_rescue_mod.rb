# The append of a row to an instance variable's table, before a rescue
# modifier, as a statement whose value is thrown away. Such a table is read
# as a table of Integer arrays only when every append that answers the table
# is dropped (an alias of the table could be appended to elsewhere);
# an_value_dropped did not climb this shape, so the append was taken for a
# value that is kept and the table stayed a table of boxed rows. The output
# is the same either way: the generated C holds the rows unboxed now.
class Table
  def initialize
    @rows = [[1, 2], [3, 4]]
  end

  def add(r)
    @rows << r rescue nil
    nil
  end

  def at(i, j) = @rows[i][j]
  def size = @rows.size
end

t = Table.new
t.add([5, 6])
t.add([7])
t.add([])
p t.size
p t.at(2, 1)
p t.at(3, 0)
