# A lazy stage's block binds a rest, an optional or a post parameter as a
# yield of the value would: `|*r|` collects [value], `|x, *r|` splats an
# Array value. The rest was never bound and read nil.
p [[1, 2], [3]].lazy.map { |*r| r }.to_a
p [1, 2].lazy.map { |*r| r }.to_a
p [1, 2].lazy.select { |*r| r.size == 1 }.to_a
p [1, 2].lazy.reject { |*r| r[0] > 1 }.to_a
p [1, 2].lazy.filter_map { |*r| r }.to_a
p [1, 2].lazy.map { |x, *r| [x, r] }.to_a
p [[1, 2], [3, 4]].lazy.map { |x, *r| [x, r] }.to_a
p [1, 2].lazy.map { |x, y = 5| [x, y] }.to_a
p (1..3).lazy.map { |*r| r }.first(2)
p [1, 2].each_slice(1).lazy.map { |*r| r }.to_a
p [[1, 2]].lazy.map { |a, b| a + b }.to_a
p [1, 2, 3].lazy.map { _1 * 2 }.select(&:even?).first(2)
p({a: 1}.lazy.map { |k, v| [k, v] }.to_a)
