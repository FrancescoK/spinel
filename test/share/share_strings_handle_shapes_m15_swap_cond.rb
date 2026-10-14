# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
c = ARGV.size == 0
a = +"aa"
b = +"bb"
ka = a
a, b = (c ? b : a), a
a << "!"
b << "?"
p a, b, ka, b.equal?(ka)
