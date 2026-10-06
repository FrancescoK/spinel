# Hash#delete with a block answers the deleted value, or the block's value
# for a missing key: either kind, so the call is boxed. On a String- or
# Integer-keyed Hash of Integer or String values it was typed as the value,
# and the generated C did not build.
h = { "a" => 1, "b" => 2 }
p h.delete("a") { |k| "no #{k}" }
p h.delete("z") { |k| "no #{k}" }
p h
p h.delete("z") { |k| k.size }, h.delete("b") { 9 } + 1
x = { "q" => 1 }.delete("z") { 5 }
p x + 1
s = { "a" => "b" }
p s.delete("z") { 0 }, s.delete("a") { 0 }, s
i = { 1 => 2 }
p i.delete(5) { "x" }, i.delete(1) { "x" }
n = { 1 => "a" }
p n.delete(2) { |k| k * 2 }, n.delete(1) { |k| k * 2 }
y = { a: 1 }
p y.delete(:b) { |k| k }, y.delete(:a) { |k| k }
f = { "a" => 1.5 }
p f.delete("z") { nil }, f.delete("a") { nil }
p({ "a" => 1 }.delete("a"), { "a" => 1 }.delete("z"))
