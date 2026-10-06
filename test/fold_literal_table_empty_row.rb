# A fold over a literal table of Integer rows reads each row as an Integer
# Array. An empty row is built as a general Array, so the fold took its
# length for 8 and its storage for eight zeros.
p [[1], [], [2]].inject([]) { |m, v| m + v }
p [[1], [], [2]].inject([7]) { |m, v| m.concat(v) }
p [[], [1], [2]].reduce([]) { |m, v| m | v }
p [[1, 2], [3], []].inject([]) { |m, v| m + v }
p [[1, 2], [], [3]].inject(0) { |n, v| n + v.size }
p [[1, 2], [], [3]].inject([]) { |m, v| m << v.first }
p [[1, 2], [], [3]].inject([]) { |m, v| m << v }
p [[1, 2], [], [3]].inject("") { |s, v| s + v.inspect }
p [[1, 2], [], [3]].inject(false) { |e, v| e || v.empty? }
p [[1, 2], [], [2]].inject(&:|)
p [[], [1, 2], [2]].reduce(&:|)
p [[1, 2], [], [2]].inject(&:&)
p [[1, 2], [2], []].inject(&:-)
p [[1, 2], [], [2]].inject { |a, b| a | b }
p [[1, 2], [2], []].reduce { |a, b| a - b }
p [[]].inject(&:|)
p [[], []].inject(&:|)
r = [[3, 1], [], [2]].inject(&:|)
r << 9
p r, r.max
# a table with no empty row answers as before
p [[1, 2], [2, 3]].inject(&:&)
p [[1], [2]].inject([]) { |m, v| m + v }
