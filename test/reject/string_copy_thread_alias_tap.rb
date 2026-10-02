# This observable String copy is refused: thread alias tap.
s = String.new("a")
t = s.tap { }
Thread.new(s) { |q| q << "#" }.join
puts t
