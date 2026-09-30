# A typed array handed to a parameter that stores elements of another kind
# into it is followed back to where it is built and built as the general
# Array there (#6223). The walk stopped short of several places an array
# comes from, and the call was refused at compile time where CRuby mutates
# the caller's array: an `||=` write, a branch that answers the local back
# (`x = m(x) ? x : x`), a row read out of a literal table, a `then` block, a
# method a subclass overrides, a multiple assignment, and an ivar that keeps
# the array its constructor or a setter method was handed. A splice of
# another kind through the parameter was refused outright. Each case has its
# own method, so each one widens on its own store.

def add1(a) = a << "z"
def add2(a) = a << "z"
def add3(a) = a << "z"
def add4(a) = a << "z"
def add5(a) = a << "z"
def add6(a) = a << "z"
def add7(a) = a << "z"
def add8(a) = a << "z"
def add9(a) = a << "z"
def set1(a) = a[0] = "s"
def spl1(a) = a[0, 1] = ["s", "t"]
def spl2(a) = a[0..0] = [1.5]

# `||=`, and a branch answering the local back
a1 ||= [1, 2]
add1(a1)
p a1
a2 = [1, 2] if ARGV.empty?
a2 ||= [3]
add1(a2)
p a2
a3 = [1, 2]
a3 = set1(a3) ? a3 : a3
p a3

# rows of a literal table
t = [[1, 2], [3]]
r = t[0]
add2(r)
add2(t.last)
p t

# a `then` block's value, a method a subclass overrides, a multiple assignment
b1 = 1.then { [1, 2] }
add3(b1)
p b1
class A; def mk = [1, 2]; end
class B < A; def mk = [3]; end
b2 = A.new.mk
add4(b2)
p b2, B.new.mk
b3, b4 = [1, 2], [3]
add5(b3)
p b3, b4

# an ivar keeping the array its constructor or a setter method was handed
class Box
  def initialize(a) = @a = a
  def get = @a
end
src = [1, 2]
add6(Box.new(src).get)
p src
def mkbox(a) = Box.new(a)
src2 = [3]
c1 = mkbox(src2).get
add7(c1)
p src2, c1
class Holder
  def put(a) = @a = a
  def get = @a
end
hd = Holder.new
src3 = [4]
hd.put(src3)
add8(hd.get)
p src3
class Reset
  def initialize(a) = @a = a
  def reset = @a = Array.new(2, 0)
  def get = @a
end
rs = Reset.new([5])
add9(rs.get)
rs.reset
add9(rs.get)
p rs.get

# a splice of another kind through the parameter
s1 = [1, 2]
spl1(s1)
p s1
s2 = [1, 2]
spl2(s2)
p s2
