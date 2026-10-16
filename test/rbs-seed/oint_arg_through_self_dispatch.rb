# spinel: rbs-seed-run
# An inherited method's call dispatches on the receiver's class, and an
# override whose parameter is `Integer?` (or `Float?`) takes the argument
# with its nil: the arm unboxed it as a plain Integer, which nil raises on,
# and passed an sp_int where the override takes the oint (#9398).
class OintDispatchBase
  def f(x) = raise NotImplementedError
  def g = f(nil)
  def h(v) = f(v)
  def q(x) = raise NotImplementedError
  def r = q(nil)
end
class OintDispatchSub < OintDispatchBase
  def f(x) = x
  def q(x) = x
end
s = OintDispatchSub.new
p s.g
p s.h(5)
p s.r
