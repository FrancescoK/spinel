# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
def f(t) = (t << "x"; "y")
s = +"abc"
u = s
(+s).insert(0, f(s))
String(s)[0] = f(s)
p u, u.equal?(s)
