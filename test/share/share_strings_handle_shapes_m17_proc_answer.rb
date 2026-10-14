# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
s = +"abc"
pr = ->(q) { q }
x, y = pr.(s), pr.call(s)
x << "!"
p s, y, x.equal?(s), y.equal?(s)
