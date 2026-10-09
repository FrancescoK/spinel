# A local receiver written from a yield holds whatever the block answers:
# refused.
class Own
  def initialize(n) = (@n = n)
  def to_s = @n
  def n = @n
end
def go
  o = yield
  s = o.to_s
  s << "!"
  [s, o.to_s]
end
b = +"b"
p go { Own.new(+"a") }, go { b }, b
