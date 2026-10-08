# `+=` on a String the rule shares makes a new String: the old one, and
# every other name for it, stay as they were.
s = +"a"; t = s; t << "b"
s += "c"
p s, t
s << "d"
p s, t
def grow(x) = (x << "!"; x += "?"; x)
u = +"u"; v = u
p grow(u), u, v
$g = +"g"; h = $g; h << "1"; $g += "2"
p $g, h
