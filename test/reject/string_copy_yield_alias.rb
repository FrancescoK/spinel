# This observable String copy is refused: yield alias.
def y(u) = yield(u)
s = String.new("a")
t = s.itself
y(s) { |q| l = -> { q << "#" }; l.() }
puts t
