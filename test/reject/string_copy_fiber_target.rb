# This observable String copy is refused: fiber target.
s = "lit"
s, = [String.new("a")]
Fiber.new { |q| q << "#" }.resume(s)
puts s
