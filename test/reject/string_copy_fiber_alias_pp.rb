# This observable String copy is refused: fiber alias pp.
s = String.new("a")
t = pp(s)
Fiber.new { |q| q << "#" }.resume(s)
puts t
