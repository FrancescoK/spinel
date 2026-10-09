s = +"abc"
t = s
f = Fiber.new { s }; f.resume << "!"
p s
p t
