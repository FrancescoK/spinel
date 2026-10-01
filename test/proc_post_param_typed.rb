# A post-required parameter of a block run as a proc (a method that hands
# its `&b` on to itself, so the block is a real proc) binds the boxed value
# unboxed into the type the yields give it, as an optional does: declared
# boxed whatever that type, it was read as a String, an Integer, a Float,
# a Symbol, a boolean, an Array, a Hash or an object, and the C did not
# build. Each method yields one kind, so the parameter keeps that type.
class Pt; def initialize(v) = (@v = v); def v = @v; end
def rs(x, n, &b) = n > 0 ? rs(x, n - 1, &b) : yield(0, x)
def ri(x, n, &b) = n > 0 ? ri(x, n - 1, &b) : yield(0, x)
def rf(x, n, &b) = n > 0 ? rf(x, n - 1, &b) : yield(0, x)
def ry(x, n, &b) = n > 0 ? ry(x, n - 1, &b) : yield(0, x)
def rb(x, n, &b) = n > 0 ? rb(x, n - 1, &b) : yield(0, x)
def ra(x, n, &b) = n > 0 ? ra(x, n - 1, &b) : yield(0, x)
def rh(x, n, &b) = n > 0 ? rh(x, n - 1, &b) : yield(0, x)
def ro(x, n, &b) = n > 0 ? ro(x, n - 1, &b) : yield(0, x)
def r1(x, n, &b) = n > 0 ? r1(x, n - 1, &b) : yield(x)
p rs(+"b", 2) { |n = 0, t| t.size }
p rs(+"ab", 1) { |*q, t| q.size + t.size }
p ri(1, 2) { |n = 0, t| t + 1 }
p rf(1.5, 1) { |*q, t| t * 2 }
p ry(:s, 1) { |*q, t| t }
p rb(true, 1) { |*q, t| !t }
p ra([1, 2], 2) { |n = 0, t| t.size }
p rh({ a: 1 }, 1) { |n = 0, t| t[:a] }
p ro(Pt.new(7), 1) { |*q, t| t.v }
p r1(+"c", 1) { |*q, t| [q, t] }
