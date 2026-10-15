# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
s = +"abc"
u = s.tap { |q| q.upcase! }
p s, u, u.equal?(s)
