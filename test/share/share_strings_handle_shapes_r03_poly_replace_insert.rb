# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
class PA; def pick(t) = t; end
class PB; def pick(t) = t.dup; end
px = ARGV.size == 0 ? PA.new : PB.new
s = +"abc"
px.pick(s).replace("zz")
px.pick(s).insert(0, "x")
px.pick(s).prepend(">")
p s
