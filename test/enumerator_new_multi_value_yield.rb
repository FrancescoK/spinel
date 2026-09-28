# A generator step that yields several values (`y.yield(a, b)`) is one
# multi-value item: a `|*r|` block takes the values spread, a `|a|` block of
# map takes the first, and select/find/to_a see the packed Array.
e = Enumerator.new { |y| y.yield(1, 2); y.yield(3, 4) }
p e.map { |*r| r }
p e.map { |a| a }
p e.map { |a, b| a + b }
p e.to_a
p e.select { |a, b| b > 2 }
p e.find { |a, b| b == 4 }
p e.each_with_object([]) { |x, acc| acc << x }
p e.sort_by { |a, b| -a }
p e.count

k = 10
g = Enumerator.new { |y| y.yield(k, 2); y.yield(3) }
p g.map { |*r| r }
p g.map { |a| a }

h = Enumerator.new { |y| [[1, 2]].each { |x| y.yield(*x) } }
p h.map { |a| a }
p h.map { |*r| r }

def mk
  Enumerator.new { |y| y.yield(:a, 1); y.yield(:b, 2) }
end
p mk.map { |a| a }
p mk.to_h

# Block iterators on an Enumerator reached through a boxed value.
p [[[5, 6]].each_with_index, [[7, 8]].each, [[1, 2]]].map { |en| en.select { |x| x } }
[[3, 1, 2].each, [[5, 6]].each_with_index, [4, 5]].each do |en|
  p en.select { |x| x }
  p en.reject { |x| x == 1 }
  p en.find { |x| x != 3 }
  p en.count { |x| x }
  p en.sort_by { |x| x.to_s }
  p en.each_with_object([]) { |x, acc| acc << x }
  p en.min_by { |x| x.to_s }
  p en.group_by { |x| x.to_s.size }
  p en.partition { |x| x.to_s.size > 1 }
  p en.inject(0) { |s, x| s + 1 }
  p en.map { |x| x }
  p en.first
end

# ... and when a user class defines its own block-taking map/select.
class Box
  def initialize(v) = @v = v
  def map
    [yield(@v)]
  end
  def select
    yield(@v) ? [@v] : []
  end
end
xs = [[3, 1].each, Box.new(9), [[5, 6]].each_with_index, Enumerator.new { |y| y.yield(1, 2) }]
xs.each do |en|
  p en.map { |x| x }
  p en.select { |x| x }
end
p xs.map { |en| en.map { |*r| r } }
