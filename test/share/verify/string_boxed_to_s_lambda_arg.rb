# A lambda answering the caller's String, read through a boxed to_s: the
# change reaches the caller's String.
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
