# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
c = ARGV.size == 0
s = +"abc"
r = (x, y = 1, 2, (c ? s : +"r"))
r[2] << "!"
p s
