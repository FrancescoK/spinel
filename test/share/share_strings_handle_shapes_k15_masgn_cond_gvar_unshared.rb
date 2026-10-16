# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
c = ARGV.size == 0
$a, $b = (c ? +"a" : +"b"), 1
$a << "!"
p $a
