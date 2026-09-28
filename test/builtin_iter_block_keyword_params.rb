# A block given to a builtin iterator binds its keyword parameters to their
# defaults, `**kw` to {} and `&b` to nil: the builtin yields no keywords and
# no block. They do not count toward spreading a yielded Array.

[[1, 2]].each { |a, b = 5, **kw| p [a, b, kw] }
[1, 2].each { |a, k: 1| p [a, k] }
p([1, 2].map { |a, k: 1| a + k })
p([1, 2, 3].select { |a, k: 2| a >= k })
[5, 6].each_with_index { |a, i, k: 3| p [a, i, k] }
{x: 1}.each { |key, v, k: 4| p [key, v, k] }
{x: 1}.each { |pr, k: 1| p [pr, k] }
p({x: 1}.map { |key, v, **kw| [key, v, kw] })
p([1, 2].each_with_object([]) { |a, acc, s: "z"| acc << "#{a}#{s}" })
p((1..3).map { |i, step: 10| i * step })
3.times { |i, k: 9| p [i, k] }
"ab".each_char { |ch, up: (ch.upcase)| print up }
puts
p([1.5].map { |f, g: (f * 2)| g })
[1].each { |k: 3| p k }

# keywords do not spread a yielded Array
[[1, 2]].each { |a, k: 1| p [a, k] }
[[1, 2]].each { |a, **kw| p [a, kw] }
[[1, 2]].each { |a, &b| p [a, b] }
[[1, 2]].each { |a, b, k: 7| p [a, b, k] }
[[1, 2]].each { |(a, b), k: 2| p [a, b, k] }
[[1, 2]].each { |a, b, k: (a + b)| p k }
[[1, 2]].each { |a, b, c = 9, k: 1, **kw| p [a, b, c, k, kw] }
[[1, 2]].each { |a, b = 5, &blk| p [a, b, blk] }

p([1, 2].select { |a, &b| b.nil? && a > 1 })
[1, 2].each_with_index { |a, i, &b| p [a, i, b] }

# a required keyword is missing
begin
  [1].each { |a, k:| p a }
rescue ArgumentError => e
  p e.message
end
begin
  [[1, 2]].each { |a, b, j:, k:| p a }
rescue ArgumentError => e
  p e.message
end

# a parameter does not share the slot of an outer local or another block's
k = "outer"
[1].each { |a, k: 1| p k }
[1].each { |a, k: "s"| p k }
p k
kw = "x"
[1].each { |a, **kw| p kw }
p kw
blk = 7
[1].each { |a, &blk| p blk }
p blk
def y; yield 1; end
y { |a, &b| p b }
b = 3
p b

# a nested block, lambda or def binding the same name keeps its own
[1].each { |a, q: 1| [2].each { |b, q: 2| p q }; p q }
[1].each { |a, q: 1| [2].each { |b, q: 2| p q; q += 10; p q }; p q }
[1].each { |a, q: 1| [2].each { |q| p q }; p q }
[1].each { |a, q: 1| [2].each { |b, q = 5| p q }; p q }
[1].each { |a, q: 1| [2].each { |b, *q| p q }; p q }
[1].each { |a, q: 1| [2].each { |b, **q| p q }; p q }
[1].each { |a, q: 1| [2].each { |b, &q| p q }; p q }
[1].each { |a, q: 1| [2].each { |b; q| q = 9; p q }; p q }
[1].each { |a, q: 1| f = ->(q: 3) { q }; p f.call; p f.call(q: 4); p q }
[1].each { |a, q: 1| def m(q: 5) = q; p m; p q }
[1].each { |a, q: 1| y { |b, q: 6| p q }; p q }
[1].each { |a, q: 1| [2].each { |b| p q; q = 7 }; p q }
