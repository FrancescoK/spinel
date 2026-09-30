# The block of `Array#delete`, `Hash#fetch` and `Hash#delete` that runs when the value or
# the key is missing is given it, whatever the block builds from it: an Array or Hash
# literal, a String, a call. The setup of a literal used to run ahead of the call, so
# `{ |k| [k] }` held nil, and `Array#delete` set the parameter only for a value that
# could not be in the array.
log = []
a = [1, 2, 3]
p a.delete(2) { |v| log << v; [v] }
p a.delete(7) { |v| log << v; log << :b; [v, log.size] }
p log
f = [1.5, 2.5]
p f.delete(9.0) { |v| [v] }
p f.delete(1.5) { |v| [v] }
s = ["a", "b"]
p s.delete("q") { |v| [v, v.upcase] }
p s.delete("a") { |v| [v] }
pa = [1, "x", :s]
p pa.delete(:zz) { |v| [v] }
p pa.delete(1) { |v| [v] }
h = { a: 1, b: nil }
p h.delete(:b) { |k| [k] }
p h.delete(:zz) { |k| [k, 1] }
p h.fetch(:a) { |k| [k] }
mh = { 1 => "a", "b" => 2 }
p mh.fetch(3) { |k| [k, k] }
p mh.fetch("zz") { |k| { k => 1 } }
p mh.delete(4) { |k| [k] }
p h.fetch(:zz) { |k| puts "missing #{k}"; [k] }
p h.delete(:qq) { |k| puts "gone #{k}"; [k] }
p a.delete(8) { |v| puts "no #{v}"; v.to_s * 2 }
p a.delete(42) { 0 }
i = 5
p a.delete(i) { |v| [v, i] }
w = [[1, 2], [3]]
p w.delete([9]) { |v| [v] }
p({ x: 1 }.fetch(:y) { |k| [[k]] })
ss = { "s" => 1 }
p ss.fetch("t") { |k| "#{k}!" }

# a value that runs code, given to a block that never reads the parameter
def seven = 7
ca = [1, 2, 3]
p ca.delete(seven) { |v| :miss }
p ca.delete(seven) { :miss }
cs = ["a", "b"]
def seven_s = "q"
p cs.delete(seven_s) { |v| :gone }

# a value that runs code, given to a block that reads the parameter: it runs once
def two = 2
def flt = 2.5
ia = [1, 2, 3]
fa = [1.5, 2.5]
wa = %w[a b c]
calls = 0
count = -> { calls += 1; 77 }
p ia.delete(two + 10) { |x| x + 1 }
p ia.delete(count.call) { |x| x + 1 }
p fa.delete(flt + 10) { |x| x * 2 }
p wa.delete("Q".downcase) { |x| "none #{x}" }
p ia.delete(two) { |x| x * 2 }
p fa.delete(flt) { |x| x * 2 }
p wa.delete("b".upcase.downcase) { |x| x * 2 }
p calls

# a whole Float from a call equals the Integer element; a block may change its parameter
def twof = 2.0
ja = [1, 2, 3]
p ja.delete(twof) { |v| v }
p ja
p ja.delete(twof) { |v| v }
p [1, 2, 3].delete(2) { |v| v << 1 }
names = %w[ann bob]
p names.delete("bob") { |n| n << "?" }
p names
p [[1], [2]].delete([2]) { |v| v.push(9) }

# a value of another kind than the array holds, and nil
p ["a"].delete(1) { |v| [v] }
p [1, 2].delete(nil) { |v| [v] }
p [1, 2].delete("z") { |v| [v, v] }

# a whole Float from a call, given to an Integer Array and read by the block: the whole range of Integers
def edge = 9.2e18
big = [9_200_000_000_000_000_000, 3]
p big.delete(edge) { |v| [:m, v] }
p big

# a valued `next` in the block of a missing `fetch` answers for the key
kn = { a: 1 }
p kn.fetch(:zz) { |k| next [k] }
p kn.fetch(:zz) { |k| x = k.to_s; next [x, 1] if k == :zz; :after }
p kn.fetch(:a) { |k| next [k] }
