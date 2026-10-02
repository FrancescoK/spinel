# This observable String copy is refused: yield alias append.
def y(u) = yield(u)
s = String.new("a")
t = (s << "")
y(s) { |q| l = -> { q << "#" }; l.() }
puts t
