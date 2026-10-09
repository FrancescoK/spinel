S = Struct.new(:a, keyword_init: true)
s = +"abc"
o = S.new(a: s)
s << "!"
p(o.a)
p s
