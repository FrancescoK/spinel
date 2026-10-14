# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
c = ARGV.size == 0
s = +"abc"
r = [1].map { |i| x, y = (c ? s : +"q"), i }
r[0][0] << "!"
p s, r[0][0].equal?(s)
