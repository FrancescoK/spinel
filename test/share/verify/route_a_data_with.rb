D = Data.define(:a)
s = +"abc"
r = D.new(a: +"q").with(a: s).a
r << "!"
p s
p r
