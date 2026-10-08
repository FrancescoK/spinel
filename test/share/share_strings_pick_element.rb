# Flag-only: under --share-strings, an Array literal's element takes the
# value of a method that answers its parameter on one path, s itself, as a
# copy: refused.
# The settled return walk now carries the handle on this route; the
# refusal described above is the old behavior.
$cnd = true
def pick(x) = $cnd ? x : +"y"
s = +"abc"
a = [pick(s)]
a[0] << "!"
p s
