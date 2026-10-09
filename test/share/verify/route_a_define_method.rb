class K; define_method(:keep) { |x| @k = x }; def k = @k; end
s = +"abc"
o = K.new; o.keep(s); r = o.k
r << "!"
p s
p r
