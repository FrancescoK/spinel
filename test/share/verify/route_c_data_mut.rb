s = +"abc"
t = s
D = Data.define(:a); D.new(a: s).a << "!"
p s
p t
