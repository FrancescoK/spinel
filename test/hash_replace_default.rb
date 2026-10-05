# Hash#replace takes the other Hash's default value and default proc along
# with its entries, as CRuby's does: `Hash.new(1).replace(b: 2).default` is
# nil. A typed receiver given a Hash of its own variant kept its own default,
# and a general (PolyPoly) receiver given another variant did too; the boxed
# receiver already took the other's (boxed_hash_replace_default).

# the same variant: the other's default value replaces the receiver's
a = Hash.new(5); a[:k] = 1; a.replace({x: 1}); p [a, a.default, a[:zz]]
f = {1 => 2}; g = Hash.new(0); g[3] = 4; f.replace(g); p [f, f[9]]
s = {"a" => "b"}; t = Hash.new("dflt"); t["c"] = "d"; s.replace(t); p [s, s["zz"]]
# ... and its default proc
d = Hash.new { |h, k| k.to_s * 2 }; d[:z] = "q"
e = {w: "v"}; e.replace(d); p [e, e[:ab]]
r = {"s" => [1]}; r2 = Hash.new { |h, k| [k] }; r2["t"] = [2]; r.replace(r2); p [r, r["u"]]
# a general receiver given another variant
m = {1 => "x", "y" => :z}; n = Hash.new(:dd); n[2] = 3; m.replace(n); p [m, m[:none]]
m2 = {1 => "x", "y" => :z}; q = {k: 1}; m2.replace(q); p [m2, m2[:none]]
# the result is the receiver
h1 = Hash.new(7); h1["a"] = 1; h2 = {"b" => 2}
p h1.replace(h2).equal?(h1), h1.default

# Lowered bang transforms keep the receiver's default value and proc.
v = Hash.new(7); v[:a] = 1; v[:b] = 2
v.transform_values! { |value| value * 10 }
p [v, v.default, v[:zz]]
dp = Hash.new { |hash, key| key.to_s * 2 }; dp[:a] = 1; dp[:b] = 2
dp.transform_values! { |value| value * 10 }
p [dp, dp[:zz]]

v = Hash.new(7); v[:a] = 1; v[:b] = 2
v.transform_keys! { |key| key == :a ? :c : key }
p [v, v.default, v[:zz]]
dp = Hash.new { |hash, key| key.to_s * 2 }; dp[:a] = 1; dp[:b] = 2
dp.transform_keys! { |key| key == :a ? :c : key }
p [dp, dp[:zz]]

# The other in-place Hash methods keep both kinds of default too.
v = Hash.new(7); v[:a] = 1; v[:b] = 2
v.select! { |key, value| value == 1 }
p [v, v.default, v[:zz]]
dp = Hash.new { |hash, key| key.to_s * 2 }; dp[:a] = 1; dp[:b] = 2
dp.select! { |key, value| value == 1 }
p [dp, dp[:zz]]

v = Hash.new(7); v[:a] = 1; v[:b] = 2
v.reject! { |key, value| value == 1 }
p [v, v.default, v[:zz]]
dp = Hash.new { |hash, key| key.to_s * 2 }; dp[:a] = 1; dp[:b] = 2
dp.reject! { |key, value| value == 1 }
p [dp, dp[:zz]]

v = Hash.new(7); v[:a] = 1; v[:b] = 2
v.filter! { |key, value| value == 1 }
p [v, v.default, v[:zz]]
dp = Hash.new { |hash, key| key.to_s * 2 }; dp[:a] = 1; dp[:b] = 2
dp.filter! { |key, value| value == 1 }
p [dp, dp[:zz]]

v = Hash.new(7); v[:a] = 1; v[:b] = 2
v.keep_if { |key, value| value == 1 }
p [v, v.default, v[:zz]]
dp = Hash.new { |hash, key| key.to_s * 2 }; dp[:a] = 1; dp[:b] = 2
dp.keep_if { |key, value| value == 1 }
p [dp, dp[:zz]]

v = Hash.new(7); v[:a] = 1; v[:b] = 2
v.delete_if { |key, value| value == 1 }
p [v, v.default, v[:zz]]
dp = Hash.new { |hash, key| key.to_s * 2 }; dp[:a] = 1; dp[:b] = 2
dp.delete_if { |key, value| value == 1 }
p [dp, dp[:zz]]

v = Hash.new(7); v[:a] = 1; v[:b] = nil
v.compact!
p [v, v.default, v[:zz]]
dp = Hash.new { |hash, key| key.to_s * 2 }; dp[:a] = 1; dp[:b] = nil
dp.compact!
p [dp, dp[:zz]]

v = Hash.new(7); v[:a] = 1; v[:b] = 2
v.merge!({a: 10}, {c: 3})
p [v, v.default, v[:zz]]
dp = Hash.new { |hash, key| key.to_s * 2 }; dp[:a] = 1; dp[:b] = 2
dp.merge!({a: 10}, {c: 3})
p [dp, dp[:zz]]
