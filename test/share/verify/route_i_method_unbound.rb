class K
  def keep(x) = (@k = x)
  def k = @k
end
um = K.instance_method(:keep)
k = K.new
s = +"abc"
um.bind(k).call(s)
s << "!"
p k.k
