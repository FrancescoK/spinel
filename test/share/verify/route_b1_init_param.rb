class K; def initialize(v) = (@a = v); def a = @a; end
s = +"abc"
o = K.new(s)
s << "!"
p(o.a)
p s
