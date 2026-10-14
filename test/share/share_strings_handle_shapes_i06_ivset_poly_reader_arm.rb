# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
class PA; def initialize(t) = @t = t; def pick = @t; end
class PB; def initialize(t) = @t = t; def pick = @t.dup; end
class O; attr_reader :v; end
s = +"abc"
px = ARGV.size == 0 ? PA.new(s) : PB.new(s)
o = O.new
o.instance_variable_set(:@v, px.pick)
o.v << "!"
p s, o.v.equal?(s)
