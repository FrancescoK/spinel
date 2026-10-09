# A local receiver written by a multiple assignment is no fresh String:
# refused.
class Own
  def initialize(n) = (@n = n)
  def to_s = @n
  def n = @n
end
def go(flag, b)
  o = Own.new(+"a")
  o, z = b, 1 if flag
  s = o.to_s
  s << "!"
  [s, o.to_s, z]
end
b = +"b"
p go(false, b), go(true, b), b
