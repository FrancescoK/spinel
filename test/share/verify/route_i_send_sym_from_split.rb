class K
  def keep(x) = (@k = x)
  def k = @k
end
k = K.new
o = [k, 2].first
s = +"abc"
"keep".split(",").each { |nm| o.send(nm, s) }
s << "!"
p k.k
