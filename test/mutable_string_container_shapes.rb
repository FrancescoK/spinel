# A mutation through a container element reaches the string CRuby stores
# there, whatever shape the container reached the mutation in.

# a parameter stored into the container
def pair(v) = [1, v]
def pair_via(w) = pair(w)
def pair_mut(v)
  a = [1, v]
  a[1] << "q"
  a
end
x = pair(+"s"); x[1] << "q"; p x
x = pair_via(+"s"); x[1] << "q"; p x
p pair_mut(+"s")
s = +"t"
x = pair_mut(s)
p x, s, x[1].equal?(s)
def keyed(v:) = [1, v]
k = keyed(v: +"k"); k[1] << "q"; p k

# a block parameter as the container
y = [1, +"s"]; y.tap { |z| z[1] << "q" }; p y
y = [[1, +"s"]]; y.each { |z| z[1] << "q" }; p y
y = [[1, +"s"]]; y.map { |z| z[1] << "q" }; p y
y = [[1, +"s"]]; y.each_with_index { |z, i| z[1] << i.to_s }; p y
y = [[1, +"s"]]; y.each_with_object([]) { |z, acc| z[1] << "q" }; p y
h = {k: [1, +"s"]}; h.each { |key, v| v[1] << "q" }; p h
h = {k: [1, +"s"]}; h.each_value { |v| v[1] << "q" }; p h

# a nested container
r = [["a".dup, 1]]; r[0][0] << "!"; p r
r = [[+"a", 1]]; r.dig(0, 0) << "!"; p r
r = [[+"a", 1]]; r.first.first << "!"; p r
hn = {k: [+"a", 1]}; hn[:k][0] << "!"; p hn
names = [+"x", +"y"].map { |n| [n, n.size] }; names[0][0] << "!"; p names

# a result that shares the receiver's elements
a = [1, +"s"]; b = a + a; b[1] << "q"; p a, b
a = [1, +"s"]; b = a.dup; b[1] << "q"; p a, a[1].equal?(b[1])
a = [1, +"s"]; b = a[0, 2]; b[1] << "q"; p a
a = [1, +"s"]; b = a.first(2); b[1] << "q"; p a
a = [1, +"s"]; b = a.select { |e| e }; b[1] << "q"; p a
a = [1, +"s", nil]; b = a.compact; b[1] << "q"; p a
a = [[1, +"s"]]; b = a.flatten(1); b[1] << "q"; p a
hv = {a: 1, b: +"s"}; v = hv.values; v[1] << "q"; p hv
a = [1, +"s"]; b = a.to_a; b[1] << "q"; p a

# to_a / to_ary on a boxed typed array answer the array itself
c = [[3, 1], [2]]; c.each { |o| o.to_a.push(9) }; p c
c = [[3, 1], [2]]; c.each { |o| o.to_ary << 9 }; p c
c = [[3, 1], [2]]; c.each { |o| t = o.to_a; t.push(9); t.concat([8]) }; p c
c = [[3, 1], {a: 1}, nil]; c.each { |o| p o.to_a.push(9) }; p c
