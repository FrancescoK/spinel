S = Struct.new(:a)
s = +"abc"
o = S.new(s)
s << "!"
p(o.a)
p s
