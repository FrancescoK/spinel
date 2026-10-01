# Regexp.union(*a): a's elements are the operands
a = ["a", "b."]
p Regexp.union(*a).source
p Regexp.union(*a).match?("b."), Regexp.union(*a).match?("bx")

def schemes_re(s = nil)
  return "none" unless s
  Regexp.union(*s).source
end
p schemes_re, schemes_re(["http", "https"])

e = []
p Regexp.union(*e).source

# a boxed scalar splats to itself, nil to nothing
[nil, "a.b", ["x", "y"]].each { |v| p Regexp.union(*v).source }
