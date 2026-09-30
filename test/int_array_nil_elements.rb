# An Integer or Float array holds nil as its slot's sentinel (SP_INT_NIL, or
# the Float NaN payload) once a nilable value is stored in it, and inspect and
# compact already read it as nil. The searches folded a nil needle to a miss,
# join and puts printed the sentinel's number, sum added it and min, max and
# sort ordered it where CRuby raises, and a copy into a poly array (a set
# operation, ==, a zip row, a splat) boxed it as a number.
def try
  yield
rescue => e
  e.class
end

class Box
  def initialize(v) = (@v = [v, 9])
  attr_reader :v
  alias vals v
end

ints = [5, 6]
flts = [1.5, 2.5]
i = ARGV.size + 7
b = ints[i]
f = flts[i]
x = [b, 3]
y = [4.5]
y << f
p x.include?(nil), x.index(nil), x.rindex(nil), x.count(nil)
p y.include?(nil), y.index(nil), y.count(nil), Box.new(b).v.count(nil)
vs = Box.new(b).vals
p vs.include?(nil), vs.index(nil), try { vs.sum }
p x.join("-"), y.join("-"), x * ",", "%s|%p" % y
puts x, y
p try { x.sum }, try { y.sum }, try { x.sum(0.5) }, try { x.max }, try { y.min }
p try { x.sort }, try { y.minmax }, [b, b].sort, [f].max
p x == [nil, 3], y == [4.5, nil], y == [4.5, f], x.eql?([nil, 3]), x.hash == [nil, 3].hash
p x - [nil], y & [nil], x | [nil], y.intersect?([nil])
p x.zip([1])[0][0].nil?, [1, 2, 3].zip(y)[2][1].nil?, y.product([0]), [*y, "s"][1].nil?
p((x + [nil])[0].nil?, [x].flatten[0].nil?, x.all?, y.none?, x.one?, x.any?(nil))
p try { x.pack("q*") }, try { y.pack("d*") }
n = [nil, "s"][ARGV.size]
p x.include?(b), [7].include?(b), y.include?(f), x.index(n), y.include?(n)
z = [b, 8]
p z.delete(nil), z, [f, 2.5].compact!
