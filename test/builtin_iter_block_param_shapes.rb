# A block given to a builtin iterator binds its optionals, posts and rest
# by CRuby's rules, not only its leading requireds.

[1, 2].each { |c, a = 10| p [a, c] }
[1, 2].each { |a = 10| p a }
[1, 2].each { |*r, c| p [r, c] }
p([1, 2].map { |c, a = 10| a + c })
p([1, 2].map { |a = 10| a })
p([1, 2].select { |c, a = 10| a > c })
p((1..3).map { |i, j = 2| i * j })
[5, 6].each_with_index { |c, i, a = 10| p [c, i, a] }
p([1, 2].each_with_object([]) { |c, acc, z = 3| acc << c + z })
p([1, 2].inject { |s, x, y = 3| s + x + y })
3.times { |i, a = 10| p [i, a] }
1.upto(2) { |i, a = 10| p [i, a] }
"ab".each_char { |ch, z = "!"| puts ch + z }

# a Hash yields its pair, spread across more than one slot
{x: 1}.each { |k, v, a = 10| p [k, v, a] }
{x: 1}.each { |*r, v| p [r, v] }
{x: 1}.each { |a = 10| p a }
{x: 1}.each { |*r| p r }
p({x: 1}.map { |k, v, a = 10| [k, v, a] })
# ...but its own filters yield the key and the value
{x: 1}.select { |a = 10| p a }
{x: 1}.select { |*r| p r }
{x: 1}.reject { |k, *r| p [k, r] }

# a yielded Array is spread, unless the block has a single optional
[[1, 2]].each { |a, b = 5| p [a, b] }
[[1, 2]].each { |a = 10| p a }
[[1, 2]].each { |*r, c| p [r, c] }
[[1, 2]].each { |a, *r| p [a, r] }
[[1, 2, 3]].each { |a, *r, c| p [a, r, c] }
[[1], [1, 2, 3, 4]].each { |a, b = 5, *r, c| p [a, b, r, c] }
[[1, 2], 3].each { |a, b = 5| p [a, b] }
[[1, "x"], [2]].each { |n, s = "d"| p [n, s] }
p([[1, 2], [3, 4]].sum { |a, b = 0| a * b })
[1, 2, 3].each_slice(2) { |a, b = 10| p [a, b] }
[1, 2, 3].each_slice(2) { |*r| p r }

# the defaults see earlier parameters and outer locals; the parameters
# still shadow outer locals
x = 7
[1].each { |a, b = x, c = (a + b)| p [a, b, c] }
a = 1
[2].each { |c, a = 3| p [c, a] }
p a
fs = []
[1, 2].each { |c, a = 10| fs << -> { c + a } }
p fs.map(&:call)
p([1, 2, 3].map { |c, a = 10| next 0 if c == 2; c + a })
p([1, 2, 3].each { |c, a = 10| break c * a if c == 2 })
p([1, 2].map { |c, a = 1| })
