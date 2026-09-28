# An item one generator handed out, yielded as one value by another, stays
# one value: an Array a multi-value step packed is not spread again.
g = Enumerator.new { |y| y.yield(1, 2); y << 3 }
a = g.to_a[0]
h = Enumerator.new { |y| y.yield(a); y.yield(5, 6) }
h.each { |x| p x }
[h, 0][0].each { |x| p x }
p h.map { |x| x }
p [h, 0][0].map { |x| x }
p [h, 0][0].count { |x| x.is_a?(Array) }
k = Enumerator.new { |y| y.yield(*[a]) }
p k.map { |x| x }
