s = +"abc"
t = s
s.freeze.dup << "!"
p s
p t
