s = +"abc"
t = s
def y(x) = yield(x); y(s) { |v| v << "!" }
p s
p t
