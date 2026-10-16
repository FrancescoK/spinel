# A call answering its String argument hands it to the boxed to_s as bytes,
# so the caller's String would not see the change: refused.
class Own
  def initialize(n) = (@n = n)
  def to_s = @n
end
def same(x) = x
def tidy(o)
  s = o.to_s
  s << "!"
  [s, o.to_s]
end
b = +"b"
p tidy(Own.new(+"a")), tidy(same(b)), b
