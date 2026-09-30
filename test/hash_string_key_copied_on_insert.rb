# A Hash stores a frozen copy of an unfrozen String key, so mutating the caller's string later leaves the key alone.
def mk(s) = (+"") << s

k1 = mk("abc"); h1 = {}; h1[k1] = 1; k1 << "d"
p h1, h1["abc"], h1.key?("abc"), h1.keys.first.frozen?, k1.frozen?
k2 = mk("abc"); h2 = {}; h2[k2] = "v"; k2 << "d"
p h2, h2["abc"]
k3 = mk("abc"); h3 = {}; h3[k3] = [1]; h3["z"] = :s; k3 << "d"
p h3, h3["abc"]
k4 = mk("abc"); h4 = {}; h4[k4] = 1; h4[2] = 3; k4 << "d"
p h4, h4["abc"]
k5 = mk("abc"); h5 = {}; h5[k5] = 1; k5.setbyte(0, 120)
p h5, h5["abc"]

k6 = mk("st"); h6 = {}; h6.store(k6, 1); k6 << "!"
k7 = mk("lit"); h7 = { k7 => 1 }; k7 << "!"
k8 = mk("br"); h8 = Hash[[[k8, 1]]]; k8 << "!"
k9 = mk("th"); h9 = [[k9, 1]].to_h; k9 << "!"
k10 = mk("gb"); h10 = [k10].group_by { |x| x.size }; k10 << "!"
k11 = mk("dp"); h11 = Hash.new { |hh, kk| hh[kk] = kk.size }; h11[k11]; k11 << "!"
k12 = mk("mg"); h12 = { "x" => 1 }.merge({ k12 => 2 }); k12 << "!"
p h6, h7, h8, h9, h10, h11, h12

# an update keeps the key object already stored; a frozen key is stored as is
k13 = mk("abc"); h13 = {}; h13[k13] = 1; first = h13.keys.first
h13[mk("abc")] = 2
p h13, h13.keys.first.equal?(first), first.equal?(k13)
f14 = "abc".freeze; h14 = {}; h14[f14] = 1
p h14.keys.first.equal?(f14)

# the stored key is frozen
k15 = mk("key"); h15 = { k15 => 1 }
fk = h15.keys.first
p fk.freeze.equal?(fk), fk.dup.frozen?
begin; fk << "x"; p :noraise; rescue FrozenError => e; p e.class; end
begin; fk.setbyte(0, 65); p :noraise; rescue FrozenError => e; p e.class; end
p h15

# a String held by an Array of mixed values keys by its contents
words = []
w = mk("w"); w << "1"; words << w
h16 = {}
words.each { |x| h16[x] = 1 }
w << "x"
p h16, h16["w1"], h16.key?("w1"), h16[words[0]]
g16 = { "w1" => 5, 2 => 3 }
p g16[mk("w1")]

k17 = mk("a\0b"); h17 = { k17 => 1 }; k17 << "z"
p h17, h17["a\0b"], h17.keys.first.bytesize

# the copies are collected once the hash lets go of them
big = "x" * 3000
h18 = {}
g18 = {}
i = 0
while i < 5000
  k = mk("k")
  k << i.to_s
  h18[k] = i
  kb = big.dup
  kb << i.to_s
  g18[kb] = i if i % 50 == 0
  k << "!"
  h18.delete("k#{i - 100}") if i >= 100
  i += 1
end
GC.start
junk = []
j = 0
while j < 20000
  junk << ("j" + j.to_s)
  j += 1
end
GC.start
p h18.size, h18["k4999"], h18.keys.all?(&:frozen?), g18.size, g18[big + "4950"]
