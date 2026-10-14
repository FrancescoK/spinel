# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
def id(t) = t
c = ARGV.size == 0
s = +"abc"
pr = ->(q) { q }
id(s).then { |q| q << "1" }
(c ? s : +"q").tap { |q| q << "2" }
pr.(s).then { |q| q << "3" }
(z = s).tap { |q| q << "4" }
s.then { |q| q }.tap { |q| q << "5" }
(1; s).then { |q| q << "6" }
p s
