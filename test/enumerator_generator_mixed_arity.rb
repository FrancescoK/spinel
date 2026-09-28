# A generator that yields several values in some steps and one in others
# keeps each step's arity: a lone |x| takes the first of a step's values but
# a yielded Array whole, |*r| spreads only a step of several values, and the
# Ruby-defined Enumerable methods a boxed one runs hand their block what
# CRuby's do.
g = Enumerator.new { |y| y.yield([1, 2]); y.yield(3, 4); y << 5 }
p g.map { |x| x }
p g.map { |*r| r }
p g.map { |a, b| [a, b] }
p g.to_a
p g.first(3)
p g.select { |x| x }
g.each { |x| p x }
p g.find_index { |x| x == 3 }
p g.take_while { |x| x != 5 }

e = [g, 1][0]
p e.map { |x| x }
p e.map { |*r| r }
e.each { |x| p x }
p e.flat_map { |x| [x] }
p e.filter_map { |x| x }
p e.count { |x| x.is_a?(Array) }
p e.any? { |x| x == 3 }
p e.all? { |x| x != 4 }
p e.none? { |x| x == 3 }
p e.one? { |x| x == [1, 2] }
p e.find_index { |x| x == 3 }
p e.take_while { |x| x != 5 }
p e.find { |x| x == [3, 4] }
p e.min_by { |x| x.is_a?(Array) ? x.sum : x }

h = Enumerator.new { |y| y.yield(*[7, 8]); y.yield(*[9]); y.yield(*[[1, 2]]) }
p h.map { |x| x }
p h.map { |*r| r }
p h.to_a

s = Enumerator.new { |y| y << 1; y << 2; y << 3 }
p s.find { |x| x == 2 }
p s.take_while { |x| x < 3 }
p s.next

xs = [[1, 2], [3], [[4, 5]]]
k = Enumerator.new { |y| xs.each { |x| y.yield(*x) } }
p k.map { |x| x }
p k.map { |*r| r }
p k.to_a
