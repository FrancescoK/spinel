# A local written from a yield holds the block's String, read through a
# boxed to_s: the change reaches the block's String.
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
