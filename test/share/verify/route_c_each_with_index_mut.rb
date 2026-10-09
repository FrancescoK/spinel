s = +"abc"
t = s
[s].each_with_index { |x, i| x << "!" }
p s
p t
