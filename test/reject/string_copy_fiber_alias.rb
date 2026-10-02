# This observable String copy is refused: fiber alias.
s = String.new("a")
t = s.itself
Fiber.new { |q| q << "#" }.resume(s)
puts t
