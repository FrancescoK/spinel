# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
class PA; def pick(t) = t; end
class PB; def pick(t) = t.dup; end
px = ARGV.size == 0 ? PA.new : PB.new
def m(px, s)
  x, y = px.pick(s), 1
end
s = +"abc"
r = m(px, s)
r[0] << "!"
p s, r[0].equal?(s)
