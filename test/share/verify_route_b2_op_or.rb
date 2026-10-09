# spinel: share
x = nil
s = +"abc"
x ||= s
(x) << "?"
p s
p(x)
