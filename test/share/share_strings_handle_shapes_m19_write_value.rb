# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
s = +"abc"
x, y = (z = s), (w = z)
x << "!"
p s, y, z, w, x.equal?(s), w.equal?(s)
