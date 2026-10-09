class K; def initialize(a:) = (@a = a); def a = @a; end
s = +"abc"
o = K.new(a: s)
(o.a) << "?"
p s
p(o.a)
