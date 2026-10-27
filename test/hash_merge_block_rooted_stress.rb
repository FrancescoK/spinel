# spinel: gc-stress
# A merge! or update with a block keeps a fresh receiver or argument
# rooted while the block allocates. gc-stress-test runs this under
# SPINEL_GC_STRESS.
def mk(i)
  h = {}
  60.times { |j| h["k#{j}"] = "v#{i}-#{j}" }
  h
end
t = 0
40.times do |i|
  sp = {"k1" => 1, "x" => "y"}
  sp.merge!(mk(i)) { |k, o, n| [k, o, n].join("-") * 3 }
  t += sp["k1"].size + sp.size
end
p t
u = 0
loc = mk(7)
6.times do |i|
  a = mk(i).update(loc) { |k, o, n| [k, o, n].join(",") }
  u += a["k3"].size + a.size
end
p u
