# This observable String copy is refused: thread alias print.
s = String.new("a")
t = p(s)
Thread.new(s) { |q| q << "#" }.join
puts t
