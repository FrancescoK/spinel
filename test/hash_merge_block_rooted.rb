# A merge or update with a block keeps its receiver and argument rooted
# while the block allocates (a fresh argument Hash was collected)
def mk(i)
  h = {}
  50.times { |j| h["k#{j}"] = "v#{i}-#{j}" }
  h
end
g = {"k1" => "a", "k2" => "b"}
g[3] = 4
20.times do |i|
  g = g.merge(mk(i)) { |*all| all.join("/") }
end
p g.size, g["k1"].size
s = {"k1" => "z"}
2.times { |i| s.update(mk(i)) { |k, o, *r| o + r.join } }
p s.size, s["k1"]
g3 = {"k1" => "a", "k2" => "b"}
g3[3] = 4
20.times do |i|
  g3 = g3.merge(mk(i)) { |k, o, n| [k, o, n].join("/") }
end
p g3.size, g3["k1"].size
