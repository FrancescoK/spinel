# Range#overlap? as CRuby decides it: an empty Range overlaps nothing, an
# exclusive end does not reach the other begin, a Float Range compares as a
# number, and a Range read out of a mixed Array answers too.
x = [(1..5), 1][0]
p x.overlap?(5..7)
p x.overlap?(6..7)
p [(1...5), 1][0].overlap?(5..7)
p x.overlap?(5...5)
p [(3..1), 1][0].overlap?(1..3)
p [(1..), 1][0].overlap?(..0)
p [(1..), 1][0].overlap?(..1)
p x.overlap?(2.5..3.0)
p [(1.0..2.0), 1][0].overlap?(2..3)
p [(1.0...2.0), 1][0].overlap?(2..3)
p x.overlap?([(4..9), 1][0])
p (1..5).overlap?([(5..9), 1][0])
p (1..5).overlap?(5...5)
p (3..1).overlap?(1..3)
p (1..5).overlap?(2.5..3.0)
p (1..5).overlap?("a".."c")
def t
  p yield
rescue => e
  puts "#{e.class}: #{e.message}"
end
t { x.overlap?(3) }
t { [:a, 1][0].overlap?(1..2) }
r = [(1..5), 1][0]
p(r.overlap?(0..1) ? "yes" : "no")
