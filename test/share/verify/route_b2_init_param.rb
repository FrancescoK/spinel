class K; def initialize(v) = (@a = v); def a = @a; end
s = +"abc"
o = K.new(s)
(o.a) << "?"
p s
p(o.a)
