S = Struct.new(:a)
o = S.new(+"")
s = +"abc"
o.a = s
s << "!"
p(o.a)
p s
