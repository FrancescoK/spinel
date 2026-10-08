# Flag-only: under --share-strings, an Array literal's element takes the
# value of a method that answers its parameter on one path, s itself, as a
# copy: refused.
$cnd = true
def pick(x) = $cnd ? x : +"y"
s = +"abc"
a = [pick(s)]
a[0] << "!"
p s
