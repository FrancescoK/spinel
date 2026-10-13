# Kernel#tap and #then (yield_self) take a forwarded callable (`&b`, a
# lambda, a method object) on any receiver, a program object's included:
# tap answers the receiver, then the callable's answer.
class M
  def x = 1
end
seen = []
b = proc { |n| seen << n.class }
p M.new.tap(&b).x, [1].tap(&b).size, "s".tap(&b)
def fwd(&blk) = M.new.tap(&blk).x
p fwd { |m| seen << :fwd }
l = ->(m) { m.x + 41 }
p M.new.then(&l), 5.yield_self(&->(n) { n * 2 })
def show(v) = "<#{v}>"
p 3.then(&method(:show))
def boxed(v, &blk) = v.tap(&blk)
p boxed(1) { |n| seen << n }, boxed("t") { |n| seen << n }
p seen
