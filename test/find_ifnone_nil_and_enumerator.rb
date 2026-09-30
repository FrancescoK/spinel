p [1, 2, 3].find(nil) { |x| false }
p [1, 2, 3].find(nil) { |x| x == 2 }
p [1, 2, 3].detect(nil) { |x| x > 1 }
p [1, 2, 3].rfind(nil) { |x| false }
p [1, 2, 3].rfind(nil) { |x| x < 3 }
p %w[a bb ccc].find(nil) { |s| s.size == 2 }
p [1, "a", :b].rfind(nil) { |x| x.is_a?(Integer) }
p({a: 1, b: 2}.find(nil) { |k, v| v > 1 })
p((1..5).find(nil) { |x| x > 3 })
p [1, 2, 3].find(nil).class

fp = -> { "cheeseburgers" }
p [1, 2, 3].find(fp).each { |x| false }
p [1, 2, 3].find(fp).each { |x| x == 2 }
p [1, 2, 3].rfind(fp).each { |x| false }
p [1, 2, 3].rfind(fp).each { |x| x < 3 }
e = [1, 2, 3].find(fp)
p e.class
p e.to_a
