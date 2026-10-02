# This observable String copy is refused: thread repeat.
def m
  puts $s
  Thread.new($s) { |q| q << "#" }.join
end
$s = String.new("a")
m
m
