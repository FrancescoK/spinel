# An inherited method must account for overrides in sibling receiver classes.
class P
  attr_reader :n
  def initialize = (@n = +"n")
  def m = (a = []; a << n; a[0] << "!"; a)
end
class Q < P; end
class R < P
  def n = "frozen-r"
end
q = Q.new; q.m; p q.n
r = R.new
begin
  p r.m
rescue FrozenError
  puts "FrozenError"
end
p r.instance_variable_get(:@n)
