# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
def id(t) = t
c = ARGV.size == 0
s = +"abc"
pr = ->(q) { q }
(z = s).upcase!
id(s).downcase!
s.then { |q| q }.capitalize!
pr.(s).swapcase!
(c ? s : +"q").reverse!
(1; s).succ!
p s, z.equal?(s)
