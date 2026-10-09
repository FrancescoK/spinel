class K; def set(v) = (@a ||= v); def a = @a; end
o = K.new
s = +"abc"
o.set(s)
s << "!"
p(o.a)
p s
