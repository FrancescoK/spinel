# A nil stored into an Integer or Float array marks the slot it was stored
# through. Another name for the same array -- the caller's argument when the
# slot is a parameter, the source of an alias, the array an ivar was handed,
# a container's element, the receiver a Method object was bound to -- saw no
# mark, and its whole-array reads took the nil for a number. The store now
# notes the array's run-time nil flag whenever the slot can share its array.

def t
  yield
rescue => e
  e.class
end

H = {1 => 2}
F = {1 => 2.5}

# through a parameter: <<, push, []=, unshift, insert
def add(x, k) = x << H[k]
c = [5]
add(c, 9)
p c, t { c.max }, t { c.sum }, c.include?(nil), c.count(nil)

def push_to(x, k)
  x.push(H[k])
  nil
end
c2 = [4]
push_to(c2, 9)
p t { c2.min }, c2.index(nil)

def set_at(x, i) = (x[i] = H[i])
d = [7, 8]
set_at(d, 0)
p d, t { d.max }, d.count(nil)

def unshift_to(y, k) = y.unshift(H[k])
def through(x, k) = unshift_to(x, k)
e = [9]
through(e, 4)
p e, t { e.max }, e.index(nil)

def insert_at(x, k)
  x.insert(1, H[k])
  nil
end
g = [1, 2]
insert_at(g, 3)
p g, t { g.sort }

# a Float array through a parameter
def addf(x, k)
  x << F[k]
  nil
end
fa = [1.5]
addf(fa, 9)
p fa, t { fa.max }, t { fa.sum }

# a local alias, an ivar handed the array, a container's element
a = [5]
b = a
b << H[9]
p t { a.max }, a.include?(nil)

class Holder
  def initialize(x) = (@x = x)
  def add(k) = (@x << H[k])
end
h = [6]
Holder.new(h).add(9)
p t { h.max }, h.include?(nil)

f = [1]
[f].each { |z| z << H[5] }
p t { f.max }, f.count(nil)

# a Method bound to the array
ram = [0] * 4
w = ram.method(:[]=)
w.call(1, H[9])
p ram, t { ram.max }

# an array a slot owns keeps its static mark
own = [1, 2]
own << H[9]
p own, t { own.max }, own.count(nil)
