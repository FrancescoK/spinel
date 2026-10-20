# A local copied from a parameter holds the caller's String, read through a
# boxed to_s: the change reaches the caller's String.
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
