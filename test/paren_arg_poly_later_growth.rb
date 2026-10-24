# A shared String variable handed in parentheses to a method called on a
# receiver in parentheses (a dispatch over the receiver's classes) is that
# String, also where a later argument grows it, moving its bytes, or gives
# the variable another String: the method's change shows through the other
# name, as CRuby's does.
SH = proc { |x| x << "" }
class K
  def each_buf(b) = yield(b)
  def wrap(b, k) = each_buf(b) { |q| yield q }
end
n = 0

m = +"m"; m << ("a" * 100); SH.call(m); o = m
(n += 1; K).new.wrap((n += 1; m), (m << ("x" * 5000); 1)) { |w| w << "!" }
p o.size, o[-1], m.equal?(o), n

u = +"u"; SH.call(u); ou = u
(n += 1; K).new.wrap((n += 1; u), (u.replace("r" * 4000); u = +"z"; 1)) { |w| w << "!" }
p ou.size, ou[-1], u, n

v = +"v"; v << ("a" * 100); SH.call(v); ov = v
(n += 1; K).new.wrap((n += 1; v), (v << ("x" * 5000); v << ("y" * 50000); GC.start; 1)) { |w| w << "!" }
p ov.size, ov[-1], v.equal?(ov), n
