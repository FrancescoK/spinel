# A String parameter the method only appends to is lent its argument's slot
# by address. A block of the same call that assigns the argument's local
# rebinds that slot while the method runs, so the appends after the block
# ran landed on the block's new String. Such a call lends nothing: the
# parameter shares its argument's String, and the local's new String is
# the block's own. A block that only reads the local leaves the lend as it
# was. Each case has a method and a local of its own: one call that cannot
# lend makes its method's parameter shared for every caller.

# a plain write in the block
def m1(v)
  yield
  v << "x"
  nil
end
a1 = +"a"
m1(a1) { a1 = +"b" }
p a1

# an operator write (refused before: the local holds the shared handle)
def m2(v)
  yield
  v << "x"
  nil
end
a2 = +"a"
m2(a2) { a2 += "c" }
p a2

# a multiple-assignment target
def m3(v)
  yield
  v << "x"
  nil
end
a3 = +"a"
m3(a3) { a3, _t = +"d", 1 }
p a3

# the yield inside the method's own iterator
def m4(v)
  [1].each { yield }
  v << "y"
  nil
end
a4 = +"a"
m4(a4) { a4 = +"e" }
p a4

# the write inside a block of the block
def m5(v)
  yield
  v << "x"
  nil
end
a5 = +"a"
m5(a5) { [1].each { a5 = +"g" } }
p a5

# appended before the yield
def m6(v)
  v << "f"
  yield
  nil
end
a6 = +"a"
m6(a6) { a6 = +"h" }
p a6

# the old String kept under a second name sees the appends
def m7(v)
  yield
  v << "x"
  nil
end
a7 = +"a"
t7 = a7
m7(a7) { a7 = +"i" }
p a7, t7

# a method's local, and a parameter lent on with its block assigning it
def m8(v)
  yield
  v << "x"
  nil
end
def local_write
  s = +"a"
  m8(s) { s = +"j" }
  s
end
def m9(v)
  yield
  v << "x"
  nil
end
def lend_on(q)
  m9(q) { q = +"k" }
  q
end
p local_write, lend_on(+"a")

# a block that only reads the local keeps the lend
def m10(v)
  yield
  v << "x"
  nil
end
a10 = +"a"
m10(a10) { p a10 }
p a10

# `+=` on a local holding the shared handle, outside any block: the old
# String stays with its other name
a11 = +"a"
t11 = a11
t11 << "q"
a11 += "c"
p a11, t11

# `+=` on a shared local in value position: the value is the local's new
# String, the old one stays with its other name
a12 = +"a"
t12 = a12
t12 << "q"
x12 = (a12 += "c")
x12 << "!"
p a12, t12, x12
a13 = +"a"
t13 = a13
t13 << "q"
p(a13 += "c")
p a13, t13
def tail_op_write
  s = +"a"
  t = s
  t << "q"
  s += "c"
end
r14 = tail_op_write
r14 << "!"
p r14
a15 = +"a"
t15 = a15
t15 << "q"
p [1, 2].map { a15 += "c" }, a15, t15
a16 = +"a"
t16 = a16
t16 << "q"
y16 = (a16 += "c" if t16.size > 0)
p y16, a16, t16

# the right-hand side grows the old String through its other name, or
# rebinds the local: the old String is read once the right-hand side ran
a17 = +"a"
t17 = a17
t17 << "q"
a17 += (t17 << ("z" * 300); "c")
p a17.size, t17.size, a17[-1]
a18 = +"a"
t18 = a18
t18 << "q"
a18 += (a18 = +"w"; "c")
p a18, t18

# an instance variable the block assigns
def m19(v)
  yield
  v << "x"
  nil
end
class C19
  def go
    @s = +"a"
    m19(@s) { @s = +"b" }
    p @s
  end
end
C19.new.go
