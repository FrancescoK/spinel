p [5, 6].each_with_index.map { |a| a }
p({a: 1}.each_with_index.map { |a| a })
p [[1, 2]].each_with_index.map { |a| a }
p [5, 6].each.with_index(1).map { |a| a }
p [5, 6].each_with_object([]).map { |a| a }

# the iterators that hand both values to the block give `|a|` the first
p [5, 6].each_with_index.flat_map { |a| [a, a] }
p [5, 6].each_with_index.filter_map { |a| a * 2 if a > 5 }
p [5, 6].each_with_index.count { |a| a > 5 }
p [5, 6].each_with_index.find_index { |a| a == 6 }
p [5, 6].each_with_index.any? { |a| a == 6 }
p [5, 6].each_with_index.all? { |a| a > 4 }
p [5, 6].each_with_index.none? { |a| a > 6 }
p [5, 6].each_with_index.take_while { |a| a < 6 }
p [5, 6].each.with_object(:o).map { |a| a + 1 }
p %w[x y].each_with_index.map { |s| s.upcase }

# the ones that pack them give it the [element, index] pair
p [5, 6].each_with_index.select { |a| a == [6, 1] }
p [5, 6].each_with_index.sort_by { |a| -a[1] }
p [5, 6].each_with_index.max_by { |a| a[1] }
p [5, 6].each_with_index.find { |a| a[0] == 6 }

# `_1` and `it` bind like `|a|`
p [5, 6].each_with_index.map { _1 * 10 }
p [1.5, 2.5].each.with_index(1).map { it * 2 }
p({a: 1, b: 2}.each_with_index.map { _1 })
p [5, 6].each_with_index.select { _1 == [5, 0] }

class Box
  def initialize = @xs = [3, 4]
  def scaled = @xs.each_with_index.map { |x| x * 10 }
  def firsts(ys) = ys.each.with_index(1).map { it }
end
p Box.new.scaled
p Box.new.firsts([7, 8])
