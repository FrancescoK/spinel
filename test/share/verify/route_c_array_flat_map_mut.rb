s = +"abc"
t = s
[s].flat_map { [_1] }[0] << "!"
p s
p t
