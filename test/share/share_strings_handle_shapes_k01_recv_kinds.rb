# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
def id(t) = t
c = ARGV.size == 0
s = +"abc"
pr = ->(q) { q }
n = c ? nil : +"n"
(z = s) << "1"
id(s) << "2"
s.then { |q| q } << "3"
pr.(s) << "4"
(n || s) << "5"
(begin; s; end) << "6"
(case c when true then s else +"o" end) << "7"
(1; s) << "8"
s.itself << "9"
p s, z.equal?(s)
