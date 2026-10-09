s = +"abc"
f = Fiber.new { s }; r = f.resume
r << "!"
p s
p r
