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

# splats of a variable: the count is only known at run time
n1 = [nil]; n12 = [1, 2]; nn = [[1, 2]]; n23 = [2, 3]; ne = []
sa = Fiber.new { |*x| p x }
sa.resume(*n1)
sb = Fiber.new { |x| p x }
sb.resume(*n12)
sc = Fiber.new { |*x| p x }
sc.resume(*nn)
sd = Fiber.new { Fiber.yield(1, *n23); Fiber.yield(*ne, 4); Fiber.yield(*ne) }
3.times { p sd.resume }
se = Fiber.new { |*x| p x }
se.resume(0, *n12)
st = Fiber.new { |x| p x; root.transfer }
st.transfer(*n12)
sx = [Fiber.new { |*x| p x }, 1][0]
sx.resume(*n1)
