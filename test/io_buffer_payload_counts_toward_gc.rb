# spinel: not-cruby -- CRuby keeps IO::Buffer bytes outside its malloc accounting, so it runs no collection here either.
# spinel: gc-minor
# spinel: gc-stress
# An IO::Buffer keeps its bytes outside its own slot, and the collector's
# trigger never saw them: allocating a buffer moved the live-byte counter by
# the buffer's header alone. A program that made large buffers and dropped
# them ran no collection at all, and every dropped buffer stayed allocated.
#
# Each way of getting a buffer that owns its bytes is churned, with nothing
# else allocated, so a collection must have run while it did: new, a resize
# that grows, a slice that detaches on resize, dup, and the result of `~`.
# Explicit frees and a transfer then run through the same counts.
ROUNDS = 200
SIZE = 4_000_000

# GC.stat's "cycle" is spinel's count of collections; CRuby's is :count
def collections
  s = GC.stat
  s.key?("cycle") ? s["cycle"] : GC.stat(:count)
end

def report(name, before)
  puts name + ": collected while churning: " + (collections > before ? "yes" : "no")
end

total = 0

before = collections
ROUNDS.times do |r|
  b = IO::Buffer.new(SIZE)
  b.set_value(:U8, r, 1)
  total += b.size / 1_000_000
end
report("new", before)

before = collections
ROUNDS.times do |r|
  b = IO::Buffer.new(16)
  b.resize(SIZE)
  total += b.size / 1_000_000
end
report("resize", before)

small = IO::Buffer.new(16)
before = collections
ROUNDS.times do |r|
  s = small.slice(0, 8)
  s.resize(SIZE)
  total += s.size / 1_000_000
end
report("slice resize", before)

big = IO::Buffer.new(SIZE)
before = collections
ROUNDS.times do |r|
  d = big.dup
  total += d.size / 1_000_000
end
report("dup", before)

before = collections
ROUNDS.times do |r|
  n = ~big
  total += n.size / 1_000_000
end
report("not", before)

ROUNDS.times do |r|
  b = IO::Buffer.new(SIZE)
  t = b.transfer
  t.resize(SIZE / 2)
  total += t.size / 1_000_000 + b.size
  t.free
  b.free
end
puts total
