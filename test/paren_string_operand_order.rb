# A parenthesized String operand runs before a call to its right whose boxed
# answer is converted, as CRuby evaluates left to right (#9258), and stays
# the String itself where a call stores it.
def t(n) = (puts "t#{n}"; n)

g = nil
g = ->(d) { puts "g#{d}"; d > 0 ? "x" : (s = "k#{t(1)}") + g.call(d + 1) }
p g.call(0)

h = {}
h[:k] = (o = +"d")
o << "x"
p h

def pick(x) = (puts "pick"; x)
box = [1, "y"][1]
r = (u = +"p") + pick(box)
u << "!"
p r, u

a = []
a.push((w = +"q"), pick(box))
w << "?"
p a
