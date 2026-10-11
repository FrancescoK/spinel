# spinel: share
# spinel: gc-stress
# String#-@ / #dedup of a String nothing else holds: the answer of a
# non-bang call, of a bang through a shared handle (whose answer the handle
# copied), of an interpolation, an element, a reader or a poly value. The
# interning copy allocates, and that allocation could sweep the receiver it
# was about to copy, so SPINEL_GC_STRESS=2 read back poisoned bytes. Each
# line dedups contents of its own: a second dedup of equal contents answers
# the interned entry without copying.
def take(v) = v
class Box
  attr_reader :s
  def initialize(s) = @s = s
end
St = Struct.new(:v)

s = +"loc1"
r = -s.upcase!
p [r, r.frozen?, s]
s = +"loc2"
p take(-s.sub!("l", "z"))
s = +"loc3"
r = (s.upcase!).dedup
p [r, r.frozen?]
s = +"plain4"
p(-s.upcase, (s + "!").dedup, -"<#{s}>")
a = [+"elt5"]
r = -a[0].upcase!
p [r, r.frozen?, a]
o = Box.new(+"rd6")
r = -o.s.upcase!
p [r, r.frozen?, o.s]
h = {k: +"hv7"}
p take((h[:k].upcase!).dedup), h
st = St.new(+"st8")
p(-st.v.upcase!, st.v)
x = ARGV.size > 5 ? 1 : +"pv9"
r = -x.upcase!
p [r, r.frozen?, x]
p((s * 2).send(:-@), -(1234567.to_s))
b = [+"m10", +"n10"]
p b.map { |e| -e.upcase! }
