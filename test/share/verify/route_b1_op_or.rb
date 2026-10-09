x = nil
s = +"abc"
x ||= s
s << "!"
p(x)
p s
