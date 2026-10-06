# cover? with a Range argument: on a Range read out of a mixed Array (an
# Integer or a Float one, the argument plain or boxed), and an empty
# argument, which no Range covers. include? and === of a Range stay false.
x = [(1..10), 5][0]
p x.cover?(2..3)
p x.cover?(2..11)
p x.cover?(0..3)
p x.cover?(1...11)
p x.cover?(5)
p [(1...10), 5][0].cover?(2..10)
p [(1...10), 5][0].cover?(2...10)
p (1..10).cover?(2..3)
p x.cover?([(2..3), 5][0])
p [(1.0..2.0), 5][0].cover?(1.5)
p x.include?(2..3)
y = [(2..3), :a][0]
p x.cover?(y)
p x.include?(y)
p x === y
p x.cover?([(0..3), :a][0])
p x.cover?([5, :a][0])
p x.cover?([2.5, :a][0])
f = [(1.0..2.0), 5][0]
p f.cover?(1..2)
p f.cover?(1...3)
p f.cover?(1..3)
p [(1.0...2.0), 5][0].cover?(1..2)
p [(1.0...2.0), 5][0].cover?(1...2)
p [(1.5..2.0), 5][0].cover?(1..2)
p [(1.0..), 5][0].cover?(5..9)
p (1..5).cover?(3..2)
p (1..5).cover?(3...3)
p x.cover?(3..2)
p [(1.0..5.0), 5][0].cover?(3...3)
