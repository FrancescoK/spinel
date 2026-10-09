s = +"abc"
t = s
def y(x, &b) = b.call(x); y(s) { |v| v << "!" }
p s
p t
