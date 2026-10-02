# This observable String copy is refused: yield alias concat.
def y(u) = yield(u)
s = String.new("a")
t = s.concat("")
y(s) { |q| l = -> { q << "#" }; l.() }
puts t
