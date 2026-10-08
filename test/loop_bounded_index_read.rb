# `i = 0; while i < a.length ... a[i] ... i += 1; end` reads a[i] without a
# bounds test: i starts non-negative, only counts up, and the predicate has
# just checked it against the array's length. Each case below either has that
# shape (and must still read the right elements) or breaks one condition of it
# (and must keep the test, because there the index can be out of range or
# negative).
# spinel: gc-minor
# the shape itself, Integer and Float, length and size
a = [3, 1, 4, 1, 5, 9, 2, 6]
s = 0
i = 0
while i < a.length
  s += a[i]
  i += 1
end
p s
f = [0.5, 1.25, 2.0]
fs = 0.0
j = 0
while j < f.size
  fs += f[j] * 2.0
  j += 1
end
p fs

# the array grows inside the loop: the read follows the moved buffer
g = [1, 2, 3]
gs = 0
k = 0
while k < g.length
  gs += g[k]
  g[k + 3] = k * 10 if k < 4
  k += 1
end
p gs, g

# `next` after its own `m += 1`: that is a second write of the index, so the read
# keeps its test (and the elements still come out right)
nx = [5, 0, 7, 0, 9]
ns = 0
m = 0
while m < nx.length
  v = nx[m]
  if v == 0
    m += 1
    next
  end
  ns += v
  m += 1
end
p ns

# a negative start counts from the end
neg = [10, 20, 30, 40]
t = 0
q = -2
while q < neg.length
  t += neg[q]
  q += 1
end
p t

# the increment is not last: the read after it can be one past the end
late = [1, 2, 3]
lt = 0
lnil = 0
r = 0
while r < late.length
  r += 1
  v = late[r]
  if v.nil?
    lnil += 1
  else
    lt += v
  end
end
p lt, lnil

# a second write to the index
two = [1, 2, 3, 4, 5, 6]
tw = 0
w = 0
while w < two.length
  tw += two[w]
  w += 1 if two[w] && two[w] > 2
  w += 1
end
p tw

# an index into a different array than the one the loop is bounded by
short = [1, 2]
long = [7, 8, 9, 10]
ds = 0
dnil = 0
x = 0
while x < long.length
  v = short[x]
  if v.nil?
    dnil += 1
  else
    ds += v
  end
  x += 1
end
p ds, dnil

# the start is not the statement just ahead of the loop
st = [4, 5, 6]
y = 1
y += 1
ys = 0
while y < st.length
  ys += st[y]
  y += 1
end
p ys

# `until` takes no part
u = [2, 4, 6]
us = 0
z = 0
until z >= u.length
  us += u[z]
  z += 1
end
p us
