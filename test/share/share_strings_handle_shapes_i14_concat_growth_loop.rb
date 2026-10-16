# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
class PA; def pick(t) = t; end
class PB; def pick(t) = t.dup; end
px = ARGV.size == 0 ? PA.new : PB.new
s = +"ab"
px.pick(s).concat(px.pick(s), px.pick(s)) while s.size < 200
p s.size, s[0, 6]
