# spinel: gc-minor
# A non-local Proc return selects its own boxed value at the method's exit.
module ProcHomeStrings
  def get(f)
    pr = proc { return @x * 2 if f }
    pr.call
    @x
  ensure
    @n = @y.size
  end
  def direct(f)
    pr = proc { return @x if f }
    return @x * 3 unless f
    pr.call
    @x
  end
end
class ProcHomeA
  include ProcHomeStrings
  def initialize(x, y)
    @x = x
    @y = y
  end
end
class ProcHomeB
  def get(f) = "b".dup
  def direct(f) = "b".dup
end
src = "s".dup
other = "o".dup
os = [ProcHomeA.new(src, other), ProcHomeB.new]
r = os[0].get(true)
r << "!"
s = os[0].direct(false)
s << "?"
p r, s, src, other
q = os[0].get(false)
q << "g"
t = os[0].direct(true)
t << "d"
p q, t, src, other
