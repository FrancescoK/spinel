# A small sum retains the seed representation for these element types.
n = (ARGV[0] || "16").to_i
a = Array.new(n) { |i| "ab" }
m = Array.new(n) { |i| i.even? ? "ab" : 1 }.select { |x| x.is_a?(String) }
aa = Array.new(n) { |i| [i] }
p a.sum("").size
