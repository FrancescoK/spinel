
s = +"abc"
x = begin; s; rescue; nil; end
s << "!"
p(x)
p s
