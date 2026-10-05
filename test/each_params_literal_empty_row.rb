# `each` with two or more block parameters over a literal table spreads each
# row over the parameters. An empty row has no kind of its own, so the
# parameters took the other rows' Integer and the empty row was read as an
# Integer Array: 0 where CRuby binds nil.
[[1, 2], [], [3, 4]].each { |a, b| p [a, b] }
[[1, 2], [], [3, 4]].reverse_each { |a, b| p [a, b] }
[[1, 2, 3], [], [4, 5, 6]].each { |a, b, c| p [a, b, c] }
[[], [1, 2]].each { p [_1, _2] }
x = 3
[[1, 2], [], [x, 4]].each { |a, b| p [a, b] }
[[1, 2], []].each { |a, b| p a.nil?, b }
[[1, 2], [], [3, 4]].each { |a, b| next if a.nil?; p a * b }
[[1, 2], [], [3, 4]].each { |a, b| v = a || 7; p v + 1 }
[[1.5, 2.5], []].each { |a, b| p a.to_f + 1 }
[[1, 2], Array.new, [3, 4]].each { |a, b| p [a, b] }
[[1, 2], {}, [3, 4]].each { |a, b| p [a, b] }
[[1, 2], [], [3, 4]].each_entry { |a, b| p [a, b] }
# a table with no empty row answers as before
[[1, 2], [3, 4]].each { |a, b| p a + b }
[[1, 2], [3]].each { |a, b| p [a, b] }
