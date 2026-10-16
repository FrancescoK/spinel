# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
def id(t) = t
c = ARGV.size == 0
s = +"abc"
$a, $b, $d = id(s), (c ? s : +"q"), s.then { |q| q }
s << "!"
p [$a, $b, $d].map { |x| x.equal?(s) }, $b
