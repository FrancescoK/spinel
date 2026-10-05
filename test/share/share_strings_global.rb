# Flag-only: without the flag (as on master) each read is a copy and misses the change.
# A global the rule shares holds the shared handle: a read bound to a local,
# a method answering the global, and a global bound to a local's String all
# name one String.
$g = +"g"
t = $g
t << "1"
p $g
def get = $g
get << "2"
p $g, t
s = +"s"
$h = s
$h << "!"
p s
$g += "x"
p $g, t
