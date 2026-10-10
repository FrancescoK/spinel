# A default reading an earlier parameter reads its own method's, when an
# argument is a call to a method with a default of the same shape (#8319):
# the inner call's renames went into the slots the outer's were hidden in.
def inner(r, copy = r) = [r, copy]
def outer(r, x, copy = r) = [r, copy, x]
p outer(1, inner(2))
p outer(1, outer(2, inner(3)))

def kin(r, k: r * 10) = [r, k]
def kout(r, x, k: r * 10) = [r, k, x]
p kout(1, kin(2))

class Box
  def inner(r, copy = r) = [r, copy]
  def outer(r, x, copy = r) = [r, copy, x]
end
b = Box.new
p b.outer(5, b.inner(6))
