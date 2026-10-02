# This observable String copy is refused: fiber repeat.
def m
  puts $s
  Fiber.new { |q| q << "#" }.resume($s)
end
$s = String.new("a")
m
m
