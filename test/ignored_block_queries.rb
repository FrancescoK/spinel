# A block given to an Array or Hash method that takes none is ignored, as
# CRuby ignores it: the call answers what it answers without one. Array#size
# and #length, #at and #slice, and Hash#store raised NoMethodError, and
# Hash#to_a and #entries answered nil. Each block here would raise if it ran.

ints = [3, 1, 2]
floats = [1.5, 2.5]
strs = ["a", "b"]
mixed = [1, "x", :s]

p ints.size { raise "ran" }, ints.length { |x| raise "ran" }
p floats.size { raise "ran" }, strs.length { raise "ran" }, mixed.size { raise "ran" }
p ints.at(0) { raise "ran" }, floats.at(-1) { raise "ran" }, strs.at(1) { raise "ran" }, mixed.at(1) { raise "ran" }
p ints.slice(1) { raise "ran" }, floats.slice(0) { raise "ran" }, strs.slice(0) { raise "ran" }, mixed.slice(2) { raise "ran" }
p ints.slice(0..1) { raise "ran" }, mixed.slice(1..) { raise "ran" }
n = ints.size { raise "ran" } + mixed.length { raise "ran" }
p n

h = {"a" => 1, "b" => 2}
sym = {a: 1, "b" => 2.0}
num = {1 => 2}
p h.to_a { raise "ran" }, sym.entries { raise "ran" }, num.to_a { |k, v| raise "ran" }
p h.first { raise "ran" }, sym.first(1) { raise "ran" }, h.take(1) { raise "ran" }, sym.drop(1) { raise "ran" }
p h.store("c", 3) { raise "ran" }, sym.store(:d, 4) { raise "ran" }
p h, sym
p num.shift { raise "ran" }, num
p h.default_proc { raise "ran" }
d = Hash.new { |hash, k| k * 2 }
p d.default_proc { raise "ran" }.call({}, 21)
