# Flag-only: without the flag (as on master) the converted Strings are copies.
# String#to_s and #to_str answer the String itself, so a map or a
# transform_values whose block converts a String the rule shares collects
# that String, and a member read through to_s answers the member.
e0 = +"e0"; e1 = +"e1"
rr = [e0, e1]
t = rr.map(&:to_s)[0]
t << "!"
u = rr.map { |v| v.to_str }[1]
u << "?"
p [e0, e1, t.equal?(e0), u.equal?(e1)]

f0 = +"f0"
h = {+"a" => f0, +"b" => +"f1"}
w = h.values.map(&:to_s)[0]
f0 << "~"
x = h.transform_values { |v| v.to_s }.values[0]
x << "#"
p [f0, w, x.equal?(f0)]

S = Struct.new(:a, :b)
g0 = +"g0"
s = S.new(g0, +"g1")
y = s.a.to_s
y << "!"
z = [s[:a].to_s]
z[0] << "?"
p [g0, y.equal?(g0), z[0].equal?(g0)]

# a String of its own still answers itself, a copy of nothing
n = +"n"
m = [n].map(&:to_s)
p m[0].equal?(n)
