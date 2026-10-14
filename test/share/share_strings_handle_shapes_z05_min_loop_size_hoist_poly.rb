# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
class PA; def pick(t) = t; end
class PB; def pick(t) = t.dup; end
px = ARGV.size == 0 ? PA.new : PB.new
s = +"abc"
n = 0
while s.size < 6 && n < 10
  px.pick(s) << +"!"
  n += 1
end
p s, n
