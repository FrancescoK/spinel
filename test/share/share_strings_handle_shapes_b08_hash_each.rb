# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
s = +"abc"
h = { a: s, b: s }
h.each { |k, v| v << k.to_s }
p s, h
