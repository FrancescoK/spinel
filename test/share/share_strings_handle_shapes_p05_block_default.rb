# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
s = +"abc"
pr = proc { |a, b = a| b << "!"; b.equal?(a) }
p pr.call(s), s
