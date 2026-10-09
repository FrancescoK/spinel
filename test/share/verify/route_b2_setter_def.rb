class K; def a=(v); @a = v; end; def a = @a; end
o = K.new
s = +"abc"
o.a = s
(o.a) << "?"
p s
p(o.a)
