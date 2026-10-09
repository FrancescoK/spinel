class K; def set(*v) = (@a = v[0]); def a = @a; end
o = K.new
s = +"abc"
o.set(s)
s << "!"
p(o.a)
p s
