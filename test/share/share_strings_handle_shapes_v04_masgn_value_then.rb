# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
s = +"abc"
r = (x, y = s.then { |q| q }, 1)
x << "!"
p s, x.equal?(s)
