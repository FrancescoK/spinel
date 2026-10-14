# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
c = ARGV.size == 0
s = +"abc"
x, y, z = s.dup, (c ? s : s.dup), s
y << "!"
p s, x, y, z, y.equal?(s), x.equal?(s)
