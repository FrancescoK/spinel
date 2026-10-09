s = +"abc"
t = s
[s].take_while { true }[0] << "!"
p s
p t
