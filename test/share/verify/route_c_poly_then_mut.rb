s = +"abc"
t = s
[s, 1][0].then { _1 } << "!"
p s
p t
