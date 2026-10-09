s = +"abc"
t = s
[s].values_at(0)[0] << "!"
p s
p t
