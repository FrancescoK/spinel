# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
s = +"abc"
x, y = s.then { |q| q }, s.tap { |q| q << "-" }
x << "!"
y << "?"
p s, x.equal?(s), y.equal?(s)
