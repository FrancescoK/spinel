s = +"abc"
t = s
def y(&b) = (@b = b); y { |v| v << "!" }; @b.call(s)
p s
p t
