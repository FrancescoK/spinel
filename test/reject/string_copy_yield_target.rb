# This observable String copy is refused: yield target.
def y(u) = yield(u)
s = "lit"
s, = [String.new("a")]
y(s) { |q| l = -> { q << "#" }; l.() }
puts s
