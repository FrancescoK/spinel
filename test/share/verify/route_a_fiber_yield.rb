s = +"abc"
f = Fiber.new { Fiber.yield s }; r = f.resume
r << "!"
p s
p r
