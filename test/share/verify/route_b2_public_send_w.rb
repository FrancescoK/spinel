class K; attr_accessor :a; end
o = K.new
s = +"abc"
o.public_send(:a=, s)
(o.a) << "?"
p s
p(o.a)
