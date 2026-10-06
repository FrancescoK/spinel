# Range#step with a negative step walks DOWN from the begin, as CRuby 4.0
# does: (5..1).step(-1) yields 5, 4, 3, 2, 1, (1..5).step(-1) nothing, and
# an endless range -- (1..).step(-1), (1.5..).step(-1) -- yields forever,
# here until a break. The block forms enumerated nothing for a negative
# Integer step, and an endless Float range returned at once.

a1 = []; (1.5..).step(-1) { |v| a1 << v; break if a1.size >= 4 }; p a1
a2 = []; (1..).step(-1) { |v| a2 << v; break if a2.size >= 4 }; p a2
a3 = []; (3.0..1.0).step(-0.5) { |v| a3 << v }; p a3
a4 = []; (3.0...1.0).step(-0.5) { |v| a4 << v }; p a4
a5 = []; (1.0..3.0).step(-0.5) { |v| a5 << v }; p a5
a6 = []; (5..1).step(-1) { |v| a6 << v }; p a6
a7 = []; (5...1).step(-2) { |v| a7 << v }; p a7
a8 = []; (1..5).step(-1) { |v| a8 << v }; p a8
a9 = []; (1..5).step(2) { |v| a9 << v }; p a9
a10 = []; (1.0..2.0).step(0.5) { |v| a10 << v }; p a10
r = (6..2)
a11 = []; r.step(-2) { |v| a11 << v }; p a11
p (5..1).step(-1).to_a
p (5...1).step(-2).to_a
p (1..5).step(-1).to_a
p (3.0..1.0).step(-0.5).to_a
p((5..1).step(-1).map { |v| v * 2 })
b1 = []; (9..1).step(-3) { |v| b1 << v; break if v < 5 }; p b1
p((10..1).step(-4) { |v| })
