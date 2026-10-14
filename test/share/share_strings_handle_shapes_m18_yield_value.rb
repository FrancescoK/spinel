# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
def m
  x, y = yield, 1
  x << "!"
  [x, y]
end
s = +"abc"
r = m { s }
p s, r, r[0].equal?(s)
