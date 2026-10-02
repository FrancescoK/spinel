# This observable String copy is refused: thread repeat lambda.
m = -> {
  puts $s
  Thread.new($s) { |q| q << "#" }.join
}
$s = String.new("a")
m.call
m.call
