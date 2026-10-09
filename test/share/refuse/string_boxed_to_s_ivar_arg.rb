# An ivar written from a parameter holds a String boxed as bytes: the ivar's
# writes are looked at one level only, so it stays refused.
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
class Hold
  def initialize(v) = (@v = v)
  def run = tidy(@v)
  def v = @v
end
b = +"b"
h = Hold.new(b.itself)
h2 = Hold.new(Own.new(+"a"))
p h.run, h2.run, h.v, b
