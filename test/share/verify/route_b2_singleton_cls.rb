class K; class << self; def keep(v) = (@a = v); def a = @a; end; end
s = +"abc"
K.keep(s)
(K.a) << "?"
p s
p(K.a)
