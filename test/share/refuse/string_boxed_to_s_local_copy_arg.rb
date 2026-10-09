# A local copied from a parameter is no fresh String: refused.
class Own
  def initialize(n) = (@n = n)
  def to_s = @n
  def n = @n
end
def tidy(o)
  s = o.to_s
  s << "!"
  [s, o.to_s]
end
def outer(q)
  x = q
  tidy(x)
end
b = +"b"
p outer(Own.new(+"a")), outer(b.itself), b
