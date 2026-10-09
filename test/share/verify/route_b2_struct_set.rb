S = Struct.new(:a)
o = S.new(+"")
s = +"abc"
o.a = s
(o.a) << "?"
p s
p(o.a)
