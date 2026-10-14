# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
c = ARGV.size == 0
s = +"abc"
t = +"t"
r = (s, t = t, (c ? s : +"q"))
s << "1"; t << "2"
p s, t, r
