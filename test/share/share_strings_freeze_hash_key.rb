# A frozen String used as a Hash key is stored as it is, so the key is that
# String: the name it was frozen through, every alias of it, an index, a
# literal, store, a key frozen as its own value, and every other route that
# stores a key. An unfrozen key is a frozen copy, as CRuby dups it.
k = +"key"
f = k.freeze
h = {}
h[f] = 1
p h.keys[0].equal?(k), h.keys[0].equal?(f), h.keys[0].frozen?
k2 = +"k2"
f2 = k2.freeze
h2 = {}
h2[k2] = 1
p h2.keys[0].equal?(f2)
k3 = +"k3"
f3 = k3.freeze
h3 = { k3 => 1 }
p h3.keys[0].equal?(k3), h3.keys[0].equal?(f3)
k4 = +"k4"
f4 = k4.freeze
h4 = {}
h4.store(f4, 1)
p h4.keys[0].equal?(k4)
k5 = +"k5"
h5 = {}
h5[k5] = k5.freeze
p h5.keys[0].equal?(k5), h5.values[0].equal?(k5)
k6 = +"k6"
j6 = k6
j6 << "!"
k6.freeze
h6 = {}
h6[k6] = 1
p h6.keys[0].equal?(k6), h6.keys[0].equal?(j6), h6.keys[0]
m = +"m"
mm = m
h7 = {}
h7[m] = 1
m << "x"
p h7.keys[0], h7.keys[0].equal?(m), h7.keys[0].frozen?, mm
h7.each_key { |kk| p kk.equal?(m) }

# the key keeps its String alive after the names go
def fill(h, i)
  n = +"n#{i}"
  a = n
  a << "!"
  h[n.freeze] = i
end
hh = {}
50.times { |i| fill(hh, i) }
junk = []
500.times { |i| junk << ("x" * 40) + i.to_s }
p hh.size, hh.keys.first, hh.keys.last, hh.keys.all?(&:frozen?), hh["n7!"]

# the same key through the other routes that store one: to_h, Hash[],
# group_by, tally, to_h with a block, a block's store, a default proc, a
# block parameter and a method parameter
fk = +"fk"
fk << "1"
fk.freeze
fa = [fk]
fp = [[fk, 1]]
p fp.to_h.keys.first.equal?(fk), Hash[fp].keys.first.equal?(fk)
p fa.group_by { |x| x }.keys.first.equal?(fk), fa.tally.keys.first.equal?(fk)
p fa.to_h { |x| [x, 1] }.keys.first.equal?(fk)
p fa.each_with_object({}) { |x, hh| hh[x] = 1 }.keys.first.equal?(fk)
fd = Hash.new { |hh, kk| hh[kk] = 1 }
fd[fk]
p fd.keys.first.equal?(fk)
fz = {}
[fk].each { |x| fz[x] = 1 }
p fz.keys.first.equal?(fk)
def put(hh, x) = hh[x] = 1
fy = {}
put(fy, fk)
p fy.keys.first.equal?(fk), fy.keys.first.frozen?

# freeze over one append on a method's answer freezes the String it handed back
def id(x) = x
s = +"s"
t = s
r = (id(s) << "x").freeze
p r.equal?(t), t.frozen?, r
