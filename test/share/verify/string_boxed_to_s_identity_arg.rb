# A String handed through a call that answers its argument, then read
# through a boxed to_s that is the String itself: the change reaches the
# caller's String.
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
