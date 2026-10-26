# spinel: int64 -- assumes a 64-bit Integer (values or arithmetic past 2^31); not run on a 32-bit target
# An Integer#times loop that sets each element of an IO::Buffer from the
# same element of others (`o.set_value(:T, i * W, e)`, e of get_values,
# literals and operators) runs in chunks ahead of its loop; what it stores
# and raises is the loop's. Counts around a chunk (64 elements), a 32-bit
# value out of range part way (RangeError, the elements ahead of it stored,
# those after it not), an update in place, a source that overlaps the
# output shifted or at another width, a read-only and a too-short output,
# Floats, the bit operators and shifts, wrapping 8/16-bit stores, the
# big-endian types and two sources.

def vals(b, t, w, n)
  out = []
  i = 0
  while i < n
    out << b.get_value(t, i * w)
    i += 1
  end
  out
end

def show(label, a)
  puts "#{label}: #{a.size} #{a.sum} #{a.first(3).inspect} #{a.last(3).inspect}"
end

def u32_src(n)
  b = IO::Buffer.new(n * 4 + 4)
  i = 0
  while i <= n
    b.set_value(:u32, i * 4, i * 7 + 1)
    i += 1
  end
  b
end

# counts around a chunk
[0, 1, 63, 64, 65, 200].each do |n|
  s = u32_src(n)
  o = IO::Buffer.new(n * 4 + 4)
  n.times do |i|
    o.set_value(:u32, i * 4, s.get_value(:u32, i * 4) * 3 + 5)
  end
  show("count #{n}", vals(o, :u32, 4, n + 1))
end

# a value past 2^32 - 1 at element 150 of 200
s = u32_src(200)
s.set_value(:u32, 150 * 4, 0x80000000)
o = IO::Buffer.new(200 * 4)
o.set_value(:u32, 151 * 4, 42)
begin
  200.times do |i|
    o.set_value(:u32, i * 4, s.get_value(:u32, i * 4) * 2)
  end
rescue RangeError => e
  puts "u32: #{e.class}"
end
show("u32 stored", vals(o, :u32, 4, 200))

# a signed store below -2^31, and an unsigned one of a negative it takes
s = IO::Buffer.new(200 * 4)
i = 0
while i < 200
  s.set_value(:s32, i * 4, -i * 1000)
  i += 1
end
s.set_value(:s32, 170 * 4, -0x7fffffff)
o = IO::Buffer.new(200 * 4)
begin
  200.times do |i|
    o.set_value(:s32, i * 4, s.get_value(:s32, i * 4) - 7)
  end
rescue RangeError => e
  puts "s32: #{e.class}"
end
show("s32 stored", vals(o, :s32, 4, 200))
o = IO::Buffer.new(200 * 4)
200.times do |i|
  o.set_value(:u32, i * 4, s.get_value(:s32, i * 4) >> 3)
end
show("u32 of negatives", vals(o, :u32, 4, 200))

# in place
b = u32_src(130)
130.times do |i|
  b.set_value(:u32, i * 4, b.get_value(:u32, i * 4) + 1)
end
show("in place", vals(b, :u32, 4, 131))

# a source overlapping the output a few bytes on, and at another width
b = u32_src(130)
s = b.slice(4, 130 * 4)
130.times do |i|
  b.set_value(:u32, i * 4, s.get_value(:u32, i * 4) + 1)
end
show("shifted", vals(b, :u32, 4, 131))
b = u32_src(130)
130.times do |i|
  b.set_value(:u32, i * 4, b.get_value(:u16, i * 2) + 1)
end
show("widths", vals(b, :u32, 4, 131))

# a read-only output, and one too short for the count
s = u32_src(100)
r = IO::Buffer.for("x" * 400)
begin
  100.times do |i|
    r.set_value(:u32, i * 4, s.get_value(:u32, i * 4))
  end
rescue => e
  puts "read-only: #{e.class}"
end
o = IO::Buffer.new(90 * 4)
begin
  100.times do |i|
    o.set_value(:u32, i * 4, s.get_value(:u32, i * 4) * 2)
  end
rescue => e
  puts "short: #{e.class}"
end
show("short stored", vals(o, :u32, 4, 90))

# Floats
f = IO::Buffer.new(100 * 8)
i = 0
while i < 100
  f.set_value(:f64, i * 8, i * 0.25 - 3.0)
  i += 1
end
g = IO::Buffer.new(100 * 8)
100.times do |i|
  g.set_value(:f64, i * 8, f.get_value(:f64, i * 8) * 1.5 + 2)
end
show("f64", vals(g, :f64, 8, 100))
h = IO::Buffer.new(100 * 4)
100.times do |i|
  h.set_value(:f32, i * 4, -f.get_value(:f64, i * 8) / 3.0)
end
show("f32", vals(h, :f32, 4, 100))
100.times do |i|
  g.set_value(:F64, i * 8, s.get_value(:u32, i * 4) * 2 - 1)
end
show("F64 of Integers", vals(g, :F64, 8, 100))

# the bit operators and shifts, 8/16-bit stores wrapping
s16 = IO::Buffer.new(100 * 2)
i = 0
while i < 100
  s16.set_value(:s16, i * 2, (i - 50) * 613)
  i += 1
end
o = IO::Buffer.new(100 * 2)
100.times do |i|
  o.set_value(:u16, i * 2, (s16.get_value(:s16, i * 2) >> 2) ^ 0x5a5a)
end
show("xor shift", vals(o, :u16, 2, 100))
o8 = IO::Buffer.new(100)
100.times do |i|
  o8.set_value(:U8, i, -(s16.get_value(:s16, i * 2) << 3) | 1)
end
show("wrap", vals(o8, :U8, 1, 100))
o = IO::Buffer.new(100 * 4)
100.times do |i|
  o.set_value(:S32, i * 4, s16.get_value(:s16, i * 2) & -16)
end
show("big-endian", vals(o, :S32, 4, 100))

# two sources
a = u32_src(100)
c = IO::Buffer.new(100 * 2)
i = 0
while i < 100
  c.set_value(:U16, i * 2, i * 300)
  i += 1
end
o = IO::Buffer.new(100 * 4)
100.times do |i|
  o.set_value(:s32, i * 4, a.get_value(:u32, i * 4) * 3 - c.get_value(:U16, i * 2) + 7)
end
show("two sources", vals(o, :s32, 4, 100))
