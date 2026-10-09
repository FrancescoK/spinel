class K
  def keep(x) = (@k = x)
  def k = @k
end
o = [K.new, 2].first
s = +"abc"
table = { "keep" => :keep }
o.public_send(table["keep"], s)
s << "!"
p o.k
