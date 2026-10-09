# A caller passes its own parameter on, and the String is boxed as bytes two
# calls up: only the direct call sites are looked at, so it stays refused.
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
