# A value that is a String or nil, stored in an Array or a Hash whose
# elements are changed in place, is stored as it is: the nil stays nil.
# The store wraps each String as a handle; it wrapped the nil as one too,
# and the element read as a String that was not there: printing it was a
# segmentation fault, `nil?` answered false and `compact` kept it.

def pick(i) = i == 0 ? "pa".dup : nil

def tail(s, at)
  s[at, 2]
end

class K
  def initialize(x) = @x = x
  def plus = @x + "a"
end

class N
  def plus = nil
end

# an Array literal
z = [pick(0), pick(1)]
z[0] << "!"
p z
p z[1], z[1].nil?, z[1] == nil, (z[1] ? 1 : 2)
p z[1].to_s, "<#{z[1]}>", z[1].inspect, z[1].class
p z[1]&.size, (z[1] || "d")
p z.compact, z.compact.size, z.include?(nil), z.count(nil), z.index(nil)
p z.map { |s| s.nil? }, z.select { |s| s }, z.reject(&:nil?), z.any?(&:nil?), z.all?
z.each { |s| p s }
z.each_with_index { |s, i| p [i, s] }
p z.dup, z.reverse, z + z, z.first(2), z.last, z.uniq
p z.join("-"), z == ["pa!", nil]
puts z[1]
puts z.inspect, z.to_s

# an append to every element that is one
y = [pick(0), pick(1), pick(0)]
y.each { |e| e << "?" if e }
p y

# pushes and an element store
q = []
q << pick(1)
q << pick(0)
q.push(pick(1), pick(0))
q[1] << "!"
p q, q.compact.size
q[0] = pick(0)
q[3] = pick(1)
q[0] << "+"
p q

# a Hash, by its literal and by a store
h = { a: pick(0), b: pick(1) }
h[:a] << "!"
p h[:a], h[:b], h[:b].nil?, h.values, h.key(nil), h.value?(nil)
p h.count { |_, v| v.nil? }, h.to_a
h.each { |k, v| p [k, v] }
g = {}
g["a"] = pick(0)
g["b"] = pick(1)
g["a"] << "!"
p g["a"], g["b"], g.values.compact, g.fetch("b")

# other values that can be nil
s = "hello".dup
t = [tail(s, 1), tail(s, 9), s[1, 2], s[9, 2]]
t[0] << "!"
p t
src = ["xy".dup, "zw".dup]
u = [src[0], src[5], src.find { |e| e == "no" }, src[2..].first]
u[0] << "!"
p u
tab = { "k" => "v".dup }
w = [tab["k"], tab["no"], pick(1)&.upcase, pick(0)&.upcase, "AB".dup.upcase!]
w[0] << "!"
p w

# a call found at run time
n = [K.new("s".dup), N.new]
v = [n[0].plus, n[1].plus]
v[0] << "!"
p v, v[1].nil?

# a block's value and an Array inside an Array
m = [0, 1].map { |i| pick(i) }
m[0] << "!"
p m
a = Array.new(2) { |i| pick(i) }
a[0] << "!"
p a
d = [[pick(0), pick(1)], [pick(1)]]
d[0][0] << "!"
p d, d[1][0].nil?

# the same store with no nil in it is as it was
k = [pick(0), "lit", "a#{1}", tail(s, 0)]
k[0] << "!"
k[3] << "?"
p k

# a nil read back as the needle of a search: a handle around nothing was
# read through there
w2 = ["ab", "cd", "ef"]
n2 = ["a".dup, 2, pick(1)]
n2[0] << "b"
p w2.include?(n2[2]), w2.member?(n2[2]), w2.include?(n2[0]), w2.index(n2[2])

# a value that is never nil is stored as it was; a dup of one that can be
# nil is not such a value
s2 = pick(1)
c = [+"ab", "cd".dup, "e" + "f", 5.to_s, s2.dup, pick(1).dup, (pick(1)).dup, pick(0).dup]
c[0] << "!"
c[7] << "?"
p c, c[4].nil?, c[5].nil?
