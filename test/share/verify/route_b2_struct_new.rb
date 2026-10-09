S = Struct.new(:a)
s = +"abc"
o = S.new(s)
(o.a) << "?"
p s
p(o.a)
