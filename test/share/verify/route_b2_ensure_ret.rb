def m(v); return v; ensure; nil; end
s = +"abc"
x = m(s)
(x) << "?"
p s
p(x)
