# A rest parameter of a merge or merge! block takes the values the
# positional ones leave
g = {a: 1}
g["s"] = 2
p g.merge({a: 9}) { |*all| all }
p g.merge({a: 9}) { |k, *r| r }
p g.merge({"s" => 3}, {a: 4}) { |k, o, n| [k, o, n] }
a = {x: 1, y: 2}
a.merge!({x: 5}) { |*r| r.sum { |v| v.is_a?(Integer) ? v : 0 } }
p a
b = {"s" => 1.5}
b.update({"s" => 2.5}) { |k, *r| r.max }
p b
c = {1 => "a"}
c.merge!({1 => "b"}) { |k, o, *r| o + r.inspect }
p c
d = {a: nil}
d[:b] = 3
d.merge!({a: 4, b: 5}) { |*r| r.inspect.size }
p d
e = {a: 1}
e.merge!({a: "s"}) { |*r| r }
p e
h = {1 => 2, "x" => nil, [] => []}
m1 = []; m2 = []
h.merge(h) { |*arg| m1 << arg }
h.merge!(h) { |*arg| m2 << arg }
p m1 == m2, m2
