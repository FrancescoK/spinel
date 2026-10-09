# spinel: gc-minor
# spinel: gc-stress
# A multiple assignment builds each value into a temporary and then stores
# them one after the other. A String-keyed Hash copies a mutable key into a
# frozen one when it stores it, and that copy can collect, so the first store
# swept the temporary of a later value that nothing else held. Covers two and
# three values with fresh String, Array and object values, Integer and poly
# values, a mixed local and index target list, a nested target, a swap, a
# call that returns the pair, a splat, a Hash passed to a method, a Hash in
# an instance variable and a key that is a local String mutated afterwards,
# beside the single index store, the chained store, `+=` and `||=`, which
# were already rooted. The same holds for a store that runs user code: an
# attribute target whose writer is a compiled method, an index target on an
# object with a user `[]=`, and a receiver typed at run time that mixes a user
# writer with an attr_accessor class.
def gcv(i)
  GC.start
  ("pad" * 150_000).size
  "v#{i}"
end
def gca(i)
  GC.start
  ("pad" * 150_000).size
  [i, i + 1]
end
def gcp(i)
  GC.start
  ("pad" * 150_000).size
  ["p#{i}", "q#{i}"]
end
class Box
  attr_reader :n
  def initialize(n)
    @n = n
  end
end
def gco(i)
  GC.start
  ("pad" * 150_000).size
  Box.new(i)
end

ss = {"a" => "b"}
30.times { |i| ss["k#{i}"], ss["m#{i}"] = "x#{i}", gcv(i) }
p ss.size, ss.keys.uniq.size, ss["k29"], ss["m29"]

sa = {"a" => [0]}
30.times { |i| sa["k#{i}"], sa["m#{i}"] = [i], gca(i) }
p sa.size, sa["k29"], sa["m29"]

so = {"a" => Box.new(0)}
30.times { |i| so["k#{i}"], so["m#{i}"] = Box.new(i), gco(i) }
p so.size, so["k29"].n, so["m29"].n

s3 = {"a" => "b"}
30.times { |i| s3["k#{i}"], s3["m#{i}"], s3["n#{i}"] = "x#{i}", "y#{i}", gcv(i) }
p s3.size, s3["k29"], s3["m29"], s3["n29"]

sp = {"a" => 1, "b" => "x"}
30.times { |i| sp["k#{i}"], sp["m#{i}"] = gcv(i), gcv(i + 1) }
p sp.size, sp["k29"], sp["m29"]

si = {"a" => 1}
30.times { |i| si["k#{i}"], si["m#{i}"] = i, i + 1 }
p si.size, si["k29"], si["m29"]

# an index target beside a local, an attribute and a nested target
class Slot
  attr_accessor :a
end
s5 = {"a" => "b"}
sl = Slot.new
bad = 0
30.times do |i|
  s5["k#{i}"], z = "x#{i}", gcv(i)
  bad += 1 unless z == "v#{i}"
  s5["m#{i}"], sl.a = "y#{i}", gcv(i)
  bad += 1 unless sl.a == "v#{i}"
  s5["n#{i}"], (s5["o#{i}"], q) = "z#{i}", [gcv(i), 1]
end
p bad, s5.size, s5["o29"]

# a swap, a call that returns the pair, a splat
s6 = {"a" => "1", "b" => "2"}
30.times { |i| s6["a"], s6["b"] = s6["b"], gcv(i) }
p s6["a"], s6["b"]
s7 = {"a" => "b"}
30.times { |i| s7["k#{i}"], s7["m#{i}"] = gcp(i) }
30.times { |i| s7["r#{i}"], s7["s#{i}"] = *gcp(i) }
p s7.size, s7["m29"], s7["s29"]

# a Hash passed to a method, held in an instance variable, and a key that
# is a local String changed after the store
def put(h, i)
  h["k#{i}"], h["m#{i}"] = "x#{i}", gcv(i)
end
h8 = {"a" => "b"}
30.times { |i| put(h8, i) }
p h8.size, h8["m29"]
class Holder
  def initialize
    @h = {"a" => "b"}
  end
  def put(i)
    @h["k#{i}"], @h["m#{i}"] = "x#{i}", gcv(i)
  end
  def size = @h.size
end
ho = Holder.new
30.times { |i| ho.put(i) }
p ho.size
h9 = {"a" => "b"}
30.times do |i|
  k1 = +"k#{i}"
  k2 = +"m#{i}"
  h9[k1], h9[k2] = "x#{i}", gcv(i)
  k1 << "!"
end
p h9.size, h9.keys.last, h9["k29"], h9["m29"]

# the single stores, already rooted
t = {"a" => "b"}
u = {"a" => "b"}
30.times { |i| t["k#{i}"] = u["m#{i}"] = gcv(i) }
p t.size, u.size, t["k29"]
w = Hash.new("")
30.times { |i| w["k#{i}"] += gcv(i) }
p w.size, w["k29"]
x = {}
30.times { |i| x["k#{i}"] ||= gcv(i) }
p x.size, x["k29"]

# an attribute target whose writer allocates, a user `[]=`, and a receiver
# typed at run time
class UserW
  attr_reader :a, :b
  def a=(v)
    @a = v
    @junk = "j" * 50 + v.size.to_s
  end
  def b=(v)
    @b = v
  end
end
class PlainW
  attr_accessor :a, :b
end
class UserIx
  def initialize
    @h = {}
  end
  def []=(k, v)
    @h[k] = v
    @junk = "j" * 50 + v.size.to_s
  end
  def [](k)
    @h[k]
  end
end
def fv(i) = "v#{i}x"
o = UserW.new
200.times { |i| o.a, o.b = "u#{i}", fv(i) }
puts o.a, o.b
ui = UserIx.new
200.times { |i| ui[1], ui[2] = "u#{i}", fv(i) }
puts ui[1], ui[2]
objs = [UserW.new, PlainW.new]
200.times do |i|
  q = objs[i % 2]
  q.a, q.b = "u#{i}", fv(i)
end
puts objs[0].a, objs[0].b, objs[1].a, objs[1].b
