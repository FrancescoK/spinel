# A local holding an overridden reader's value is each class's own String:
# the field's for the ancestor, the override's new one for a descendant.
class P
  attr_reader :n
  def initialize = (@n = +"n")
  def m = (s = n; s << "!"; s)
end
class Q < P
  def n = (@n + "q")
end
x = P.new; x.m; p x.n
q = Q.new
p [q.m, q.instance_variable_get(:@n)]
