# This observable String copy is refused: fiber repeat lambda.
m = -> {
  puts $s
  Fiber.new { |q| q << "#" }.resume($s)
}
$s = String.new("a")
m.call
m.call
