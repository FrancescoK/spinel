# A `**h` passed to a method inlined because it yields is call-site code,
# so `h` is the caller's own local even when the callee has one of the
# same name -- a parameter of any kind or a body local.

def blk(h) = yield(h)
h = { a: 1 }
p blk(**h) { |x| x }

def opt(h = {}) = yield(h)
p opt(**h) { |x| x }

def pair(n, h) = yield(n, h)
p pair(1, **h) { |n, x| [n, x] }

def kw(k: 0, j: 2) = yield(k, j)
k = { k: 5 }
p kw(**k) { |x, y| x + y }

# merged with a literal key, and a positional evaluated ahead of the merge
p kw(j: 1, **k) { |x, y| x + y }
def push(a, k: 0) = yield(a, k)
a = [1]
p push(a.push(2), k: 3, **k) { |x, y| [x, y] }

def kwrest(**o) = yield(o)
o = { a: 1, b: 2 }
p kwrest(**o) { |x| x }

def rest(*h) = yield(h)
p rest(**h) { |x| x }

def body_local(v)
  h = v
  yield h
end
p body_local(**h) { |x| x }

class Box
  def open(h) = yield(h)
end
p Box.new.open(**h) { |x| x }

# a `super` into a yielding parent, whose parameter shares the name
class Shelf
  def load(h) = yield(h)
end
class Crate < Shelf
  def load(x)
    h = { c: x }
    super(**h) { |y| y }
  end
end
p Crate.new.load(3)

# a `**` operand that is a boxed value
list = [{ k: 7 }, 1]
k = list[0]
p kw(**k) { |x, y| x + y }

# an anonymous `**` forwarded into a callee that takes one too
def inner(**) = yield(**)
def outer(**) = inner(**) { |**kw| kw }
p outer(a: 1)
