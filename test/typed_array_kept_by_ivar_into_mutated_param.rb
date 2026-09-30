# A typed array passed to a general-Array parameter the method mutates,
# through an ivar that keeps the array its constructor was handed: `get`
# answers the ivar, the ivar widens with the constructor's parameter, and
# the parameter's callers widen theirs, so the append reaches `src` (CRuby
# prints [1, 2, "z"] twice). The call was refused at compile time, since
# widening the ivar alone would have copied the caller's array into it.
class Box
  def initialize(a) = @a = a
  def get = @a
end
def add(out) = out << "z"
src = [1, 2]
x = Box.new(src).get
add(x)
p src, x
