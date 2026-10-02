# This observable String copy is refused: yield repeat lambda.
def y(u) = yield(u)
m = -> {
  puts $s
  y($s) { |q| l = -> { q << "#" }; l.() }
}
$s = String.new("a")
m.call
m.call
