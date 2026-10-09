S = Struct.new(:a)
s = +"abc"
x = S.new(s); r = x.dup.a
r << "!"
p s
p r
