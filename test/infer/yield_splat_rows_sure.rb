# A table's row spread into a block, `yield(*row)` of an Integer table's row,
# binds sp_int once the rows are typed after the fixpoint, marked nullable
# since a row may be short. A local assigned an array literal once and never
# changed holds every element it was given: `yield(*pair)` binds them as
# unmarked sp_int with no length test.
def each_row(table)
  table.each { |row| yield(*row) }
end
def each_pair(n)
  pair = [3, 4]
  i = 0
  while i < n
    yield(*pair)
    i += 1
  end
end
table = Array.new(4) { |i| [i, i + 1, i + 2] }
t = 0
each_row(table) { |a, b, c| t += a + b * c }
each_row(table) { |d, e, f| p [d, :s, e + f] }
each_pair(3) { |g, h| t += g * h; p [g, :s] }
p t
