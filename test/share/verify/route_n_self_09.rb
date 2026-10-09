s = +"abc"
t = s
s.tr!(s, "x")
p s, t
