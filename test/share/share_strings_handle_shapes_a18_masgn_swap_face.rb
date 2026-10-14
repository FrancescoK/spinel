# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
c = ARGV.size == 0
s = +"s"
t = +"t"
r = (s, t = (c ? t : +"q"), s)
s << "1"
t << "2"
p s, t, r, r[0].equal?(s), r[1].equal?(t)
