s = +"abc"
t = s
Fiber.new { |x| x << "!" }.resume(s)
p s
p t
