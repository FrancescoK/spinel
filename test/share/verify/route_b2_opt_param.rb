class K; def set(v = nil) = (@a = v); def a = @a; end
o = K.new
s = +"abc"
o.set(s)
(o.a) << "?"
p s
p(o.a)
