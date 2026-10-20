# A local written by a multiple assignment holds the caller's String, read
# through a boxed to_s: the change reaches the caller's String.
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
