# A method called with a block of its own hands a yielding callee a
# different proc: `lp = proc { "lp" }; m(&lp)` inside a method given
# `{ :blk }`. The callee yields to lp, not to the enclosing method's block,
# but the call was typed from that block: its yield ran lp and the String
# lp answered was unboxed into the Symbol the block would have given, an
# empty Symbol, a Float read from a pointer, an address, or C that did not
# build. A lambda or a Method in place of the local did the same, and so
# did instance_exec. The enclosing method's own block handed on (`&b`, an
# anonymous `&`) still answers that block's value.
def m1 = yield
def f1
  lp = proc { "lp" }
  m1(&lp)
end
p(f1 { :blk })

def f2 = m1(&-> { "lam" })
p(f2 { :blk })

def str_val = "meth"
def f3 = m1(&method(:str_val))
p(f3 { 7 })

def m4 = block_given? ? yield : 0
def f4
  lp = proc { "g" }
  m4(&lp)
end
p(f4 { 1.5 })

def m5(x) = yield(x)
def f5 = m5("abc", &:upcase)
p(f5 { 1 })

def f6(&b) = m1(&b)
p(f6 { :own })
def f7(&) = m1(&)
p(f7 { :anon })

def f8
  lp = proc { [1, 2] }
  r = m1(&lp)
  r.size
end
p(f8 { "x" })

class K
  def initialize = (@v = "iv")
end
def f9
  lp = proc { @v }
  K.new.instance_exec(&lp)
end
p(f9 { 3 })

class C
  def self.m(a, k:) = yield
end
def f10(&)
  lp = proc { "lp" }
  [C.m(1, k: 2, &lp)]
end
p(f10 { :blk })

# the same callee reached from a literal block and a proc value
def f11
  lp = proc { 2.5 }
  [m1 { 1 }, m1(&lp)]
end
p(f11 { :blk })

# a callee that answers its own value on one call and the proc's on the
# next: the call joins the two, where it joined an Array to the enclosing
# block's Symbol and the C did not build
def m12(a)
  return [a] if ($r12 = !$r12)
  yield
end
def f12
  lp = proc { "lp" }
  m12(1, &lp)
end
p(f12 { :blk })
p(f12 { :blk })
