s = +"abc"
r = {a: {b: s}}.dig(:a, :b)
r << "!"
p s
p r
