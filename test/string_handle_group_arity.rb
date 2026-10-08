# A method that appends to its String parameter shares the caller's String
# whatever another method of the same name takes at that position: no
# parameter, an Integer, an Array, a boxed value, a yielding method spliced
# into its calls (#6179).
# spinel: gc-minor
X = "x" * 100

# another arity
class A1; def m(p1) = (p1 << X; nil); end
class B1; def m = 0; end
class C1; def m(a, b) = a + b; end
class D1; def m(p1 = 0) = p1; end
p B1.new.m, C1.new.m(1, 2), D1.new.m
s1 = +"a"
A1.new.m(s1)
p s1.size

# a position the other method types as something else
class A2; def m(p1, p2) = (p2 << X; nil); end
class B2; def m(p1) = p1 + 1; end
p B2.new.m(1)
s2 = +"b"
A2.new.m(1, s2)
p s2.size

# a top-level method beside a class's of the name
def grow(p1) = (p1 << X; nil)
class C3; def grow(p1) = p1.to_s * 2; end
p C3.new.grow(3)
s3 = +"c"
grow(s3)
def via(y) = grow(y)
via(s3)
p s3.size

# a super into the method, beside one of another arity
class P4; def m(p1) = (p1 << X; nil); end
class Q4 < P4; def m(p1) = (super; p1 << "y"; nil); end
class Z4; def m(a, b) = a * b; end
p Z4.new.m(2, 3)
s4 = +"d"
Q4.new.m(s4)
p s4.size

# a dispatch over both: a poly receiver, a class value
class A5; def m(p1) = (p1 << X; nil); end
class B5; def m(p1) = p1 + 1; end
s5 = +"e"
[A5.new, B5.new].each { |o| o.is_a?(A5) ? o.m(s5) : p(o.m(1)) }
p s5.size
class A6; def self.m(p1) = (p1 << X; nil); end
class B6; def self.m(p1) = p1 * 2; end
k = [A6, B6][ARGV.size]
s6 = +"f"
k.m(s6)
p s6.size, B6.m(3)

# a boxed sibling that appends too
class A7; def m(p1) = (p1 << X; nil); end
class B7; def m(p1) = (p1 << "y" * 50; nil); end
B7.new.m([1])
s7 = +"g"
A7.new.m(s7)
t7 = +"h"
B7.new.m(t7)
x7 = [A7.new, B7.new][ARGV.size]
u7 = +"i"
x7.m(u7)
p s7.size, t7.size, u7.size

# a top-level yielding method of the name, spliced into each call
def m8(p1) = yield(p1)
class A8; def m8(p1) = (p1 << X; nil); end
w8 = +"w"
m8(w8) { |q| q << "y" }
s8 = +"a"
A8.new.m8(s8)
p w8, s8.size

# a frozen String still raises
fz = "fz".freeze
begin
  A1.new.m(fz)
rescue FrozenError
  p :frozen
end
