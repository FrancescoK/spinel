def m(v); return v, 1; end
s = +"abc"
x, _ = m(s)
s << "!"
p(x)
p s
