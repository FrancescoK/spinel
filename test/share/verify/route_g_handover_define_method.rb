class K; define_method(:m) { y = +"a"; @k = y; y }; def k = @k; end
o = K.new
r = o.m
r << "!"
p o.k
