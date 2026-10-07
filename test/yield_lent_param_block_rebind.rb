# A yielding method is spliced at its call site, and a String parameter it
# appends to binds as an alias of the caller's variable. When the call's
# block assigned that variable, the alias followed it, so the method's
# appends after the yield landed on the block's new String: `m(s) { s =
# +"b" }` printed "bx" where CRuby prints "b". The alias now moves onto the
# splice's own slot at the block's write, keeping the String the variable
# held until then: appends before the write, and reads in the block before
# it, still go through the variable. Every kind of write moves it: a plain
# or operator write, `||=`, `&&=`, a multiple-assignment target, and a
# write whose value reads or changes the variable first; a write that
# stores the String the variable already holds leaves it. Each case has a
# method and a local of its own.

# a plain write
def m1(v)
  yield
  v << "x"
  nil
end
def case1
  s = +"a"
  m1(s) { s = +"b" }
  p s
end

# a write the block may skip
def m2(v)
  yield
  v << "x"
  nil
end
def case2
  s = +"a"
  c = false
  m2(s) { s = +"b" if c }
  p s
end

# an operator write
def m3(v)
  yield
  v << "x"
  nil
end
def case3
  s = +"a"
  m3(s) { s += "c" }
  p s
end

# the method appends before the yield, the block reads the String first
def m4(v)
  v << "f"
  yield
  v << "x"
  nil
end
def case4
  s = +"a"
  m4(s) { p s; s = +"b" }
  p s
end

# the block appends before it writes
def m5(v)
  yield
  v << "x"
  nil
end
def case5
  s = +"a"
  m5(s) { s << "q"; s = +"b" }
  p s
end

# the write inside a block of the block
def m6(v)
  yield
  v << "x"
  nil
end
def case6
  s = +"a"
  m6(s) { [1].each { s = +"g" } }
  p s
end

# the yield inside the method's own iterator
def m7(v)
  [1].each { yield }
  v << "y"
  nil
end
def case7
  s = +"a"
  m7(s) { s = +"e" }
  p s
end

# a write in value position
def m8(v)
  yield
  v << "x"
  nil
end
def case8
  s = +"a"
  x = nil
  m8(s) { x = (s = +"b") }
  p s, x
end

# two yields, each writing
def m9(v)
  yield
  v << "x"
  yield
  v << "y"
  nil
end
def case9
  s = +"a"
  n = 0
  m9(s) { n += 1; s = +"b#{n}" }
  p s
end

# the method spliced inside its own block
def m10(v)
  yield
  v << "x"
  nil
end
def case10
  s = +"a"
  m10(s) { m10(s) { s = +"z" } }
  p s
end

# a block that only reads the variable keeps the alias
def m11(v)
  yield
  v << "x"
  nil
end
def case11
  s = +"a"
  m11(s) { p s }
  p s
end

def pair_value = [+"d", 2]

# a multiple-assignment target, from a literal
def m12(v)
  yield
  v << "x"
  nil
end
def case12
  s = +"a"
  m12(s) { s, _t = +"d", 1 }
  p s
end

# from an Array
def m13(v)
  yield
  v << "x"
  nil
end
def case13
  s = +"a"
  arr = [+"d", 1]
  m13(s) { s, _t = arr }
  p s
end

# from a method's value
def m14(v)
  yield
  v << "x"
  nil
end
def case14
  s = +"a"
  m14(s) { s, _t = pair_value }
  p s
end

# after a splat
def m15(v)
  yield
  v << "x"
  nil
end
def case15
  s = +"a"
  m15(s) { _w, *_r, s = 1, 2, +"e" }
  p s
end

# `||=`
def m16(v)
  yield
  v << "x"
  nil
end
def case16
  s = +"a"
  m16(s) { s = nil; s ||= +"b" }
  p s
end

# `&&=`
def m17(v)
  yield
  v << "x"
  nil
end
def case17
  s = +"a"
  m17(s) { s &&= +"c" }
  p s
end

# a value that reads the variable
def m18(v)
  yield
  v << "x"
  nil
end
def case18
  s = +"a"
  m18(s) { s = s + "b" }
  p s
end

# a value that appends to the variable first
def m19(v)
  yield
  v << "x"
  nil
end
def case19
  s = +"a"
  m19(s) { s = (s << "q"; +"b") }
  p s
end

# an operator write whose operand appends to the variable first
def m20(v)
  yield
  v << "x"
  nil
end
def case20
  s = +"a"
  m20(s) { s += (s << "q"; "c") }
  p s
end

# a write of the String the variable already holds
def m21(v)
  yield
  v << "x"
  nil
end
def case21
  s = +"a"
  m21(s) { s = s }
  p s
end

# a `||=` that keeps it
def m22(v)
  yield
  v << "x"
  nil
end
def case22
  s = +"a"
  m22(s) { s ||= +"b" }
  p s
end

# a multiple assignment that keeps it
def m23(v)
  yield
  v << "x"
  nil
end
def case23
  s = +"a"
  m23(s) { s, _w = s, 1 }
  p s
end

# an instance variable the block assigns, always or not at all
def m_iv(v)
  yield
  v << "x"
  nil
end
class Holder
  def go
    @s = +"a"
    m_iv(@s) { @s = +"b" }
    p @s
  end
end
def m_iv2(v)
  yield
  v << "x"
  nil
end
class Holder2
  def go
    @s = +"a"
    c = false
    m_iv2(@s) { @s = +"b" if c }
    p @s
  end
end
# an instance variable's other writes
def m_ivw1(v)
  yield
  v << "x"
  nil
end
class HolderW1
  def go
    @s = +"a"
    m_ivw1(@s) { @s, _t = +"d", 1 }
    p @s
  end
end
def m_ivw2(v)
  yield
  v << "x"
  nil
end
class HolderW2
  def go
    @s = +"a"
    m_ivw2(@s) { @s = nil; @s ||= +"b" }
    p @s
  end
end
def m_ivw3(v)
  yield
  v << "x"
  nil
end
class HolderW3
  def go
    @s = +"a"
    m_ivw3(@s) { @s &&= +"c" }
    p @s
  end
end
def m_ivw4(v)
  yield
  v << "x"
  nil
end
class HolderW4
  def go
    @s = +"a"
    m_ivw4(@s) { @s = @s + "e" }
    p @s
  end
end

case1
case2
case3
case4
case5
case6
case7
case8
case9
case10
case11
case12
case13
case14
case15
case16
case17
case18
case19
case20
case21
case22
case23
Holder.new.go
Holder2.new.go
HolderW1.new.go
HolderW2.new.go
HolderW3.new.go
HolderW4.new.go
