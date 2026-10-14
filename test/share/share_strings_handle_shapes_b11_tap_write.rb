# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
s = +"abc"
(z = s).tap { |q| q << "!" }
p s, z, z.equal?(s)
