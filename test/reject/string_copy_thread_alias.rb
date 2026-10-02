# This observable String copy is refused: thread alias.
s = String.new("a")
t = s.itself
Thread.new(s) { |q| q << "#" }.join
puts t
