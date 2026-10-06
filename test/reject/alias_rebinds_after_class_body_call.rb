# A class body runs in order: `new.a` meets the `def a` above, and the alias
# below rebinds `a` only afterwards (CRuby prints 3). An alias binds for the
# whole program here, so the call would print 19; refused, not answered wrongly
# (#7690).
class A
  def a = 3
  def b = 19
  p new.a
  alias_method :a, :b
end
