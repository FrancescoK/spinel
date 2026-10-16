# spinel: share
# spinel: gc-minor
# Arrays of shared Strings built and changed in loops that allocate: the
# Array scans its Strings, a store keeps the generational write barrier, and
# a String reached only through the Array stays alive.
rows = []
1500.times do |i|
  row = +"row"
  row << i.to_s
  rows << row
  rows << "#{i}-lit" if i % 7 == 0
  junk = "junk" * (i % 5 + 1)
  junk << "!"
end
rows.each { |r| r << "." }
total = 0
rows.each { |r| total += r.size }
p rows.size, total, rows[0], rows[-1], rows[1500]
keep = []
200.times do |i|
  t = +"k#{i}"
  keep << t
  t << "+"
end
keep.shift
keep.pop
keep[3] = +"swapped"
keep << keep.first
GC.start
p keep.size, keep[3], keep.last.equal?(keep.first), keep[199]
old = rows[0]
300.times { |i| rows[0] = +"new#{i}"; GC.start if i % 100 == 0 }
p rows[0], old
