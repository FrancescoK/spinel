# spinel: gc-stress
# A multiple assignment whose value is used evaluates every target's receiver and
# key before its right side, in Ruby's order, as the statement does: the nested
# targets, the splat's and the rights' too. The value of a local's write, of a
# method's last expression and of a block's all go through the expression form.
class P; attr_accessor :a, :b, :c, :d; end
def pk(t) = (puts t; P.new)
def rhs = (puts "rhs"; [[1, 2], 3, 4])
v = ((pk("n1").a, pk("n2").b), *pk("s").c, pk("r").d = rhs)
p v
(pk("m1").a, pk("m2").b), x = rhs
def tl = ((pk("t1").a, pk("t2").b), *pk("t3").c, pk("t4").d = rhs)
tl
r = [1].map { (pk("b1").a, pk("b2").b), x = rhs }
p r.size
w = (((pk("c1").a, pk("c2").b), *pk("c3").c, pk("c4").d = rhs) if true)
p w.size
