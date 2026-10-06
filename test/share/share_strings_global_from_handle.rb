# Flag-only: a global written from a String local that is a String handle
# holds that handle under --share-strings, so a change made later through
# the local shows through the global, and the String refusals' global route
# stands down there (without the flag the global holds a copy and the route
# refuses).
a = +"a"
a << "b"
$m = (b = a)
p $m.size
a << "c"
p $m, b
t = +"x"
$w = t
t << "y"
p $w
