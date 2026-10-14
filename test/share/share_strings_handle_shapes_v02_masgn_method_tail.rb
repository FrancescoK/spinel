# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
def m(s, c)
  x, y = (c ? s : +"q"), 1
end
s = +"abc"
r = m(s, ARGV.size == 0)
r[0] << "!"
p s, r[0].equal?(s)
