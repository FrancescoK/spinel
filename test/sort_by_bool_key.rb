a = [1, "a", :b]
acc = 0
r = a.sort_by { |*| acc += 1; false }
p acc
p r
p a.sort_by { |x| true }
p [3, 1, 2].sort_by { |x| false }
p [3, 1, 2].sort_by { |x| x > 5 }
b = [3, 1]
b.sort_by! { |x| false }
p b
