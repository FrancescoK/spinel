a = [1, "a", :b]
acc = 0
r = a.inject(0) { |*| acc += 1; 0 }
p acc
p r
p a.reduce(0) { |s, *| s + 1 }
p [1, 2].inject(0) { 5 }
p [1, 2].inject(0) { |s| s + 1 }
p [1, 2].inject(0) { |*| 5 }
p [1, 2].inject(0) { |s, *| s + 1 }
p [1.5, 2.5].reduce(1.0) { |s| s * 2 }
p [1, 2].inject(0) { _1 + 1 }
p [1, 2].inject(0) { it + 1 }
p ["x", "y"].inject("") { |s, *| s + "." }
