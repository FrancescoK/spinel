# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
def id(t) = t
s = +"abc"
x, y = id(s), id(s)
x << "!"
p s, y, x.equal?(s), y.equal?(s)
