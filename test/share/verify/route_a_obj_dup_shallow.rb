class K; attr_accessor :a; end
s = +"abc"
o = K.new; o.a = s; r = o.dup.a
r << "!"
p s
p r
