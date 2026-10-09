c = [true, false].first
s = +"abc"
x = c ? s : nil
s << "!"
p(x)
p s
