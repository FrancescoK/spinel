# spinel: gc-minor
# Flag-only: under --share-strings, then's parameter takes the value of a
# method that answers its parameter on one path, s itself, as a copy.
# The mixed return route now carries the handle, so this path is accepted.
$cnd = true
def pick(x) = $cnd ? x : +"y"
s = +"abc"
pick(s).then { |t| t << "!" }
p s

$cnd = false
pick(s).then { |t| t << "?"; p t }
p s
