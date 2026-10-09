# A callee container store cannot bypass a descendant reader override.
class P
  attr_reader :n
  def initialize = (@n = +"n")
  def keep(a) = (a << n)
end
class Q < P
  def n = (@n + "q")
end
x = P.new; a = []; x.keep(a); a[0] << "!"; p x.n
q = Q.new; b = []; q.keep(b); b[0] << "?"; p [b, q.instance_variable_get(:@n)]
