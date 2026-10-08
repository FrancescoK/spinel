# `a[i] op= x` on an Integer or Float array folds the element in place when
# the index is in range and the array is not frozen: one bounds check instead
# of the read's and then the write's. Everything else goes the long way, and
# has to answer exactly what it did.
# spinel: gc-minor
counts = Array.new(4, 0)
zsum = Array.new(4, 0.0)
bins = [0, 1, 1, 3, 2, 1]
r = [0.5, 1.5, 2.5, 3.5, 4.5, 5.5]
j = 0
while j < bins.length
  b = bins[j]
  counts[b] += 1
  zsum[b] += r[j]
  j += 1
end
p counts, zsum

# every operator a scalar slot folds
a = [10, 20, 30, 40]
a[0] -= 3
a[1] *= 2
a[2] /= 7
a[3] %= 6
a[0] <<= 2
a[1] >>= 1
a[2] |= 8
a[3] &= 3
a[0] ^= 5
a[1] **= 2
p a
f = [1.5, 2.5, 3.5]
f[0] -= 0.25
f[1] *= 4.0
f[2] /= 2.0
p f

# negative indices count from the end
n = [1, 2, 3]
n[-1] += 10
n[-3] += 100
p n

# an RHS that reads the same array, the slot itself included
s = [1, 2, 3]
s[0] += s[2]
s[1] += s[1]
s[2] += s[0] * s[1]
p s

# an RHS that runs code keeps the long way: it grows the array under the write
g = [1, 2]
def grow(arr)
  arr.push(99)
  5
end
g[0] += grow(g)
p g

# a key with an effect runs once
calls = 0
k = [0, 0, 0]
[1, 2, 2].each do |x|
  k[(calls += 1; x)] += 1
end
p k, calls

# one past the end: nil + 1
e = [1, 2, 3]
begin
  e[3] += 1
rescue NoMethodError => ex
  p ex.class
end
p e.length

# a frozen array refuses the write
z = [1, 2, 3].freeze
begin
  z[0] += 1
rescue FrozenError => ex
  p ex.class
end
p z

# a key that reassigns the receiver's variable and allocates: the array read
# first is the one written, and it has to stay alive while the key runs
class Swapper
  attr_reader :keep
  def initialize
    @a = [0, 0, 0, 0]
    @keep = []
  end
  def key
    @a = [5, 5, 5, 5]
    junk = []
    300.times { |k| junk << Array.new(4) { |q| q + k } }
    @keep << Array.new(4) { |q| q * 10 }
    1
  end
  def bump
    @a[key] += 1
    @a
  end
end
sw = Swapper.new
res = nil
50.times { res = sw.bump }
p res
p sw.keep.all? { |x| x == [0, 10, 20, 30] }
