# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
s = +"abc"
t = s
[s, t].each { |q| q << "!" }
p s, t, t.equal?(s)
