s = +"abc"
t = s
[s].each_with_index.map { |x, i| x }[0] << "!"
p s
p t
