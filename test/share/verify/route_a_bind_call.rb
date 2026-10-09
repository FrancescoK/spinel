class K; def keep(x) = (@k = x); def k = @k; end
s = +"abc"
o = K.new; K.instance_method(:keep).bind_call(o, s); r = o.k
r << "!"
p s
p r
