s = +"abc"
t = s
[s].each.with_object([]) { |x, acc| x << "!" }
p s
p t
