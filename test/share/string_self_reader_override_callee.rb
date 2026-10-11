# A container store of a reader's value in an ancestor's method keeps each
# class's own String: the field's for the ancestor, the override's for a
# descendant.
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
