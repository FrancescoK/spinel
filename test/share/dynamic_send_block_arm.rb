# A computed-name send whose arm takes the block (tap, then) answers the
# receiver's String or the block's value: the receiver's handle, not a copy.
# The arm of a name that answers its receiver's String, with the block
# given, is boxed as its handle, and the block's value is its own.
tn = [:tap, :then, :size]
tp = +"t"
u = tp.send(tn[0]) { |x| x << "!" }; p [u, tp, u.equal?(tp)]
u = tp.send(tn[1]) { |x| x + "?" }; p [u, tp]
class Tapper
  def initialize = @s = +"iv"
  def go(m) = @s.send(m) { |x| x << "!" }
  def s = @s
end
tr = Tapper.new
u = tr.go(tn[0]); p [u, tr.s, u.equal?(tr.s)]

