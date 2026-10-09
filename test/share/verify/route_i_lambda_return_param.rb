id = ->(x) { x }
s = +"abc"
t = id.(s)
t << "!"
p s
