# spinel: gc-stress
# The targets nested in a `(a, b)` of a multiple assignment from a boxed Array
# store boxed elements, and tell the type of the attribute they write so: here
# `a` is written a nested element (a boxed Array) and the splat target's Array,
# and is a boxed slot for both. Typed as the splat's Array alone, the nested
# store cast the element's pointer, and a collection scanned it as the wrong kind.
# An outer Array of Integer Arrays keeps the attribute's elements: the nested
# targets store the Integers, as a typed Array's do.
class P; attr_accessor :a, :b; end
def pk(t) = (puts t; P.new)
def rhs = (puts "rhs"; [[1, 2], 3, 4])
v = ((pk("n1").a, pk("n2").b), *pk("s").a, pk("r").b = rhs)
p v
(pk("m1").a, pk("m2").b), x = rhs
def tl = ((pk("t1").a, pk("t2").b), *pk("t3").a, pk("t4").b = rhs)
tl
r = [1].map { (pk("b1").a, pk("b2").b), x = rhs }
p r.size
w = (((pk("c1").a, pk("c2").b), *pk("c3").a, pk("c4").b = rhs) if true)
p w.size

class Q3; attr_accessor :a, :b, :c, :d; end
o = Q3.new
v = [[1, 2], [3, 4]]
(o.a, o.b), (o.c, o.d) = v
p [o.a, o.b, o.c, o.d]

class Q7; attr_accessor :a, :b; end
def pair = [[1, 2], [3, 4]]
o = Q7.new
(o.a, o.b), (x, y) = pair
p [o.a, o.b, x, y]
AR = [0, 0]
(AR[0], AR[1]), z = pair
p AR
