class K
  def keep(x) = (@k = x)
  def k = @k
end
k = K.new
o = [k, 2].first
s = +"abc"
%i[keep].each { |nm| o.send(nm, s) }
s << "!"
p k.k
