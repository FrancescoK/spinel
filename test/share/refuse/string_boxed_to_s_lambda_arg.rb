# A lambda's value is the caller's String boxed as bytes: refused.
class Own
  def initialize(n) = (@n = n)
  def to_s = @n
end
def tidy(o)
  s = o.to_s
  s << "!"
  [s, o.to_s]
end
b = +"b"
f = -> { b }
p tidy(Own.new(+"a")), tidy(f.call), b
