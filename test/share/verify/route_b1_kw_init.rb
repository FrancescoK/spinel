class K; def initialize(a:) = (@a = a); def a = @a; end
s = +"abc"
o = K.new(a: s)
s << "!"
p(o.a)
p s
