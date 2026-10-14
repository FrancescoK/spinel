# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
def m(t) = yield(t)
s = +"abc"
m(s) { |q| q << "!" }
p s
