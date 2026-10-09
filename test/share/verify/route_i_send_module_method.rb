module Keeper; def keep(x) = (@k = x); def k = @k; end
class K; include Keeper; end
s = +"abc"
o = K.new
o.send(("ke" + "ep").to_sym, s)
s << "!"
p o.k
