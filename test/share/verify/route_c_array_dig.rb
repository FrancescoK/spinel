s = +"abc"
t = s
[[s]].dig(0, 0) << "!"
p s
p t
