# GC.count is the number of collections so far: an Integer that never
# decreases and grows across GC.start.
c0 = GC.count
p c0.is_a?(Integer)
p c0 >= 0
a = []
20000.times { |i| a << "s#{i}" }
GC.start
c1 = GC.count
p c1 > c0
p a.size
p GC.respond_to?(:count)
