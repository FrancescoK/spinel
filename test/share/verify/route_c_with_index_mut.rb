s = +"abc"
t = s
[s].each.with_index(1) { |x, i| x << "!" }
p s
p t
