# An Integer Range and a Float Range read out of a mixed Array are == when
# their ends are equal as numbers and their exclusiveness matches, as Range#==
# compares ends with ==. eql? still tells them apart.
r = [(1..10), 5][0]
f = [(1.0..10.0), 5][0]
p r == (1.0..10.0)
p f == (1..10)
p (1..10) == f
p r == f
p r != f
p r == (1.0...10.0)
p r == (1.0..10.5)
p [(1..10)] == [(1.0..10.0)]
p [r].include?(1.0..10.0)
p [(..5), 1][0] == (..5.0)
p [(1..), 1][0] == (1.0..)
p [(1..), 1][0] == (1.0..Float::INFINITY)
p [(1..2.0), 1][0] == (1.0..2.0)
p r.eql?(f)
p f.eql?(r)
p [r, f].uniq.size
h = {r => 1}
p h[(1.0..10.0)]
