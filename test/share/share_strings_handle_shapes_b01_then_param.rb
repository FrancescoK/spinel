# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
s = +"abc"
r = s.then { |q| q << "!"; q }
p s, r.equal?(s)
