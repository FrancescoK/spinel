# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
class O; attr_accessor :a, :b, :c; end
def id(t) = t
c = ARGV.size == 0
s = +"abc"
o = O.new
o.a, o.b, o.c = id(s), (c ? s : +"q"), s.then { |q| q }
s << "!"
p [o.a, o.b, o.c].map { |x| x.equal?(s) }
