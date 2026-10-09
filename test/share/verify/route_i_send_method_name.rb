class K
  def keep(x) = (@k = x)
  def k = @k
  def go(x) = send(__method__.to_s.sub("go", "keep").to_sym, x)
end
o = K.new
s = +"abc"
o.go(s)
s << "!"
p o.k
