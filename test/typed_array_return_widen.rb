# An array a method answers, handed to a parameter that stores elements of
# another kind into it, is the general Array where the method builds it: the
# binding follows the argument back through locals and method values, as it
# does an array literal, instead of copying a typed array into the parameter
# (the mutation landed in the copy, so the call was refused at compile time).
# The method's other callers read the general Array. Each case has its own
# method, so each one widens on its own mutation.

def cat(a) = a.concat(["c"])
def shl(a) = a << 3.5
def psh(a) = a.push(4)
def set(a) = a[0] = "s"
def ins(a) = a.insert(1, :i)
def uns(a) = a.unshift(7)
def fil(a) = a.fill("f")

# Integer, Float and String arrays, each mutator
def i1 = [1, 2]
def f1 = [1.5, 2.5]
def s1 = %w[a b]
def i2 = [3, 4]
def f2 = [0.5]
def s2 = %w[x]
def i3 = Array.new(2, 0)
def f3 = Array.new(1, 0.0)
a1 = i1; cat(a1); p a1
a2 = f1; set(a2); p a2
a3 = s1; psh(a3); p a3
a4 = i2; shl(a4); p a4
a5 = f2; ins(a5); p a5
a6 = s2; uns(a6); p a6
a7 = i3; fil(a7); p a7
p fil(f3)

# the value of a method answering another's, and a branch of each kind
def inner = [5, 6]
def outer = inner
def outer2 = outer
y = outer2
ins(y)
p y
def pick(f) = f ? Array.new(2, 0) : [7]
p cat(pick(true)), cat(pick(false))

# still read as an array elsewhere
def nums = [1, 2, 3]
z = nums
cat(z)
w = nums
p z, w.sum, w.map { |v| v * 2 }, w.include?(2)

# a method answering its block's value, and a builtin answering its receiver
def build = yield
b1 = build { [5, 6] }
set(b1)
p b1
b2 = [8].push(9)
fil(b2)
p b2
b3 = [1, 2].tap { }
uns(b3)
p b3

# an ivar a method answers, and one an attr_reader on another object does
class Box
  attr_reader :items
  def initialize; @items = [1.5]; end
  def get(_k) = @items
end
q = Box.new
r = q.get(0)
set(r)
p r, q.items
c = Box.new
ins(c.items)
p c.items

# a class variable and a constant a method answers
class Reg
  @@list = [1, 2]
  TABLE = [3.5]
  def self.list = @@list
  def self.table = TABLE
end
l = Reg.list
set(l)
p Reg.list
t = Reg.table
cat(t)
p Reg.table

# a parameter whose callers pass different kinds, which stores a String
def store(arr) = arr[1] = "t"
def i4 = [1, 2]
store(["x", "y"])
u = i4
store(u)
p u
