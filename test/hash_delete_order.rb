# Hash#delete keeps the insertion order of the other entries, for each kind
# of Hash: String keys with Integer, String or mixed values, Symbol keys,
# Integer keys with Integer or String values, and mixed keys. Each one is
# grown past a few dozen entries, loses its first, last and a middle entry,
# misses a key it does not hold, deletes through an equal String that is
# another object, and is churned; a small one deletes its middle entry.

si = {}
40.times { |i| si["k#{i}"] = i }
si.delete("k0"); si.delete("k39"); si.delete("k20"); p si.delete("nope")
p si.delete("k1".dup)
si["k0"] = 100
p si.keys.first(4), si.keys.last(3), si.size
small = { "a" => 1, "b" => 2, "c" => 3 }
small.delete("b"); small["b"] = 4
p small

ss = {}
40.times { |i| ss["k#{i}"] = "v#{i}" }
ss.delete("k0"); ss.delete("k39"); ss.delete("k20")
p ss.delete("k2".dup), ss.keys.first(3), ss.keys.last(2), ss.size

sp = {}
40.times { |i| sp["k#{i}"] = i.even? ? i : "s#{i}" }
sp.delete("k0"); sp.delete("k39"); sp.delete("k21")
p sp.delete("k3".dup), sp.keys.first(3), sp.keys.last(2), sp.size

sy = {}
40.times { |i| sy[:"s#{i}"] = i.even? ? i : "v#{i}" }
sy.delete(:s0); sy.delete(:s39); sy.delete(:s20)
p sy.delete(:missing), sy.keys.first(3), sy.keys.last(2), sy.size

ii = {}
40.times { |i| ii[i * 16] = i }
ii.delete(0); ii.delete(39 * 16); ii.delete(20 * 16); p ii.delete(7)
ii[0] = -1
p ii.keys.first(3), ii.keys.last(2), ii.size

is = {}
40.times { |i| is[i * 16] = "v#{i}" }
is.delete(0); is.delete(39 * 16); is.delete(20 * 16)
p is.keys.first(3), is.keys.last(2), is.size

pp = {}
40.times { |i| pp[i.even? ? i * 16 : "k#{i}"] = i }
pp.delete(0); pp.delete("k39"); pp.delete(20 * 16)
p pp.delete("k1".dup), pp.keys.first(3), pp.keys.last(2), pp.size

# churn: delete and put back keys in a scrambled order, then compare the
# order with what was kept alongside it
seed = 7
cs = {}
ci = {}
cp = {}
kept = []
300.times do |i|
  seed = (seed * 75 + 74) % 65_537
  n = seed % 60
  k = "c#{n}"
  if cs.key?(k)
    cs.delete(k); ci.delete(n); cp.delete(n.even? ? n : k)
    kept.delete(n)
  else
    cs[k] = i; ci[n] = i; cp[n.even? ? n : k] = i
    kept << n
  end
end
p cs.keys == kept.map { |n| "c#{n}" }, ci.keys == kept, cp.keys == kept.map { |n| n.even? ? n : "c#{n}" }
p cs.size, kept.first(5)
