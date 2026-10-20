# Range#cover? on a typed Integer Range given a boxed value that is a Range
# at run time: whether the Range lies inside, as for a typed argument. The
# boxed argument was compared as a member, and the call answered false.

r = (1..3)
def pick(a, i) = a[i]
xs = [2..3, 1, 0..5, 1.5..2.5, 2...4, 3...4, "a".."b", nil, 2.5, (1..), :s]
xs.size.times { |i| p [i, r.cover?(pick(xs, i))] }
e = (1...3)
p e.cover?(pick([1..2, 1], 0)), e.cover?(pick([1..3, 1], 0)), e.cover?(pick([1...3, 1], 0))

# an empty Float Range, typed or boxed, is covered by none
e1 = [(2.0...2.0), 1][ARGV.size]
e2 = [(3.0..2.0), 1][ARGV.size]
p (1..5).cover?(3.0...3.0), (1..3).cover?(e1), (1..3).cover?(e2), (1..3).cover?(1.5..2.5)
# ... and so is one with a bound written as an Integer
i1 = [(2...2.0), 1][ARGV.size]
i2 = [(3..2.0), 1][ARGV.size]
p (1..3).cover?(i1), (1..3).cover?(i2), (1..3).cover?([(2..2.5), 1][ARGV.size])
