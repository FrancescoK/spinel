# A block of two parameters over a boxed element that is not an Array binds
# the element to the first and nil to the rest: the element was indexed as
# if it were one, so an Integer gave its bits, a String its characters and a
# Hash a key lookup.
a = [[1, 2], 9, "ab", {k: 1}]
p a.map { |x, y| [x, y] }
p a.select { |x, y| y.nil? }
b = [[1, 2], 9]
p b.sum(0) { |x, y| x + (y || 0) }
p b.sort_by { |x, y| y || 0 }
p b.reject { |x, y| y }
p b.inject(0) { |s, (x, y)| s + x + (y || 0) }

g = Enumerator.new { |y| y.yield(1, 2, 3); y << 9 }
p g.map { |a1, b1| [a1, b1] }
p [g, 1][0].map { |a1, b1| [a1, b1] }
