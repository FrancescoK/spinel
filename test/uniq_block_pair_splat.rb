# A two-param uniq block over a Hash or an Array of pairs splats each pair
# across its params.
p({a: 1, b: 2}.uniq { |k, v| v > 1 ? 0 : v })
h = {a: 1, b: 2, c: 1}
p h.uniq { |k, v| v }
p h.uniq { |kv| kv[1] }
p h.uniq { |(k, v)| v }
s = {"x" => 1.5, "y" => 2.5, "z" => 3.5}
p s.uniq { |k, v| v > 2 }
a = [[1, 2], [1, 3], [2, 2]]
p a.uniq { |x, y| x }
p a.uniq { |x, y| y }
b = [[:a, 1], [:b, 1], [:c, 2]]
p b.uniq { |k, v| v }
b.uniq! { |k, v| v }
p b
p({1 => 2, 3 => 2}.uniq { |k, v| k })
