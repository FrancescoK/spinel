class K; def k = @k; end
K.class_eval { def keep(x) = (@k = x) }
k = K.new
s = +"abc"
k.keep(s)
s << "!"
p k.k
