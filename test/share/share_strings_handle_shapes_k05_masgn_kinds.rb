# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
def id(t) = t
def yl = yield
c = ARGV.size == 0
s = +"abc"
pr = ->(q) { q }
a, b, d, e, f, g = id(s), (c ? s : +"q"), s.then { |q| q }, pr.(s), yl { s }, (1; s)
s << "!"
p [a, b, d, e, f, g].map { |x| x.equal?(s) }, g
