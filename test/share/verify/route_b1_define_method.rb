class K; define_method(:keep) { |x| @a = x }; def a = @a; end
o = K.new
s = +"abc"
o.keep(s)
s << "!"
p(o.a)
p s
