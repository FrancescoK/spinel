# Fiber.yield and resume/transfer with several values, one array, or none,
# bind the way CRuby's block parameters do.

f = Fiber.new { |a, b| x, y = Fiber.yield(a, b); x + y }
p f.resume(1, 2)
p f.resume(3, 4)

g = Fiber.new do
  Fiber.yield
  Fiber.yield 1, 2
  Fiber.yield [3, 4]
  Fiber.yield(*[5, 6])
  Fiber.yield(*[7])
  Fiber.yield(*[])
end
7.times { p g.resume }

one = Fiber.new { |a| p a }
one.resume(1, 2)
arr = Fiber.new { |a| p a }
arr.resume([1, 2])

rest = Fiber.new { |*a| p a; p Fiber.yield; p Fiber.yield }
rest.resume([1, 2])
rest.resume(3, 4)
rest.resume
[nil, [], [1, 2, 3]].each do |args|
  r = Fiber.new { |*a| p a }
  if args.nil? then r.resume(nil) else r.resume(*args) end
end

pair = Fiber.new { |a, b| p [a, b] }
pair.resume([1, 2])
pair1 = Fiber.new { |a, b| p [a, b] }
pair1.resume(1)
pair0 = Fiber.new { |a, b| p [a, b] }
pair0.resume

root = Fiber.current
tf = Fiber.new { |a| p a; root.transfer }
tf.transfer(7, 8)

boxed = [Fiber.new { |a| p a }, 1][0]
boxed.resume(3, 4)
