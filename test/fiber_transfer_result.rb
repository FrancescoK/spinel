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

# a resumed fiber that transfers away gets the result back when the chain
# ends, and can itself be transferred back to
c1 = Fiber.new { :c_end }
b1 = Fiber.new { r = c1.transfer; p [:b_got, r]; :b_end }
a1 = Fiber.new { r = b1.transfer; GC.start; p [:a_got, r]; :a_end }
p [:root_got, a1.resume]

$a2 = nil
c2 = Fiber.new { GC.start; $a2.transfer(:from_c) }
$a2 = Fiber.new { r = c2.transfer; p [:a2_got, r]; :a2_done }
p [:root_got2, $a2.resume]

e3 = Fiber.new { :e_end }
d3 = Fiber.new { r = e3.transfer; p [:d_got, r]; :d_end }
a3 = Fiber.new { p [:a3_got, d3.resume]; :a3_end }
p [:root_got3, a3.resume]

$outer = Fiber.new do
  inner = Fiber.new { mid = Fiber.new { $outer.transfer }; mid.transfer }
  inner.resume
rescue FiberError => e
  p e.message
end
$outer.resume

p(Thread.new do
  bb = Fiber.new { :bb }
  aa = Fiber.new { [:aa_got, bb.transfer] }
  aa.resume
end.value)
