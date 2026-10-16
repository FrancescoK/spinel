# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
s = +"abc"
x, y = (begin; s; rescue; +"r"; end), (s rescue nil)
x << "!"
p s, x, y, x.equal?(s), y.equal?(s)
