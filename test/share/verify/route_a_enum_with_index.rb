s = +"abc"
r = nil; [s].each.with_index { |x, i| r = x }
r << "!"
p s
p r
