# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
c = ARGV.size == 0
s = +"abc"
[[s, 1]].each { |q, n| q << n.to_s }
s.then { |q| x, y = q, (c ? q : +"z"); y << "!" }
p s
