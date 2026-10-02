# This observable String copy is refused: yield alias print.
def y(u) = yield(u)
s = String.new("a")
t = p(s)
y(s) { |q| l = -> { q << "#" }; l.() }
puts t
