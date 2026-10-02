# This observable String copy is refused: yield target global.
def y(u) = yield(u)
$s = "lit"
$s, = [String.new("a")]
y($s) { |q| l = -> { q << "#" }; l.() }
puts $s
