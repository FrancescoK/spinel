class Base; def keep(x) = (@k = x); def k = @k; end
class K < Base; end
s = +"abc"
o = K.new
o.send(("ke" + "ep").to_sym, s)
s << "!"
p o.k
