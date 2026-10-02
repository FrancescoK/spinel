# This observable String copy is refused: yield repeat.
def y(u) = yield(u)
def m
  puts $s
  y($s) { |q| l = -> { q << "#" }; l.() }
end
$s = String.new("a")
m
m
