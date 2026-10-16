# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
s = +"abc"
r = [1, 2].each_with_object(s) { |i, acc| acc << i.to_s }
p s, r.equal?(s)
