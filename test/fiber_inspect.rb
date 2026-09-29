# Fiber#inspect and #to_s show CRuby's #<Fiber:0x... file:line (status)>,
# typed or boxed. The test harness compiles without line positions, so
# the line is masked.

def shape(s)
  s.sub(/0x\h+/, "0x").sub(/ \S*fiber_inspect\.rb:\d+/, " fiber_inspect.rb:N")
end

f = Fiber.new do
  Fiber.yield shape(Fiber.current.inspect)
  inner = Fiber.new { Fiber.yield }
  inner.resume
  Fiber.yield shape(inner.inspect)
  :done
end
puts shape(f.inspect)
puts f.resume
puts shape(f.to_s)
puts shape("#{f}")
puts f.resume
f.resume
puts shape(f.inspect)
p f.inspect == f.to_s

outer = Fiber.new do
  inner = Fiber.new { Fiber.yield }
  inner.resume
  Fiber.yield
end
outer.resume
puts shape(outer.inspect)
puts shape(Fiber.current.inspect)

$outer = Fiber.new { Fiber.new { puts shape($outer.inspect) }.resume }
$outer.resume

boxed = [Fiber.new { }, 1][0]
puts shape(boxed.inspect)
puts shape(boxed.to_s)

t = Thread.new { 1 }
t.join
puts shape([t, 1][0].to_s)
