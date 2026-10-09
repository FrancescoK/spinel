class K
  def kee(x) = nil
  def kef(x) = (@k = x)
  def k = @k
end
o = [K.new, 1][0]
s = +"abc"
o.send(:kee.succ, s)
s << "!"
p o.k
