# An empty array literal on the right of a multiple assignment is a tuple
# of no elements: every fixed target takes nil and a splat target an empty
# array, before, after or around the splat.
a, *r = []
p a, r

b, c = []
p b, c

*s, d = []
p s, d

e, *t, f = []
p e, t, f

def build
  g, *u = []
  [g, u]
end
p build
