class K; attr_accessor :a; end
o = K.new
s = +"abc"
o.a = s
(o.a) << "?"
p s
p(o.a)
