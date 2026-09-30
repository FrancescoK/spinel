# A typed array passed to a general-Array parameter the method mutates, where
# the binding cannot follow the argument back to where it is built: `get`
# answers an ivar that keeps the array its constructor was handed, and
# widening that ivar would copy the caller's array into it instead. The
# conversion into the parameter is a copy, so the append would not reach
# `src` (CRuby prints [1, 2, "z"] twice); refused at compile time (#4480).
class Box
  def initialize(a) = @a = a
  def get = @a
end
def add(out) = out << "z"
src = [1, 2]
x = Box.new(src).get
add(x)
p src, x
