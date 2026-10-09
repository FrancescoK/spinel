D = Data.define(:a)
s = +"abc"
r = D.new(a: s).a
r << "!"
p s
p r
