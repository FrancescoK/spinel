# dig with a splat beside other keys on a Hash or an Array read out of a
# container walks every key in order, the splat's elements in its place, as
# CRuby does; a receiver with no dig raises NoMethodError.
h = [{ a: { b: { c: 1, d: [5, 6], n: 7 } } }, 0][0]
ks = [:a, :b]
p h.dig(*ks, :c)
kb = [:b]
p h.dig(:a, *kb, :d, 1)
p h.dig(*ks, :d, *[0])
p h.dig(*[:a], *kb, :c)
p h.dig(*ks, :zz)
p h.dig(*ks, :zz, :q)
a = [[[10, [20, 30]]], 0][0]
ix = [0]
p a.dig(*ix, 1, 0)
p ks
def path = [:a, :b]
p h.dig(*path, :d)
p (h.dig(*ks, :n, 0) rescue [$!.class, $!.message])
p ([nil, 0][0].dig(*ks, :c) rescue [$!.class, $!.message])
p (["str", 0][0].dig(*ks, :c) rescue [$!.class, $!.message])
