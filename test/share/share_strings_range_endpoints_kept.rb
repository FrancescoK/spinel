# A String Range keeps the String objects its endpoints were made from
# whatever the share rule says about them (#8321): a fresh endpoint is
# reached again through #begin, an ivar's String is changed in place by
# another method, and a Range held by a Struct, a Data, a global, a
# constant or a class variable reads its endpoints as they are now.
# spinel: gc-stress

# a fresh endpoint, changed through the Range
f = (+"a").."c"
f.begin << "b"
p f, f.to_a, f.begin.frozen?

# an ivar's String, changed by another method
class Bumper
  def initialize
    @s = String.new("a")
    @r = (@s.."c")
  end
  def bump = @s << "b"
  attr_reader :r
end
bu = Bumper.new
bu.bump
p bu.r.begin, bu.r, bu.r.to_a

# both endpoints, every reader, after the change
lo = String.new("ab")
hi = String.new("ad")
r = (lo...hi)
lo << "b"
hi << "a"
p r.begin, r.end, r.first, r.last, r.min, r.max, r.minmax
p r.to_s, r.inspect, r.to_a, r.count, r.size, r.exclude_end?
p r.include?("abc"), r.member?("abc"), r.cover?("abz"), r === "ac"
p r == ("abb"..."ada"), r.eql?("abb"..."ada"), r.hash == ("abb"..."ada").hash
p r.first(2), r.dup.begin, r.clone.end
p r.begin.equal?(lo), r.end.equal?(hi), r.frozen?
r.each { |x| print x, " " }
puts

# endless and beginless
e = String.new("x")
en = (e..)
bl = (...e)
e << "y"
p en, en.begin, bl, bl.end, bl.cover?("xx"), en === "xz"

# a frozen literal endpoint stays the literal, frozen
lit = ("aa".."ab")
p lit.begin.frozen?, lit.end.frozen?
begin
  lit.begin << "x"
rescue FrozenError => ex
  p ex.class
end

# a Struct and a Data member, built in the call and read through it
S = Struct.new(:rng)
D = Data.define(:rng)
n = 5
st = S.new(n.to_s..(n + 3).to_s)
dd = D.new(rng: n.to_s..(n + 2).to_s)
t = String.new("s")
st2 = S.new(t.."z")
t << "t"
GC.start
p st.rng, st.rng.to_a, dd.rng, st2.rng.begin, st2
st2.rng = (t.."tz")
t << "u"
p st2.rng.begin, st2.rng.begin.equal?(t)

# a global, a constant and a class variable
g = String.new("g")
$gr = (g..(n.to_s * 2))
KS = String.new("k")
KR = (KS..(n.to_s + "x"))
class Keeper
  @@cr = nil
  def self.set(s) = @@cr = (s.."z")
  def self.get = @@cr
end
cs = String.new("c")
Keeper.set(cs)
g << "h"
KS << "l"
cs << "d"
GC.start
p $gr, KR, Keeper.get, Keeper.get.begin.equal?(cs)

# Array and Hash elements, a method's answer, an old object's ivar
a = String.new("a")
arr = [(a..(n.to_s + "z")), (n.to_s..(n + 1).to_s)]
h = { r: (a.."zz") }
a << "b"
p arr, arr.map(&:begin), h, h[:r].begin
def mk(i)
  s = String.new("k#{i}")
  rr = (s.."z")
  s << "+"
  rr
end
GC.start
p (1..3).map { |i| mk(i) }
class Box
  def put(r) = @r = r
  def r = @r
end
bx = Box.new
3.times { GC.start }
x = String.new("q")
bx.put(x..(x + "z"))
x << "r"
GC.start
p bx.r, bx.r.to_a.size

# identity: a plain variable endpoint is the String itself, a kept one is
# one object however often it is read, and a dup shares the endpoints
pt = String.new("k")
pr = (pt.."z")
p pr.begin.equal?(pt), pr.first.equal?(pt)
ps = String.new("a")
p S.new(ps.."c").rng.begin.equal?(ps)
fr = (+"a")..(+"c")
p fr.end.equal?(fr.end), fr.first.equal?(fr.begin)
fd = fr.dup
p fd.begin.equal?(fr.begin)
fd.begin << "q"
p fr, fd

# #last / #end through a Hash and an Array element change the endpoint
hk = { k: (+"a")..(+"b") }
hk[:k].last << "y"
hk[:k].end << "z"
ak = [(+"a")..(+"b")]
ak[0].last << "w"
ak[0].first << "v"
p hk, ak

# an explicit initialize and send(:initialize) taking a String Range
class Resettable
  def initialize(r) = @r = r
  def reset(r)
    initialize(r)
    self
  end
  attr_reader :r
end
xr = String.new("q")
ro = Resettable.new("a".."b").reset(xr..(xr + "z"))
ro.send(:initialize, xr..(xr + "y"))
xr << "!"
p ro.r

# a kept endpoint read twice is one object; computed endpoints in
# String#clamp and #to_set, an end kept as a handle being there
ce = (+"a").."c"
ca = ce.begin
ce.begin << "z"
p ca.equal?(ce.begin), ce.begin.object_id == ce.begin.object_id, ca
cn = 5
cr = (cn.to_s + "a")..(cn.to_s + "d")
cr.end << ""
p "zz".clamp(cr), "5".clamp(cr), "5b".clamp(cr), cr.to_set.size
ts = "a"..(+"c")
ts.end << "d"
p ts.to_set.include?("cd"), ts.to_set.size
fi = (+"q")..(+"s")
p fi.begin.equal?(fi.begin), fi.begin.object_id == fi.first.object_id

# freezing an endpoint freezes the String the Range holds
fz = (+"a")..(+"c")
fz.begin.freeze
fz.last.freeze
p fz.begin.frozen?, fz.first.frozen?, fz.end.frozen?
begin
  fz.first << "z"
rescue FrozenError => fe
  p fe.class
end
begin
  fz.end << "z"
rescue FrozenError => fe
  p fe.class
end
p fz
hs = String.new("h")
hr = (hs.."z")
hr.begin.freeze
p hs.frozen?
class FrozenHolder
  def initialize = @r = ((+"m")..(+"n"))
  attr_reader :r
end
fh = FrozenHolder.new
fh.r.end.freeze
p fh.r.last.frozen?
