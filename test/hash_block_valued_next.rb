# A `next <value>` in a Hash block answers for that key or pair, as the
# block's tail would.

p({a: 1}.merge({a: 2}) { |k, o, n| next o + n if o; 0 })
p({a: 1}.merge({a: 2}) { |k, o, n| next o * 10 if n > 1; o + n })
p({"x" => 1}.merge({"x" => 4}) { |k, o, n| next o + n if o; 0 })
p({1 => "a", :b => 2}.merge({1 => "z"}) { |k, o, n| next o + n if o; 0 })

g = {a: 1}
g.merge!({a: 2}) { |k, o, n| next o + n if o; 0 }
p g
g.update({a: 5}) { |k, o, n| next o - n if o; 0 }
p g
acc = [{a: 1}, {a: 2}, {a: 3}].reduce({}) { |m, e| m.merge(e) { |k, o, n| next o + n if o; 0 } }
p acc

p({a: 1, b: 2}.transform_values { |x| next x * 10 if x > 1; x })
p({a: "x", b: "y"}.transform_values { |x| next x * 2 if x == "y"; x })
p({a: 1, b: 2}.transform_keys { |k| next :z if k == :b; k })
t = {a: 1, b: 2}
t.transform_values! { |x| next x * 10 if x > 1; x }
p t

h = {a: 1, b: 2, c: 3}
p h.chunk_while { |x, y| next true if y[1] > 1; false }.to_a
p h.slice_when { |x, y| next false if y[1] > 1; true }.to_a
p h.chunk { |k, v| next :big if v > 1; :small }.to_a
