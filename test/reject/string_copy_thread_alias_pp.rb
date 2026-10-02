# This observable String copy is refused: thread alias pp.
s = String.new("a")
t = pp(s)
Thread.new(s) { |q| q << "#" }.join
puts t
