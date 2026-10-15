# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
class PA; def pick(t) = t; end
class PB; def pick(t) = t.dup; end
px = ARGV.size == 0 ? PA.new : PB.new
def junk = Array.new(300) { |i| "j" * 50 + i.to_s }.size.to_s
s = +"abc"
px.pick(s).concat(px.pick(s), junk, px.pick(s))
p s
