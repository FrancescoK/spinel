s = +"abc"
t = s
Fiber.new { s << "!" }.resume
p s
p t
