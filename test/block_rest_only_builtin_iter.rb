# A lone rest parameter never spreads the one value a builtin iterator
# yields: `|*r|` gets `[x]`, even when x is itself an Array.

[[1, 2]].each { |*r| p r }
[[1, 2]].reverse_each { |*r| p r }
[["a", "b"]].each { |*r| p r }
[[[1]]].each { |*r| p r }
[1, [2, 3]].each { |*r| p r }
[{a: 1}].each { |*r| p r }
{a: 1}.each { |*r| p r }
p [[1, 2], [3]].map { |*r| r }
p [[1, 2]].select { |*r| r.size == 1 }
p [[1, 2]].find { |*r| r.size == 1 }
p [[1, 2]].count { |*r| r.size == 1 }
p [[1, 2]].sum { |*r| r.size }
[[1, 2]].each_slice(1) { |*r| p r }
[[1, 2]].each_with_index { |*r| p r }
2.times { |*r| p r }
