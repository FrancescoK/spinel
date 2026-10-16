# `b.itself` is b: the boxed to_s hands on the caller's String itself, and
# the change shows through b (#9258).
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
p tidy(Own.new(+"a")), tidy(b.itself), b
