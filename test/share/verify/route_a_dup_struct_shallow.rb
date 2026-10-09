S = Struct.new(:a)
s = +"abc"
r = S.new(s).clone.a
r << "!"
p s
p r
