s = +"abc"
t = s
[s].filter_map { _1 }[0] << "!"
p s
p t
