# A small sum retains the seed representation for these element types.
n = (ARGV[0] || "16").to_i
a = Array.new(n) { |i| "ab" }
s = a.sum("")
p s.size
m = Array.new(n) { |i| i.even? ? "ab" : "cd" }
m << 1 if n < 0
p m.sum("").size
aa = Array.new(n) { |i| [i] }
p aa.sum([]).size
