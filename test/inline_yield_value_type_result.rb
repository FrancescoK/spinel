# A yielding method is inlined at its call sites, and its value can be a
# value-type object (a small immutable class kept as a struct) or the struct
# Process.times answers held in a local of the inlined body.
class Pt
  def initialize(x) = @x = x
  attr_reader :x
end
def make
  yield
  Pt.new(2.5)
end
def timed
  t0 = Process.times
  yield
  t1 = Process.times
  t1.utime - t0.utime
end
p make { 1 + 1 }.x
p timed { 10.times { |i| i } } >= 0.0
