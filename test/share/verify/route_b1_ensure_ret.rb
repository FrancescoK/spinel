def m(v); return v; ensure; nil; end
s = +"abc"
x = m(s)
s << "!"
p(x)
p s
