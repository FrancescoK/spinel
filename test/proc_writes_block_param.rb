# A proc, lambda, Fiber or Thread made in an iteration block shares the
# block's parameters with it, one binding per iteration. The capture
# analysis kept such a closure's copy of a parameter by value, from when one
# cell served the whole loop: its writes were lost, and a block that also
# assigned the parameter did not compile (an undeclared lv_x). Each
# iteration has a fresh cell now (#4462), so the closure takes it.

def t(xv, z)
  [xv].each do |x|
    pr = proc { x = z }
    pr.call
    p x
  end
end
t(1, 5)
t(1, nil)

def u(xv, z)
  [xv].each do |x|
    x = nil
    pr = proc { x = z }
    pr.call
    p x
  end
end
u(1, 5)

ps = []
[1, 2, 3].each { |x| ps << proc { x }; x += 10 }
p ps.map(&:call)
ls = []
[1.5, 2.5].each { |x| ls << lambda { x = x * 2; x } }
p ls.map(&:call), ls.map(&:call)
# (Floats: under --int-overflow=promote an Integer computed in such a
# closure and written to the cell does not compile, as on master.)
[1.5].each do |x|
  f = Fiber.new { x = 5.5; Fiber.yield; x = 6.5 }
  f.resume
  p x
  f.resume
  p x
end
[1.5].each do |x|
  t = Thread.new { x = 2.5 }
  t.join
  p x
end
h = {}
{ a: 1, b: 2 }.each { |k, v| h[k] = proc { v += 1 } }
p h[:a].call, h[:a].call, h[:b].call
3.times { |i| pr = proc { i = 7 }; pr.call; print i, " " }
puts
[[1.5, 2.5]].each { |a, b| pr = proc { a, b = b, a }; pr.call; p [a, b] }
def m(xs)
  r = []
  xs.each_with_index { |x, i| r << -> { x + i } }
  r.map(&:call)
end
p m([5, 6])
