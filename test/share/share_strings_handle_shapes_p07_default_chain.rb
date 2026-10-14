# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
def m(a, b = a, c = b)
  c << "!"
  [a, b, c, c.equal?(a)]
end
s = +"abc"
p m(s), s
