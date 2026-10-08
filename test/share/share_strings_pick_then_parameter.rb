# Flag-only: under --share-strings, then's parameter takes the value of a
# method that answers its parameter on one path, s itself, as a copy.
# The settled return walk now carries the handle on this route; the
# refusal described above is the old behavior.
$cnd = true
def pick(x) = $cnd ? x : +"y"
s = +"abc"
pick(s).then { |t| t << "!" }
p s
