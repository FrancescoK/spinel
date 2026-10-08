# spinel: gc-minor
# Flag-only: under --share-strings, an Array literal's element takes the
# value of a method that answers its parameter on one path, s itself, as a
# copy: refused.
# The mixed return route now carries the handle, so this path is accepted.
$cnd = true
def pick(x) = $cnd ? x : +"y"
s = +"abc"
a = [pick(s)]
a[0] << "!"
p s

$cnd = false
a = [pick(s)]
a[0] << "?"
p s, a
