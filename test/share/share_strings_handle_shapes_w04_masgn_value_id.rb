# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
def id(t) = t
s = +"abc"
r = (x, y = id(s), 2)
x << "!"
p s, x.equal?(s)
