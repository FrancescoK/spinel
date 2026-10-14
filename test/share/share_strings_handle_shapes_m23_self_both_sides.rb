# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
c = ARGV.size == 0
s = +"abc"
t = +"zz"
k = s
s, t = t, (c ? s : t)
t << "!"
p s, t, k, t.equal?(k)
