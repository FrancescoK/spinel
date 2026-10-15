# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
class O
  def v = @v
  def v=(x); @v = x; end
  attr_accessor :w
end
c = ARGV.size == 0
s = +"abc"
o = O.new
o.v, o.w = (c ? s : +"q"), s.then { |q| q }
o.v << "!"
o.w << "?"
p s, o.v.equal?(s), o.w.equal?(s)
