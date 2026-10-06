# A Thread or Fiber body made in an iteration block that writes the block's
# parameter shares that iteration's binding, even when nothing else in the
# block names the parameter.
3.times { |n| t = Thread.new { n += 1; n }; p t.value }
3.times { |n| f = Fiber.new { n += 1; n }; p f.resume }
[1, 2].each_with_index { |x, i| f = Fiber.new { x += i; x }; p f.resume }
r = 3.times.map { |n| Thread.new { n *= 2; n } }.map(&:value)
p r
[[1, 2]].each { |a| 2.times { |j| t = Thread.new { a += [j]; a }; p t.value } }
c = Fiber.new { 2.times { |i| g = Fiber.new { i += 5; i }; Fiber.yield g.resume }; :done }
p c.resume, c.resume, c.resume
3.times { |n| t = Thread.new { n = "s#{n}"; n }; p t.value }
