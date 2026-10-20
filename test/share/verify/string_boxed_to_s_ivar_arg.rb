# An instance variable written from a parameter holds the String a boxed
# to_s hands on: the change reaches the caller's String.
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
