# An element destructured from a boxed value into an instance variable whose
# slot another write typed (Integer, Float, String) is stored when it is of
# that kind or nil, and otherwise raises TypeError rather than reading the
# other kind's bits. CRuby has no slot types and stores any value: there
# @x would become "s" / 2.5, and these lines would print those instead of
# the error. The expected output is Spinel's refusal.
class A
  def initialize = (@x = 0; @f = 1.5; @s = "a"; @y = nil)
  def set(v)
    @x, @y = v
    @x
  end
  def setf(v)
    @f, @y = v
    @f
  end
  def sets(v)
    @s, @y = v
    @s
  end
end
def g(i) = [[1, 2], ["s", 3], [2.5, 1], nil, [nil, 1], [:k, 0]][i]
a = A.new
p a.set(g(0))
[1, 2, 5].each do |i|
  a.set(g(i))
rescue TypeError => e
  p e.message
end
p a.set(g(3))
p a.set(g(4))
p a.setf(g(2))
begin
  a.setf(g(0))
rescue TypeError => e
  p e.message
end
p a.sets(g(1))
begin
  a.sets(g(5))
rescue TypeError => e
  p e.message
end
