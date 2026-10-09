
s = +"abc"
x = begin; s; rescue; nil; end
(x) << "?"
p s
p(x)
