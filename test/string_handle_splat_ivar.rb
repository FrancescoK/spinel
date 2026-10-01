# An ivar a call hands on through a splat -- an element of a splatted
# Array, or an argument written after the splat -- is the object's own
# String, as in CRuby: the method it lands on appends to it. It went over
# as a copy. (A global has no shared form to take there, and is refused at
# compile time.)

X = "x" * 40

class B; def m(a) = (a << X; nil); end
class C
  def initialize = (@w = +"w")
  def lit = (B.new.m(*[@w]); @w.size)
  def loc = (@v = +"a"; s = [@v]; B.new.m(*s); @v.size)
  def par(x) = (@u = x; B.new.m(*[@u]); @u.size)
  def own = (@w << "!"; B.new.m(*[@w]); @w.size)
end
c = C.new
p c.lit, c.loc, c.own
s = +"p"; p c.par(s), s.size

def m2(a, b) = (b << X; a)
class D
  def initialize = (@d = +"d")
  def run = (m2(*[], 1, @d); @d.size)
  def after = (m2(*[1], @d); @d.size)
end
p D.new.run, D.new.after
