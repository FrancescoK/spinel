# A nested block or lambda parameter named like the yielder shadows it: its
# multi-value yield does not make the generator a multi-value one.
e = Enumerator.new { |y| [].each { |y| y.yield(1, 2) }; y.yield([:a, :b]) }
p e.map { |x| x }
p e.map { |*r| r }
f = Enumerator.new { |y| ->(y) { y.yield(1, 2) }; y << [:c, :d] }
p f.map { |x| x }
p f.map { |*r| r }
g = Enumerator.new { |y| [1].each { |z; y| y = nil }; y.yield([:e, :f]) }
p g.map { |*r| r }
