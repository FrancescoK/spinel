# Every run of a with_index over a generator (#next, include?, first(n)) pulls
# the source through a fiber of its own: one run starting over replaced the
# fiber another was reading, and #next skipped a value.
g = Enumerator.new { |y| y << 10; y << 20; y << 30; y << 40 }
e = g.with_index
p e.next
p e.include?([20, 1])
p e.next
p e.first(2)
p e.next
p [e, 0][0].include?([30, 2])
p e.next
