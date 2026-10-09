class K; attr_accessor :a; end
s = +"abc"
o = K.new
o.a = s
o.a << "!"
p s
