s = +"abc"
t = s
[[1, s]].to_h[1] << "!"
p s
p t
