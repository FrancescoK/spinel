# A descendant method can return a different String from the reader slot.
class P
  attr_reader :n
  def initialize = (@n = +"n")
  def m = (a = []; a << n; a[0] << "!"; a)
end
class Q < P
  def n = (@n + "q")
end
p P.new.tap { |x| x.m }.n
q = Q.new
r = q.m
p [r, q.instance_variable_get(:@n)]
