s = +"abc"
t = s
s.then { _1 } << "!"
p s
p t
