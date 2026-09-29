class Integer
  def enc(out) = out << to_s
end
o = []
5.enc(o)
p o
