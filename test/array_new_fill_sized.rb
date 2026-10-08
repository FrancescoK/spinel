# Array.new(n, v) on an Integer or Float array allocates its buffer once at
# size n and fills it. Each case checks something the pushes it replaced
# used to get right: the length, every slot's value, room to grow past n,
# and the argument checks.
# spinel: gc-minor
[0, 1, 15, 16, 17, 1000].each do |n|
  a = Array.new(n, 7)
  f = Array.new(n, 2.5)
  p [a.length, a.sum, f.length, f.sum(0.0)]
  a << 9
  f << 0.25
  p [a.length, a[-1], a[0], f.length, f[-1], f[0]]
end

# growing well past the initial size, then shrinking
g = Array.new(20, 1)
100.times { |i| g << i }
p g.length, g.sum
g.pop
g.shift
p g.length, g.first, g.last

# every slot is its own element: writing one leaves the rest
z = Array.new(3, 0.0)
z[1] += 1.5
p z
k = Array.new(4, -1)
k[2] = 5
p k

# NaN and negative zero keep their bits
nan = Array.new(2, 0.0 / 0.0)
p nan[0].nan?, nan[1].nan?
nz = Array.new(2, -0.0)
p nz, (1.0 / nz[1])

# a computed size and value, each evaluated once
calls = 0
sz = -> { calls += 1; 3 }
v = Array.new(sz.call, calls * 10)
p v, calls

# a frozen copy refuses the write
fr = Array.new(2, 1).freeze
begin
  fr[0] = 2
rescue FrozenError => e
  p e.class
end

# a negative size raises, as before
begin
  Array.new(-1, 0.0)
rescue ArgumentError => e
  p e.message
end
