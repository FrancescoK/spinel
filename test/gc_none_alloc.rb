# --gc=none (gc-none-test): a program that allocates past every collection
# trigger and asks for a collection answers as with the collector, which
# is not in its build.
a = []
200_000.times { |i| a << "s#{i}"; a.shift if a.size > 100 }
p a.size
GC.start
p a.last
h = {}
50_000.times { |i| h[i % 64] = [i, i.to_s] }
p h.size, h[63]
