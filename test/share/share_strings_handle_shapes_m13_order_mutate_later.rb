# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
c = ARGV.size == 0
s = +"abc"
t = +"zz"
x, y = (c ? s : t), (s << "!"; s.size)
p x, y, s, x.equal?(s)
