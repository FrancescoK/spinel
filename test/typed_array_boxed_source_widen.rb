# A typed array held in a boxed slot -- a local written arrays of two kinds,
# an element read out of a general container, a block parameter, a `for`
# variable, a boxed parameter -- takes a store of another kind through the
# box: the store promoted a copy into that one slot, so the caller's local,
# the array it was read from and the container it came out of kept the
# typed array without it (`x = ints; set(x); p x` printed [1, 2]), or the
# store raised TypeError. The arrays the boxed value can be are followed back
# to where they are built and built as the general Array there. Each case has
# its own method, so each one widens on its own store.

def set1(a) = a[0] = "s"
def set2(a) = a[0] = "s"
def set3(a) = a[0] = 1.5
def shl1(a) = a << "s"
def shl2(a) = a << "s"
def shl3(a) = a << "s"
def shl4(a) = a << "s"
def shl5(a) = a << "s"
def shl6(a) = a << "s"
def cat1(a) = a.concat(["c"])
def fil1(a) = a.fill(:f)
def spl1(a) = a[0, 1] = ["s", "t"]
def ins1(a) = a.insert(1, "i")
def uns1(a) = a.unshift(nil)

# a local assigned typed arrays of two kinds, through methods and locals
def ints = [1, 2]
def strs = %w[a b]
x = ints
x = strs if ARGV.size > 5
set1(x)
p x
y = ARGV.empty? ? [3, 4] : ["q"]
set3(y)
p y
z = [5, 6]
z = [7.5] if ARGV.size > 5
cat1(z)
p z
def either = ARGV.empty? ? Array.new(2, 0) : [1.5]
w = either
fil1(w)
p w

# the store through an alias of the boxed local, and through a parameter
# handing it on
v1 = [1, 2]
v1 = ["a"] if ARGV.size > 5
v2 = v1
v2[0] = "s"
p v1
def pass_on(a) = shl1(a)
v3 = [8]
pass_on(v3)
pass_on(["b"])
p v3

# an element read, a Hash value, a block parameter, a `for` variable, `||=`
outer = [[1, 2]]
shl2(outer[0])
p outer
h = {k: [1, 2]}
shl3(h[:k])
p h
[[3, 4], [5]].each { |r| shl4(r) }
t = [[1, 2], [3]]
t.each { |r| shl5(r) }
p t
for r in [[6, 7]]
  shl6(r)
  p r
end
o = nil
o ||= [1, 2]
set2(o)
p o

# splice, insert and unshift through a boxed parameter
s1 = [1, 2]
spl1(s1)
spl1(["x"])
p s1
s2 = [1, 2]
ins1(s2)
ins1([1.5])
p s2

# the program that did not converge: a parameter a store widened, met by a
# boxed argument and an array literal in turn, flipped between the general
# Array and the boxed value every round
def i2 = [1, 2]
def s2k = %w[a b]
def set4(a) = a[0] = "s"
q = i2; set4(q); r0 = q; q = s2k; set4([5])
p r0, q
q = s2k; uns1(q); p q
