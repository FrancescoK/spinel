# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
n = ARGV.size == 0 ? nil : +"n"
s = +"abc"
x, y = (n || s), (n && s)
x << "!"
p s, x, y, x.equal?(s)
