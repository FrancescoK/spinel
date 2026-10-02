# This observable String copy is refused: fiber alias print.
s = String.new("a")
t = p(s)
Fiber.new { |q| q << "#" }.resume(s)
puts t
