# A typed array passed to a boxed parameter (its callers disagree on the
# array kind) that the method stores a String into, through an ivar that
# keeps the array its constructor was handed: the ivar widens with the
# constructor's parameter and the parameter's callers widen theirs, so the
# store reaches `src` (CRuby prints ["s", 2] twice). The call was refused at
# compile time, the store otherwise promoting a copy `src` never sees.
class Box
  def initialize(a) = @a = a
  def get = @a
end
def m(arr); arr[0] = "s"; end
m(["x"])
src = [1, 2]
x = Box.new(src).get
m(x)
p src, x
