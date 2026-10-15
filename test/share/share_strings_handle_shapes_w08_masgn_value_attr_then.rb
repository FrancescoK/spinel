# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
class O; attr_accessor :v, :w; end
s = +"abc"
o = O.new
r = (o.v, o.w = s.then { |q| q }, 2)
o.v << "!"
p s, o.v.equal?(s)
