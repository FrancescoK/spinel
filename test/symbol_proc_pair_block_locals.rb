# Several `&:m` blocks in one scope, one of them over a chain that yields two
# values, each bind their own element; an operator symbol over such a chain
# takes the second value as its argument.
p [[1, 2], [3]].each_with_index.map(&:first)
p [1, 2].map(&:-@)
p [[1], [2, 3]].map(&:last)
p ["a", "b"].map(&:upcase)
p [10, 20].each_with_index.map(&:+)

def mix
  a = [[1, 2], [3]].each_with_index.map(&:first)
  b = [1.5, 2.5].map(&:floor)
  c = [:x, :y].map(&:to_s)
  d = [[1, 2], [3]].each_with_index.map { |_spx| _spx.first }
  [a, b, c, d]
end
p mix

p [3, 4].each_with_index.map(&:[])
p %w[a b].each_with_index.map(&:*)
p [5, 6].each_with_index.map(&:-)
p (1..3).each_with_index.map(&:+)
p [10, 20].each.with_index.map(&:+)
p [1, 2, 3].inject(&:+)

def run(e)
  [e.map(&:first), [1, 2].map(&:-@), ["a"].map(&:upcase)]
end
p run([[1, 2], [3]].each_with_index)
