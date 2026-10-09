s = +"abc"
t = s
l = ->(x) { x << "!" }; l.(s)
p s
p t
