# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
s = +"s"
t = +"t"
r = (s, t = t, s)
s << "!"
p r
