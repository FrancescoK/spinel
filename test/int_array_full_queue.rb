# A queue of Integers at its capacity
# A push into a full Integer array whose head was shifted off slides the
# elements home, and grows it as well unless the shift freed as many slots as
# there are elements. These run queues across both: one held at its capacity,
# one that drains most of the way and refills, one that holds nils, and the
# other Array operations on a queue that went through both.

# held at its capacity (Array.new(n) fills it): a shift, then a push
q = Array.new(33) { |i| i }
sum = 0
200.times do |r|
  sum += q.shift
  q << r * 3
end
p q.size, sum, q.first(4), q.last(4)

# shifted most of the way down, then pushed past the old capacity
q = Array.new(16) { |i| i * 10 }
12.times { q.shift }
p q
20.times { |i| q.push(i) }
p q.size, q.first(6), q.last(3)

# a frontier that grows and shrinks: k pushes, then k - 1 shifts
q = [0]
total = 0
1.upto(40) do |k|
  k.times { |i| q.push(k * 100 + i) }
  (k - 1).times { total += q.shift }
end
p q.size, total, q.first, q.last

# nils ride along through the slide and the growth
q = Array.new(16) { |i| i.even? ? i : nil }
40.times do |r|
  v = q.shift
  q << (v.nil? ? r : nil)
end
p q.size, q.count(nil), q
q2 = Array.new(16) { |i| i }
15.times { q2.shift }
gap = q2.empty? ? 0 : nil
q2 << gap
q2 << 7
q2 << gap
20.times { |i| q2 << (i % 3 == 0 ? nil : i) }
p q2.size, q2.index(nil), q2.rindex(nil), q2.compact.sum, q2

# the other operations on a queue that went through both
q3 = Array.new(17) { |i| i }
40.times { |i| q3.shift; q3 << i * 2 }
q3.unshift(-1)
q3.insert(4, 99)
q3.delete_at(2)
q3.rotate!(5)
p q3, q3.sort.first(3), q3.reverse.first(3), q3.sum, q3.dup.size, q3[1, 4]
