# spinel: gc-stress
# The targets nested in a `(a, b)` of a multiple assignment from a boxed Array
# store boxed elements, and tell the type of the attribute they write so: here
# `a` is written a nested element (a boxed Array) and the splat target's Array,
# and is a boxed slot for both. Typed as the splat's Array alone, the nested
# store cast the element's pointer, and a collection scanned it as the wrong kind.
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
