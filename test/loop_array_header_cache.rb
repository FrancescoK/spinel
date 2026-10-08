# A loop whose body runs no code keeps the headers of the arrays it indexes in
# C locals across its iterations, reading them again after anything that can
# move them. Each case below is one where a stale header would read or write
# the wrong memory, or where a check the cache stands in for has to still fire.
# spinel: gc-minor
# the histogram step itself
counts = Array.new(4, 0)
sums = Array.new(4, 0.0)
bins = [0, 1, 1, 3, 2, 1]
vals = [0.5, 1.5, 2.5, 3.5, 4.5, 5.5]
j = 0
while j < 6
  b = bins[j]
  counts[b] += 1
  sums[b] += vals[j]
  j += 1
end
p counts, sums

# writing past the end grows the array, many times over: every read after it
# has to see the new buffer and the new length
g = [0]
i = 1
while i < 2000
  g[i] = g[i - 1] + i
  i += 1
end
p g.length, g[1999], g[1000]

# growing the array moves its buffer: a write to an early element after that
# has to land in the new one, or the array keeps the value it was copied with
w = [0]
i = 1
while i < 1000
  w[i] = i
  w[0] += 1
  i += 1
end
p w[0], w.length

# two names for one array: a write through one that reallocates it is seen
# through the other
x = [1, 2]
y = x
i = 0
s = 0
while i < 500
  x[i + 2] = i
  s += y[i]
  i += 1
end
p s, y.length

# a frozen array refuses the write even with its header in hand
fz = [1, 2, 3].freeze
begin
  i = 0
  while i < 3
    fz[i] += 1
    i += 1
  end
rescue FrozenError => e
  p e.class
end
p fz

# negative indices count from the end, reading and writing
n = [10, 20, 30]
i = 0
t = 0
while i < 3
  t += n[-1 - i]
  n[-1 - i] = i
  i += 1
end
p t, n

# a local the loop reassigns is not cached: the array changes under the name
a1 = [1, 1, 1]
a2 = [100, 100, 100]
cur = a1
i = 0
ct = 0
while i < 6
  ct += cur[i % 3]
  cur = a2 if i == 2
  i += 1
end
p ct

# nor an ivar it writes
class Holder
  def initialize
    @v = [1, 2, 3]
    @w = [10, 20, 30]
  end
  def run
    i = 0
    t = 0
    while i < 6
      t += @v[i % 3]
      @v = @w if i == 2
      i += 1
    end
    t
  end
end
p Holder.new.run

# break and next leave the cached headers behind cleanly
bi = 0
bt = 0
while bi < 100
  bi += 1
  next if counts[bi % 4] == 1
  bt += counts[bi % 4]
  break if bt > 10
end
p bi, bt

# getbyte: in range, negative and past the end (nil, counted as -1)
str = "abcdef"
k = -8
acc = 0
while k < 9
  acc = acc * 3 + (str.getbyte(k) || -1)
  k += 1
end
p acc

# a field read whose object is nil, in a loop that never runs
class Box
  attr_reader :data
  def initialize
    @data = [1.0, 2.0]
  end
end
box = nil
i = 0
ft = 0.0
while i < 0
  ft += box.data[i]
  i += 1
end
p ft
box = Box.new
i = 0
while i < 2
  ft += box.data[i]
  i += 1
end
p ft

# a class test on a scalar is its nil test: the loop still caches, and the
# test still answers
qv = [1.5, 0.0 / 0.0, -2.0, 4.0]
qk = [3, 1, 4, 1]
qs = Array.new(4, 0.0)
i = 0
qt = 0
while i < 4
  v = qv[i]
  k = qk[i]
  qs[i] = (v.is_a?(Float) && v.nan?) ? 0.0 : v * 2.0
  qt += k if k.is_a?(Integer) && k.kind_of?(Numeric) && !k.nil?
  qt += 1000 if !k || !v
  qt += 100 if v.instance_of?(Integer)
  i += 1
end
p qs, qt
