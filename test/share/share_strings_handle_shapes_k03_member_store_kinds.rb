# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
class O; attr_accessor :a, :b, :c, :d, :e, :f; end
def id(t) = t
c = ARGV.size == 0
s = +"abc"
pr = ->(q) { q }
o = O.new
o.a = (c ? s : +"q")
o.b = id(s)
o.c = s.then { |q| q }
o.d = pr.(s)
o.e = (z = s)
o.f = (1; s)
s << "!"
p [o.a, o.b, o.c, o.d, o.e, o.f].map { |x| x.equal?(s) }, o.a
