s = +"f"
t = s
th = Thread.new(s) { |x| 30.times { |i| x << i.to_s; junk = "z" * 40 }; x }
r = th.value
f = Fiber.new { |x| 10.times { x << "y"; Fiber.yield x }; x }
11.times { f.resume(s) }
p s.size, t.equal?(s), r.equal?(s)
