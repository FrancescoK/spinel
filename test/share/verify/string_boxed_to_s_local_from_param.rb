# A local written from a parameter holds the caller's String, read through
# a boxed to_s: the change reaches the caller's String.
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
