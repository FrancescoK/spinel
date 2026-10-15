# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
c = ARGV.size == 0
s = +"abc"
r = (x, y = (c ? s : +"q"), s)
r[0] << "!"
p s, x, y, r, x.equal?(s)
