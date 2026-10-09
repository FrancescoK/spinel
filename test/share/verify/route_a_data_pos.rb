D = Data.define(:a)
s = +"abc"
r = D.new(s).a
r << "!"
p s
p r
