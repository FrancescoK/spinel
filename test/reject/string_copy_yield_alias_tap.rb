# This observable String copy is refused: yield alias tap.
def y(u) = yield(u)
s = String.new("a")
t = s.tap { }
y(s) { |q| l = -> { q << "#" }; l.() }
puts t
