# A local receiver written from a parameter holds whatever the caller boxed:
# its writes are looked at one level only, so it stays refused.
class Own
  def initialize(n) = (@n = n)
  def to_s = @n
  def n = @n
end
def go(x)
  o = x
  s = o.to_s
  s << "!"
  [s, o.to_s]
end
b = +"b"
p go(Own.new(+"a")), go(b.itself), b
