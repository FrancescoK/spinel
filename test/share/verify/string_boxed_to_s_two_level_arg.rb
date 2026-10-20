# A caller passes its own parameter on, and the String is the caller's two
# calls up, read through a boxed to_s: the change reaches it.
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
def outer(q) = tidy(q)
b = +"b"
p outer(Own.new(+"a")), outer(b.itself), b
