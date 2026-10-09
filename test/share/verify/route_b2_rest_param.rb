class K; def set(*v) = (@a = v[0]); def a = @a; end
o = K.new
s = +"abc"
o.set(s)
(o.a) << "?"
p s
p(o.a)
