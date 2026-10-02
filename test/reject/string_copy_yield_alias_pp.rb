# This observable String copy is refused: yield alias pp.
def y(u) = yield(u)
s = String.new("a")
t = pp(s)
y(s) { |q| l = -> { q << "#" }; l.() }
puts t
