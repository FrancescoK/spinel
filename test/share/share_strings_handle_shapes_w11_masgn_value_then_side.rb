# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
$n = 0
s = +"abc"
r = (x, y = s.then { |q| $n += 1; q }, 1)
p $n
x << "!"
p s, x.equal?(s)
