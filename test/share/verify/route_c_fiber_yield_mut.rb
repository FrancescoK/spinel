s = +"abc"
t = s
f = Fiber.new { Fiber.yield s }; f.resume << "!"
p s
p t
