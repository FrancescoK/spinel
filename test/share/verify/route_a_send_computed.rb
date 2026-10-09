class K; def keep(x) = (@k = x); def k = @k; end
s = +"abc"
o = K.new; [o, 1][0].send(:KEEP.downcase, s); r = o.k
r << "!"
p s
p r
