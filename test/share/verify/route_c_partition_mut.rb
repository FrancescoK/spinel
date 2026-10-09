s = +"abc"
t = s
[s].partition { true }[0][0] << "!"
p s
p t
