# Integer#times, #upto and #downto without a block answer an Enumerator
# labeled with the receiver and the call, as in CRuby. spinel answered the
# counted Range (`7..1`, `0...7`) wherever the value was kept, printed or
# walked with #next; a chain whose answer is the same over the Range (map,
# to_a, sum, ...) still walks it.
def box(v) = [v, "z"][0]

p 7.downto(1), 7.times, 3.upto(5)
p box(7).downto(5), box(7).times, box(7).upto(9)
p box(7).upto(box(9)), box("a").upto(box("c")), box("a").upto(box("c"), true)

e = 7.downto(5)
p e.next, e.next, e.size, e.class
t = 4.times
p t.map { |i| i * 2 }, t.to_a, t.first(2), t.peek

# a walk that answers its receiver answers the Enumerator
p 7.times.each_slice(3) { }
p 5.times.each_cons(4) { }
p 5.times.each_slice(2).to_a

# the chains that read the same over the Range
p 3.times.map { |i| i + 1 }, 1.upto(3).to_a, 9.downto(7).select(&:odd?)
p 4.times.sum, 4.times.with_index(1).to_a
p(4.times.with_index(1) { |x, i| x })

# a Float limit floors (upto) or ceils (downto), and an infinite one is
# walked only as far as it is read
p 7.downto(1.5), 1.upto(3.5).to_a
u = 1.upto(Float::INFINITY)
p u.size, u.first(3)
p [1, 2].zip(10.upto(Float::INFINITY))
p [:a, :b].zip(3.times)

# a long count too
n = 100_000.times
p n.size, n.next, n.first(2), n.map { |i| i }.size

def count_up(lo, hi) = lo.upto(hi)
p count_up(2, 4), count_up(2, 4).to_a
p [2.times]
