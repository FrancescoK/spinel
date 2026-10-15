# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
def m(a:, b: a)
  b << "!"
  [a, b.equal?(a)]
end
s = +"abc"
p m(a: s), s
