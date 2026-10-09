s = +"abc"
t = s
[s].map { it }[0] << "!"
p s
p t
