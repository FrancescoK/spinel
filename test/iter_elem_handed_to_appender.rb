# An iterator's block that hands its element to a method appending to its
# parameter appends to the element itself in CRuby: the Array holds the
# one String. Spinel made a container's Strings handles only when the block
# appended to its element in place, so `a.each { |e| go(e) }` with
# `def go(e) = (e << x; nil)` grew the block parameter's copy and the Array
# kept its old bytes. Each probe appends LONG, which always reallocates.
# spinel: gc-minor
LONG = "!" * 100
def go(e) = (e << LONG; nil)
def gc(e) = (e.concat(LONG); nil)
def g2(e) = (go(e); nil)
class B
  def put(e) = (e << LONG; nil)
end

a = [+"p", +"q"]; a.each { |e| go(e) }; p a.map(&:size)
b = [+"r"]; b.each { |e| gc(e) }; p b.map(&:size)
c = [+"s"]; c.each { |e| g2(e) }; p c.map(&:size)
d = [+"t", +"u"]; d.each_with_index { |e, i| go(e) if i == 1 }; p d.map(&:size)
f = [+"v"]; bx = B.new; f.each { |e| bx.put(e) }; p f.map(&:size)
g = [+"w"]; g.map { |e| go(e); e.size }; p g.map(&:size)
s = +"y"; k = [s]; k.each { |e| go(e) }; p s.size

# a block that only reads leaves the elements; the bytes survive; a frozen
# element still raises
m = [+"z"]; m.each { |e| e.size }; p m.map(&:size)
n = [+"n\0o"]; n.each { |e| go(e) }; p n.map(&:size), n[0][0, 3]
o = ["fz".freeze]
begin
  o.each { |e| go(e) }
rescue FrozenError => ex
  p ex.class
end
