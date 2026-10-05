# spinel: int64
# Boxed fill offsets use the implicit Integer conversion, with nil defaults
# and checked Float narrowing before an offset can enter the growth loop.
def w(v) = v
w("x")
p [1, 2, 3].fill(9, 1, w(3r/2))
p [1, 2, 3].fill(9, w(3r/2), 1)
p [1, 2, 3].fill(9, w(-3r/2), w(3r/2))
p [1, 2, 3].fill(9, w(1.9), w(1.9))
p [1, 2, 3].fill(9, w(nil), w(nil))
p [1, 2, 3].fill(9, 1, w(-3r/2))
p [1, 2, 3].fill(9, w(Complex(1, 0)), 1)
class Offset
  def to_int = 1
end
p [1, 2, 3].fill(9, w(Offset.new), w(Offset.new))
[-1e30, 1e30, 2**100, -(2**100), Float::INFINITY, -Float::INFINITY, Float::NAN].each do |v|
  begin
    p [1, 2, 3].fill(9, w(v))
  rescue => e
    p [e.class, e.message]
  end
  begin
    p [1, 2, 3].fill(9, 1, w(v))
  rescue => e
    p [e.class, e.message]
  end
end
["x", true, false, :x, 0..2].each do |v|
  begin
    p [1, 2, 3].fill(9, w(v), 1)
  rescue => e
    p [e.class, e.message]
  end
end
