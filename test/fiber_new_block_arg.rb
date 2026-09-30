# Fiber.new(&x) and Thread.new(&x) run x, with what #resume or Thread.new
# passes, for a Method, a proc or a lambda.

def work(x) = x * 3
f = Fiber.new(&method(:work))
p f.resume(4)

pr = proc { |a| Fiber.yield(a + 1); :done }
g = Fiber.new(&pr)
p g.resume(1)
p g.resume

sum = ->(a, b) { a + b }
p Fiber.new(&sum).resume(2, 3)
begin
  Fiber.new(&sum).resume(1)
rescue ArgumentError => e
  p e.message
end

def steps
  Fiber.yield 1
  2
end
k = Fiber.new(&method(:steps))
p k.resume, k.resume

DOUBLE = ->(x) { x * 2 }
p Fiber.new(&DOUBLE).resume(21)
p Fiber.new(&->(s) { s.upcase }).resume("hi")

class Box
  def initialize = @pr = proc { |a, b| [a, b] }
  def run = Fiber.new(&@pr).resume(1, 2)
end
p Box.new.run

opt = proc { |a, b = 5| [a, b] }
p Fiber.new(&opt).resume(1)
p Fiber.new(&opt).resume([7, 8])

# the fiber keeps the proc it was made with
later = proc { |v| v + 1 }
lf = Fiber.new(&later)
later = proc { |v| v + 100 }
p lf.resume(1)

tp = proc { |a| a.to_s * 2 }
p Thread.new(7, &tp).value
def m0 = :m
p Thread.new(&method(:m0)).value
p Thread.new(1, 2, &sum).value
