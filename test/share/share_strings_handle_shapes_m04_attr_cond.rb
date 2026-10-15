# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
class O; attr_accessor :v, :w; end
c = ARGV.size == 0
s = +"abc"
o = O.new
o.v, o.w = (c ? s : +"n"), s
o.v << "!"
p s, o.v, o.w, o.v.equal?(s), o.w.equal?(s)
