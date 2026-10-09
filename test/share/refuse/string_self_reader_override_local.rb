# An alias of an overridden reader cannot take the ancestor slot handle.
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
