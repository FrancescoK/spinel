# This observable String copy is refused: fiber alias tap.
s = String.new("a")
t = s.tap { }
Fiber.new { |q| q << "#" }.resume(s)
puts t
