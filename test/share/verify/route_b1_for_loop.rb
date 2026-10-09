x = nil
s = +"abc"
for e in [s] do x = e end
s << "!"
p(x)
p s
