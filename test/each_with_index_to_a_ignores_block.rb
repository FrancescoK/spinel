# each_with_index.to_a and .entries take no block: one given is never
# called, and the answer is the [element, index] pairs
a = %w[x y]
calls = 0
p a.each_with_index.to_a { |n, i| calls += 1; n * 2 }
p a.each_with_index.entries { |n, i| calls += 1; 0 }
p [3, 4].each_with_index.to_a { |n, i| n + i }
p calls
