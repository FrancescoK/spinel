# `h.default = nil` on a Hash with Integer values leaves the default nil,
# not 0.
h = Hash.new(4)
h["a"] = 1
h.default = nil
p h["zz"], h.default, h.fetch("zz", :d)
q = {"a" => 1}
q.default = 9
q.default = nil
p q["zz"], q.default
r = {1 => 10}
r.default = 5
r.default = nil
p r[2], r.default, r[1]
s = Hash.new(0)
s["x"] += 1
s.default = nil
p s["y"], s["x"], s.key?("y")
p(s.default = nil)

# a nil default on a Hash that never had another
w = {"a" => 1}
w.default = nil
p w["zz"], w.default
z = {1 => 1}
z.default = nil
p z[2], z.default

# String values, and a default that is not nil, as before
t = {"a" => "s"}
t.default = "d"
p t["zz"]
t.default = nil
p t["zz"], t.default
u = {1 => "s"}
u.default = "d"
u.default = nil
p u[3], u.default
k = {"a" => 1}
k.default = 7
p k["zz"], k.default
v = Hash.new(nil)
v["a"] = 2
p v["zz"], v.default
