c = [true, false].first
s = +"abc"
x = c ? s : nil
(x) << "?"
p s
p(x)
