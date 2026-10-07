# chunk_while, slice_when, chunk, slice_before and slice_after yield one
# value per step, the chunk, so a block chained straight onto them binds
# each chunk as that one value: &:sum sums the chunk, |*r| collects [chunk].
# Spread as yielded arguments, &:sum called 1.sum(2).
a = [1, 2, 4]
p a.chunk_while { |x, y| y == x + 1 }.map(&:sum)
p a.slice_when { |x, y| y != x + 1 }.map(&:size)
p a.chunk_while { |x, y| y == x + 1 }.map(&:first)
p a.chunk_while { |x, y| y == x + 1 }.filter_map(&:first)
p a.chunk { _1.odd? }.map(&:last)
p a.chunk { _1.odd? }.map { |k, v| [k, v.size] }
p "ab cd".each_char.chunk_while { |x, y| y != " " }.map(&:join)
p a.chunk_while { |x, y| y == x + 1 }.map { |*r| r }
p a.chunk { _1.odd? }.map { |*r| r }
p a.chunk_while { |x, y| y == x + 1 }.map { |x| x }
p a.chunk_while { |x, y| y == x + 1 }.map { |x, y| [x, y] }
p [1, 2, 3, 6].slice_before { _1 > 2 }.map(&:sum)
p [1, 2, 3, 6].slice_after(&:odd?).map(&:size)
runs = a.chunk_while { |x, y| y == x + 1 }
p runs.map(&:sum)
p [[1, 2], [3]].each.map { |*r| r }
p [[1, 2], [3]].each_with_index.map { |*r| r }
