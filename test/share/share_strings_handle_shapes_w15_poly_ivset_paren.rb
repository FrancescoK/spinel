# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
class PA; def pick(t) = t; end
class PB; def pick(t) = t.dup; end
class O; attr_reader :v; end
px = ARGV.size == 0 ? PA.new : PB.new
s = +"abc"
o = O.new
o.instance_variable_set(:@v, (px.pick(s)))
o.v << "!"
p s, o.v.equal?(s)
