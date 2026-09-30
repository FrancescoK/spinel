# A boxed Hash answers its default for a key of a kind its storage cannot
# hold (a String or an Integer on a Symbol-keyed Hash, a Symbol or an Integer
# on a String-keyed one, a Float, nil or an Array on any of them): the key is
# a miss, not nil.
def box(h) = [h, 1][0]

# keys read out of a Hash
sp = Hash.new(7); sp[:a] = 1; sp[:b] = "x"
sq = Hash.new(7); sq["a"] = 1; sq["b"] = "x"
si = Hash.new(7); si["a"] = 1
ss = Hash.new("d"); ss["a"] = "v"
ii = Hash.new(7); ii[1] = 1
is = Hash.new("d"); is[1] = "v"
pp = Hash.new(7); pp[1] = 1; pp["a"] = "x"
k = {sym: :a, str: "zz", int: 5, flt: 1.5, nil: nil, ary: [1]}
hs = {sp: sp, sq: sq, si: si, ss: ss, ii: ii, is: is, pp: pp}
hs.each do |hn, h|
  b = box(h)
  out = k.map do |kn, key|
    v = b[key] rescue "ERR"
    "#{kn}=#{v.inspect}"
  end
  puts "#{hn}: #{out.join(' ')}"
end

# keys written in the source
sp = Hash.new(7); sp[:a] = 1; sp[:b] = "x"
sq = Hash.new(7); sq["a"] = 1; sq["b"] = "x"
si = Hash.new(7); si["a"] = 1
ss = Hash.new("d"); ss["a"] = "v"
ii = Hash.new(7); ii[1] = 1
is = Hash.new("d"); is[1] = "v"
[["sp", sp], ["sq", sq], ["si", si], ["ss", ss], ["ii", ii], ["is", is]].each do |n, h|
  b = box(h)
  puts "#{n}: #{b[:zz].inspect} #{b["zz"].inspect} #{b[9].inspect} #{b[-1].inspect} #{b[1.5].inspect} #{b[nil].inspect} #{b[[1]].inspect} #{b[1..2].inspect} #{b[true].inspect}"
end
# default blocks that ignore their key
dp = Hash.new { |h, k| "blk" }
dp[:a] = 1; dp[:b] = "x"
dq = Hash.new { |h, k| "blk" }
dq["a"] = 1; dq["b"] = "x"
[["dp", dp], ["dq", dq]].each do |n, h|
  b = box(h)
  puts "#{n}: #{b[:zz].inspect} #{b["zz"].inspect} #{b[9].inspect} #{b[1.5].inspect} #{b[nil].inspect}"
end
# default_proc= keeps a Symbol- or String-keyed table: a block that ignores its key
dr = {a: 1, b: "x"}
dr.default_proc = ->(h, k) { "blk" }
ds = {"a" => 1, "b" => "x"}
ds.default_proc = ->(h, k) { "blk" }
[["dr", dr], ["ds", ds]].each do |n, h|
  b = box(h)
  puts "#{n}: #{b[:zz].inspect} #{b["zz"].inspect} #{b[9].inspect} #{b[1.5].inspect} #{b[nil].inspect} #{b[[1]].inspect}"
end
# a String key missed on a Symbol-keyed Hash is not interned
b = box(dr)
9000.times { |i| b["dyn#{i}"] }
p "fresh_after".to_sym
h = {}; h["q".to_sym] = 1; h["r".to_sym] = 2
p h
# key 0 present: a Float, nil or Array key is still a miss
z = Hash.new(7); z[0] = 5
zs = Hash.new("d"); zs[0] = "z"
[["z", z], ["zs", zs]].each do |n, h|
  b = box(h)
  puts "#{n}: #{b[1.5].inspect} #{b[nil].inspect} #{b[[1]].inspect} #{b[:s].inspect} #{b["s"].inspect} #{b[0].inspect}"
end
# no default
np = {a: 1, b: "x"}
nq = {"a" => 1, "b" => "x"}
ni = {"a" => 1}
ni2 = {1 => 1}
[["np", np], ["nq", nq], ["ni", ni], ["ni2", ni2]].each do |n, h|
  b = box(h)
  puts "#{n}: #{b[:zz].inspect} #{b["zz"].inspect} #{b[9].inspect} #{b[1.5].inspect} #{b[nil].inspect}"
end
# present keys still read
b = box(sp); puts "#{b[:a].inspect} #{box(sq)["a"].inspect} #{box(ii)[1].inspect} #{box(is)[1].inspect}"
# fetch, dig, key?
b = box(sp)
puts "#{b.fetch(:zz, :f).inspect} #{b.key?("a").inspect} #{b.dig(:a).inspect} #{(b.dig("q")).inspect}"
puts box(sp).values_at(:a, :zz, "s", 3).inspect
