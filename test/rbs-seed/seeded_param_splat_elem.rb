# A splat of a boxed value -- an array of mixed elements, or a scalar read out
# of one -- widens the parameters it reaches to poly, unless an --rbs seed
# pins them. Spread in place into pinned Integer, Float, String and object
# parameters, the element was bound as the sp_RbVal it is and the C did not
# compile; it is unboxed to the pinned type, through a method on an object,
# a top-level method and a class method.
# spinel: rbs-seed-run
class SplatPinBox
  attr_reader :n
  def initialize(n) = @n = n
end

class SplatPin
  def add(a, b) = a + b
  def succ(a) = a + 1
  def scale(x, f) = x * f
  def join(s, t) = s + t
  def box_n(b, k) = b.n + k
  def self.add(a, b) = a + b
end

def splat_pin_add(a, b) = a + b

mixed = [1, "x", 2.5, SplatPinBox.new(40)]
one = [mixed[0]]
p SplatPin.new.add(*one, 2)
both = [mixed[0], 4]
p SplatPin.new.add(*both)
p SplatPin.add(*both)
p splat_pin_add(*both)
scalar = mixed[0]
p SplatPin.new.add(*scalar, 5)
p SplatPin.new.succ(*scalar)
p splat_pin_add(*scalar, 6)
fl = [mixed[2]]
p SplatPin.new.scale(*fl, 2.0)
p SplatPin.new.scale(*[mixed[2], 4.0])
strs = [mixed[1], "y"]
p SplatPin.new.join(*strs)
boxes = [mixed[3], 2]
p SplatPin.new.box_n(*boxes)
