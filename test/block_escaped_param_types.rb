# A block a method yields to, or calls through its &block, takes its
# parameters' types from those calls. When the method also lets the block
# go -- stores it, returns it, hands it on, turns it into a proc -- the
# block can later be called with anything, and a parameter typed from the
# yields alone read a String or a Symbol as an Integer. So do the yields and
# calls of a method the block is handed on to with `&b` or `super`.

def glob(&b)
  $g = b
  yield 1, 2
end
glob { |a, c| p [a, c] }
$g.call("t", "u")

class Reg
  def initialize = @cbs = []
  def keep(&b)
    @b = b
    yield 1
  end
  def fire = @b.call("s")
  def on(&b)
    @cbs << b
    yield 2
  end
  def fire_all = @cbs.each { |cb| cb.call(:sym) }
end
r = Reg.new
r.keep { |a| p a }
r.fire
r.on { |a| p a }
r.fire_all

def ret(&b)
  yield 3
  return b
end
ret { |a| p a }.call("returned")

def as_proc(&b)
  yield 4
  proc(&b)
end
as_proc { |a| p a }.call(1.5)

def via_to_proc(&b)
  $t = b.to_proc
  yield 5
end
via_to_proc { |a| p a }
$t.call("to_proc")

def aliased(&b)
  x = b
  yield 6
  x.call("alias")
end
aliased { |a| p a }

def keeper(&b) = $k = b
def hands_on(&b)
  keeper(&b)
  yield 7
end
hands_on { |a| p a }
$k.call("kept")

def lam(&b)
  $l = -> { b.call("captured") }
  yield 8
end
lam { |a| p a }
$l.call

# no yield: a `.call` beside the store
def call_and_keep(&b)
  b.call(9)
  $c = b
end
call_and_keep { |a| p a }
$c.call(:later)

# a keyword parameter
def kw(&b)
  $kw = b
  yield 10, k: 11
end
kw { |a, k: 0| p [a, k] }
$kw.call("x", k: "y")

# handed on to a method whose own yield or call passes something else
def inner_yield = yield("inner")
def outer_yield(&b)
  inner_yield(&b)
  yield 12
end
outer_yield { |a| p a }

def inner_call(&b) = b.call(:inner)
def outer_call(&b)
  inner_call(&b)
  yield 13
end
outer_call { |a| p a }

# handed on to a method that agrees keeps the Integer
def inner_int = yield(14)
def outer_int(&b)
  inner_int(&b)
  yield 15
end
outer_int { |a| p a + 1 }

# handed on to the parent's method with `super`
class Parent
  def each = yield("parent")
end
class Bare < Parent
  def each(&b)
    super
    yield 16
  end
end
Bare.new.each { |a| p a }
class Explicit < Parent
  def each(&b)
    super(&b)
    yield 17
  end
end
Explicit.new.each { |a| p a }
