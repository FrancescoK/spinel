# A typed array passed to a boxed parameter (its callers disagree on the
# array kind) that the method stores a String into, where the binding cannot
# follow the argument back to where it is built: `get` answers an ivar that
# keeps the array its constructor was handed. The store would promote a copy
# `src` never sees (CRuby prints ["s", 2] twice); refused at compile time.
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
