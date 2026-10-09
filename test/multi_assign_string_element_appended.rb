# A new String a multiple assignment stores in an Array element that is
# changed in place is that element, as a single assignment's is.
# spinel: gc-stress
r = [+"q"]
r[0], r[1] = +"ab", +"cd"
r[0] << "z"
p r

n = 1
u = []
u << +"q"
u[0], u[1] = "a#{n}", "b".dup
u.each { |e| e << "!" }
p u

# beside a value of another kind, and a variable's own String
c = +"ef"
w = [+"q"]
a, w[0], w[1] = 1, c, +"gh"
w[1] << "z"
w[0] << "y"
p a, w, c

# a String of adjacent literals: nothing else holds its handle while the
# next value is made
v = [+"q"]
v[0], v[1] = "a" "b", +"cd"
v[1] << "z"
p v, v[0].frozen?

# a Hash's values, under keys two locals name
i = ARGV.size
h = {"a" => +"q"}
k1 = "x#{i}"
k2 = "y#{i}"
h[k1], h[k2] = +"ab", +"cd"
h[k2] << "z"
h[k1] << "w"
p h.values

# a local that can be nil, where it is known not to be
g = ARGV.size == 1 ? nil : [+"q"]
if g
  g[0], g[1] = +"ab", +"cd"
  g[0] << "z"
end
p g

# the last new String's handle is held while the stores before its own
# run: a Hash's store copies a String key, and that can collect
m = {"a" => +"q"}
j = 0
bad = 0
while j < 2000
  ka = "x#{j}"
  kb = "y#{j}"
  m[ka], m[kb] = j, "v#{j}"
  m["tmp"] = "w#{j}"
  m["tmp"] << "!"
  bad += 1 if m[kb] != "v#{j}"
  m.delete(ka)
  m.delete(kb)
  j += 1
end
p bad, m.size
q1 = "x#{i}"
q2 = "y#{i}"
q3 = "z#{i}"
t = {"a" => +"q"}
t[q1], t[q2], t[q3] = 1, 2, +"cd"
t[q3] << "z"
p t.values
