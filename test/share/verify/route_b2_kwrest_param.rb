class K; def set(**kw) = (@a = kw[:x]); def a = @a; end
o = K.new
s = +"abc"
o.set(x: s)
(o.a) << "?"
p s
p(o.a)
