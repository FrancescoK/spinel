# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
$log = []
def lg(t, s) = ($log << t; s)
c = ARGV.size == 0
s = +"abc"
u = +"zz"
x, y, z = lg("a", s), (c ? lg("b", s) : u), lg("c", s.dup)
x << "!"
p s, y, z, $log, y.equal?(s)
