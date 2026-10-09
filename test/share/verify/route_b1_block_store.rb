class K; def set = (@a = yield); def a = @a; end
o = K.new
s = +"abc"
o.set { s }
s << "!"
p(o.a)
p s
