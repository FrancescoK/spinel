# A fiber entered by transfer hands its block's result back when it ends,
# and transfer refuses the targets CRuby refuses.

root = Fiber.current
f1 = Fiber.new { puts "f1"; root.transfer(:from_f1); puts "back in f1"; :done }
p f1.transfer
p f1.transfer
p f1.alive?

g = Fiber.new { |x| x * 2 }
p g.transfer(21)

h = Fiber.new { root.transfer(1); root.transfer(2); 3 }
p h.transfer, h.transfer, h.transfer
begin
  h.transfer
rescue FiberError => e
  p e.message
end

a = Fiber.new { Fiber.yield 1 }
a.resume
begin
  a.transfer
rescue FiberError => e
  p e.message
end

$b = Fiber.new do
  c = Fiber.new do
    $b.transfer
  rescue FiberError => e
    p e.message
  end
  c.resume
end
$b.resume

d = Fiber.new { :x }
d.resume
begin
  d.transfer
rescue FiberError => e
  p e.message
end

e2 = Fiber.new { root.transfer }
e2.transfer
begin
  e2.resume
rescue FiberError => e
  p e.message
end

s = Fiber.new { p Fiber.current.transfer(4) }
s.resume

t = Thread.new do
  tr = Fiber.current
  x = Fiber.new { |v| tr.transfer(v + 1); :fin }
  [x.transfer(1), x.transfer, x.alive?]
end
p t.value
p(Thread.new { Fiber.new { :only }.transfer }.value)
