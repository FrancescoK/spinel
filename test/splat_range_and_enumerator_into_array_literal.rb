# `[*v]`, `[0, *v, 9]` and `x, y = *v` spread a Range's members and an
# Enumerator's items when the value's kind is known only at run time, and an
# Enumerator or a String Range held in a variable when it is known. The
# value went in as one element (`x, y = *e` gave the Enumerator and nil),
# and the String Range did not build.
def lit(v) = [*v]
def mid(v) = [0, *v, 9]
def two(v)
  x, y = *v
  [x, y]
end
p lit(3..4), lit(1...3), lit("a".."b"), lit([8]), lit("t"), lit(nil), lit(5)
p mid(3..4), mid(1...3), mid("a".."b"), mid([8]), mid("t"), mid(nil), mid(5)
p two(3..4), two(1...3), two("a".."b"), two([8]), two("t"), two(nil), two(5)
p lit([1, 2, 3].each_slice(2)), mid([4, 5].each), two([6, 7].map)
p lit({ k: 1 }), lit(1...1), lit("b".."a")

# read out of a container, and out of an instance variable
h = [(3..5), ("a".."c"), [4, 5].each, 1, "s"]
r = h[0]
s = h[1]
e = h[2]
p [*r], [0, *s, 9], [*e, *r], [[*r], 1]
x, *y = *r
*a, b = *s
p x, y, a, b
z = *r
p z, [*r].sum, [*s].join("-")
class Holder
  def initialize(v) = @v = v
  def all = [*@v, *@v]
end
p Holder.new(1..2).all, Holder.new([7]).all, Holder.new(nil).all

# the value is left as it was, and each literal is its own array
c = [*r]
d = [*r]
c << 9
p c, d, r, c.equal?(d)

# an Enumerator the compiler knows is one
e = [1, 2, 3].each
p [*e], [0, *e, 9], [*e, *e]
m, n, o, q = *e
p [m, n, o, q]
x, *y = *e
p x, y
p [*[1, 2, 3].each_cons(2)], [*[1, 2].each_with_index], [*"ab".each_char]
p [*3.times], [*1.upto(3)], [*1.step(7, 3)]
e.next
p [*e]

# a String Range held in a variable
v = ("a".."c")
p [*v], [0, *v, 9], [*v, *v], [*v].size
x, y = *v
p x, y
w = ("a"..."c")
p [*w]

# a Range with no end has no members to spread
endless = [(1..), 0][0]
begin
  p [*endless]
rescue RangeError
  puts "RangeError"
end

# what was right stays so: a Range or an Array the compiler knows
t = 3..4
u = [1, 2]
p [*t], [0, *t, 9], [*1..3], [*"a".."c"], [*u], [0, *u, 9], [*u, *nil, *[]]
