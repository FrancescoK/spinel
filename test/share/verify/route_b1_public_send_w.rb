class K; attr_accessor :a; end
o = K.new
s = +"abc"
o.public_send(:a=, s)
s << "!"
p(o.a)
p s
