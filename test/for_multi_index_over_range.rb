# `for a, b in` over a range: each element destructures as `a, b = el` does,
# so the first index takes it and the rest are nil. A literal range, one held
# in a local, an endless one and a String range.

for a, b in 1..3
  p [a, b]
end
p [a, b]

r = (4...6)
for x, y in r
  p [x, y]
end

def sum_pairs(n)
  s = 0
  for i, j in 1..n
    next if i == 2
    s += i
    s += 100 if j.nil?
  end
  s
end
p sum_pairs(4)

for e, f in (1..)
  break if e > 2
  p [e, f]
end

for s, t in "a".."c"
  p [s, t]
end
sr = "x".."y"
for u, v in sr
  p [u, v]
end
