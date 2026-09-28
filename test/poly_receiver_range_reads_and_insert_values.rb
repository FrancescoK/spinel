# A Range reaching a poly receiver answers the count-taking reads, size and
# count from its members, and Array#insert takes any number of values: through
# a boxed receiver, and into a caller's typed array, which widens.

def l(o, n) = o.last(n)
p l([1, 2], 1)
p l(1..3, 2)
p l(1...4, 2)
p l(1..3, 5)
p l(3..1, 2)
p l("a".."c", 2)
p((l(1.., 2) rescue $!))

def dr(o, n) = o.drop(n)
p dr([1, 2], 1)
p dr(1..5, 2)
p dr("a".."c", 1)

def mn(o, n) = o.min(n)
p mn([3, 1, 2], 2)
p mn(1..3, 2)
p mn({ b: 1, a: 2 }, 1)
p((mn([1], -1) rescue $!))

def mx(o, n) = o.max(n)
p mx([3, 1, 2], 2)
p mx(1..3, 5)
p mx("a".."e", 2)

def sz(o) = o.size
p sz([1])
p sz(1...10)
p sz("a".."c")

def ct(o) = o.count
p ct([1])
p ct(1..10)
p ct("a".."c")
p ct([1, 2, 3].each_slice(2))

def tail_sum(o) = o.last(2).sum
p tail_sum([2, 1])
p tail_sum(1..3)

# insert through a boxed receiver, from a splat of any length
def insp(o, *r) = o.insert(*r)
p insp([1, 2], 1, 7, 8, 9)
p insp([1, 2], -2, 7, 8)
p insp([1, 2], 1)
p insp([1, 2], 4, 5, 6)
p insp(+"ab", 1, "Z")
p((insp([1, 2], -4, 7, 8) rescue $!))
p((insp(+"ab", 1, "Z", "Y") rescue $!))
p((insp({ a: 1 }, 1, 7, 8) rescue $!))

# values of other kinds widen the caller's typed array
def ins(a, *r) = a.insert(*r)
p ins([1, 2], 1, 2)
p ins([1, 2], 1, :x, :y, :z)
x = [1, 2]
ins(x, 1, :x, :y)
p x
y = [1, 2]
ins(y, 0, 5, 6)
p y

def ins3(a, i, v, w) = a.insert(i, v, w)
p ins3([1, 2], 1, :x, "s")
def ins3f(a, i, v, w) = a.insert(i, v, w)
f = [1.0]
p ins3f(f, 0, 2.0, :k)
p f

def pu(a, *r) = a.push(*r)
p pu([1, 2], :x, :y)
def pus(a, *r) = a.push(*r)
s = %w[a b]
pus(s, "c", 4)
p s

def uns(a, *r) = a.unshift(*r)
p uns([1, 2], :x, :y)
ys = [:a]
p uns([1], *ys)
p uns([1], *[:b])

def ins_post(a, i, *r, last) = a.insert(i, *r, last)
z = [1, 2]
p ins_post(z, 1, 3, 4, "s")
p z

# push and unshift of a splat through a receiver of more than one array kind
def pw(a, *r) = a.push(*r)
p pw([1], 2, 3)
p pw(%w[a], "b")
def uw(a, *r) = a.unshift(*r)
p uw([1], 2, 3)
p uw(%w[a], "b")

# a rest stored through a parameter two array kinds make boxed: each call's
# own arguments are checked against its own array
def insb(a, *r) = a.insert(*r)
p insb([1, 2], -1, :x, :y)
p insb(%w[a b], 1, 3)
p insb([1, 2], 0, 9)
