# Element routes that broke the C build only under --share-strings: a call
# answering an Array of elements (pop(2), shift(2), min(2), max(2), flatten,
# a Hash's slice and flatten) whose walk reached a String as if it held
# elements, a Hash block's key parameter, a symbol-proc's parameter over a
# Hash's keys, and the key of an update block. Each answers as CRuby.
def guarded
  yield
rescue FrozenError => e
  e.class
end

e0 = +"e0"; e1 = +"e1"; e2 = +"e2"
r = [e0, e1, e2]
t = r.pop(2)[0]
e1 << "~"
p [e1, t, t.equal?(e1)]

e0 = +"e0"; e1 = +"e1"; e2 = +"e2"
r = [e0, e1, e2]
t = r.shift(2)[0]
e0 << "~"
p [e0, t, t.equal?(e0)]

e0 = +"e0"; e1 = +"e1"; e2 = +"e2"
r = [e0, e1, e2]
t = r.min(2)[0]
e0 << "~"
p [e0, t]
t = r.max(2)[0]
e2 << "~"
p [e2, t]

e0 = +"e0"; e1 = +"e1"
r = [e0, e1]
t = r.flatten[0]
u = r.flatten(1)[1]
e0 << "~"
e1 << "~"
p [t, u, t.equal?(e0)]

k0 = +"a"; k1 = +"b"; v0 = +"v0"; v1 = +"v1"
h = {k0 => v0, k1 => v1}
t = h.slice(k0).values[0]
u = h.flatten[1]
w = h.flatten(2)[3]
v0 << "~"
v1 << "!"
p [t, u, w, t.equal?(v0)]

h = {+"a" => +"e"}
pairs = h.map { |k, v| [k, v] }
p guarded { pairs[0][0] << "!" }
inv = h.to_h { |k, v| [v, k] }
p guarded { inv.values[0] << "!" }
ks = h.keys.sort_by(&:to_s)
p guarded { ks[0] << "!" }

k0 = +"a"; k1 = +"b"; v0 = +"v0"; v1 = +"v1"; n = +"n"
h = {k0 => v0, k1 => v1}
res = h.update({k0 => n}) { |_k, _old, new| new }
t = res.values[1]
v1 << "~"
p [t, t.equal?(v1), res[k0].equal?(n)]

# two blocks of one scope bind one key parameter; a tuple joins it to the
# values, which are compared or frozen through the answer
x0 = +"x0"; x1 = +"x1"
h = {+"a" => x0, +"b" => x1}
w = h.map { |k, v| [k, v] }[1][1]
p [w.equal?(x1), w == x1]
y0 = +"y0"; y1 = +"y1"
h2 = {+"a" => y0, +"b" => y1}
w2 = h2.map { |k, v| [k, v] }[1][1]
w2.freeze
p [y1.frozen?, w2.frozen?]
