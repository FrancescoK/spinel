# A Symbol read out of a container answers start_with?, end_with? and
# match? over its name, and intern as itself, as a typed Symbol does; a
# String read out of one interns too.
s = [:Foo, 0][0]
p s.start_with?("F")
p s.start_with?("x", "Fo")
p s.end_with?("oo", "x")
p s.end_with?("F")
p s.match?(/o+/)
p s.match?(/F/, 1)
p s.intern
t = ["bar", 0][0]
p t.intern
p [t.start_with?("b"), t.match?(/ar/)]
u = [:"héllo", 0][0]
p [u.start_with?("hé"), u.end_with?("lo"), u.match?(/é/)]
n = [nil, :x][0]
e = (n.start_with?("a") rescue $!)
p e.message
e = (n.intern rescue $!)
p e.message
