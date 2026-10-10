# spinel: share
# spinel: gc-stress
# A boxed Float Range's inspect builds the text of each end as a new String,
# and the first was held by nothing while the second was built, so under
# SPINEL_GC_STRESS=2 it printed freed memory.
def show(r) = p(r)
a = [1.0..2.5, 3, 1.5...4.25, 1.5..5, 1..2.5]
show(a[0])
show(a[2])
show(a[3])
show(a[4])
x = a[0]
p x
puts x.inspect
puts x.to_s
puts "#{a[2]}"
h = { r: 0.5..9.75, s: (..2.5), t: (1.5..) }
p h
p h[:s], h[:t], h[:r]
p [a[0], a[2]].map(&:to_s)
GC.start
p a[0], x
