# A multiple write's target takes the handle of each value the String plan
# gives as one, whatever its producer: a conditional, a bang on a boxed
# receiver, a call answering its receiver, a proc's answer, a `then` or a
# yield, into a local, an instance variable, a global or an attribute. The
# String stays one object under two names: a change through either shows in
# both, and equal? answers true.
class O; attr_accessor :v; end
def idf(x) = x
def yy = yield
c = ARGV.size == 0
s = +"abc"
a = [s, 1]
pr = proc { s }
x, y = (c ? s : a[0]), 1
x << "1"
p s, x.equal?(s), y
x, y = 1, s.then { |t| t }
y << "2"
p s, y.equal?(s)
class K
  def go(s, a)
    @x1, @y1 = idf(s), a[0].upcase!
    @x1 << "3"; @y1 << "4"
    p s, @x1.equal?(s), @y1.equal?(s)
  end
end
K.new.go(s, a)
$g, $h = pr.call, yy { s }
$g << "5"; $h << "6"
p s, $g.equal?(s), $h.equal?(s)
o = O.new
o.v, y = (s << "7"), 1
o.v << "8"
p s, o.v.equal?(s), y
x, y = 2, (c ? a[0] : s)
y << "9"
p s, x, y.equal?(s)
x, y = (1; s), s.itself
x << "a"
p s, x.equal?(s), y.equal?(s)
