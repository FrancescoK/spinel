# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
s = +"abc"
r = (x, y = (z = s), 2)
x << "!"
p s, z, x.equal?(s)
