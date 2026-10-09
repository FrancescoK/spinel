class K; attr_accessor :a; end
o = K.new
s = +"abc"
o.send(:a=, s)
s << "!"
p(o.a)
p s
