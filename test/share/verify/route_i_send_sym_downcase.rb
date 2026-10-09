class K
  def keep(x) = (@k = x)
  def k = @k
end
class J
  def keep(x) = nil
end
o = K.new
objs = [o, J.new]
s = +"abc"
m = :KEEP.downcase
objs.each { |r| r.send(m, s) }
s << "!"
p o.k
