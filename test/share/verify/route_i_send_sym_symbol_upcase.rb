class K
  def KEEP(x) = (@k = x)
  def k = @k
end
k = K.new
o = [k, 2].first
s = +"abc"
o.send(:keep.upcase, s)
s << "!"
p k.k
