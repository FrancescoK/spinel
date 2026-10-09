class K; class << self; def keep(v) = (@a = v); def a = @a; end; end
s = +"abc"
K.keep(s)
s << "!"
p(K.a)
p s
